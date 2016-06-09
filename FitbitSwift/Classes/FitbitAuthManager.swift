//
//  SwiftBit.swift
//  Pods
//
//  Created by Albert Jo on 5/12/16.
//
//

import Locksmith
import SwiftyJSON
import Alamofire

let ACCOUNT = "authentiated user"
let SERVICE = "Fitbit"

public enum FitbitScope: String {
    case activity, heartrate, location, nutrition, profile, settings, sleep, social, weight
    
    public static func all() -> [FitbitScope] {
         return [FitbitScope.activity, FitbitScope.heartrate, FitbitScope.location, FitbitScope.nutrition,
                     FitbitScope.profile, FitbitScope.settings, FitbitScope.sleep, FitbitScope.social, FitbitScope.weight]
    }
    
    public static func generateUrlString(scopes: Array<FitbitScope>) -> String {
        return getStringArray(scopes).joinWithSeparator("%20")
    }
    
    public static func getStringArray(scopes: Array<FitbitScope>) -> [String] {
        var array = [String]()
        for scope in scopes {
            array.append(scope.rawValue)
        }
        return array
    }
}

struct FitbitOAuthKeys: CreateableSecureStorable,
                        GenericPasswordSecureStorable,
                        DeleteableSecureStorable,
                        ReadableSecureStorable {
    let accessToken : String
    let refreshToken : String
    let expiresIn : Int
    let dateCreated : NSDate
    
    static var sharedInstance : FitbitOAuthKeys? {
        if let data = Locksmith.loadDataForUserAccount(ACCOUNT, inService: SERVICE) {
            return FitbitOAuthKeys(accessToken: data["access_token"] as! String,
                                   refreshToken: data["refresh_token"] as! String,
                                   expiresIn: data["expires_in"] as! Int,
                                   dateCreated: data["date_created"] as! NSDate)
        }
        return nil
    }
    
    // Required by GenericPasswordSecureStorable
    let service = SERVICE
    let account = ACCOUNT
    
    // Required by CreateableSecureStorable
    var data: [String: AnyObject] {
        return ["access_token": accessToken,
                "refresh_token": refreshToken,
                "expires_in": expiresIn,
                "date_created": dateCreated]
    }
}


public class FitbitAuthManager {
    
    var OAuthTokenCompletionHandler:(NSError? -> Void)?
    var clientID: String
    var clientSecret: String
    var redirectUrl: String
    var authorizeUrl = "https://www.fitbit.com/oauth2/authorize"
    var accessTokenUrl =  "https://api.fitbit.com/oauth2/token"
    var scope : [FitbitScope] = FitbitScope.all()
    var oauthKeys : FitbitOAuthKeys? { return FitbitOAuthKeys.sharedInstance }
    var authorizationHeader : [String : String] { return [ "Authorization": "Bearer \(oauthKeys!.accessToken))" ] }
    var authorizationCode : String { return convertToBase64("\(clientID):\(clientSecret)") }
    
    
    // MARK: Initializer
    
    public init(clientID: String, clientSecret: String, redirectUrl: String, scope : [FitbitScope]?) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectUrl = redirectUrl
        if let _scope = scope {
            self.scope = _scope
        }
    }
    
    // MARK: Authentication
    
    func beginOAuthRequest() {
        let escapedCallbackURL = escapedString(redirectUrl)
        let authPath = "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(escapedCallbackURL)&scope=\(FitbitScope.generateUrlString(scope))&expires_in=604800"
        if let authURL:NSURL = NSURL(string: authPath) {
            UIApplication.sharedApplication().openURL(authURL)
        }
    }
    
    func processOAuthResponse(url: NSURL) {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        guard components != nil else {
            return
        }
        
        guard let code = components!.code else {
            return
        }
        
        let headers = [
            "Authorization": "Basic \(authorizationCode)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters = [
            "grant_type":"authorization_code",
            "client_id":clientID,
            "redirect_uri":redirectUrl,
            "code":code
        ]
        
        Alamofire.request(.POST, accessTokenUrl, parameters: parameters, headers: headers)
            .validate()
            .responseJSON {
            response in
            var requestError : NSError?
            
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    self.saveOAuthKeys(JSON(value))
                }
            case .Failure(let error):
                requestError = error
            }
            
            // Execute completion handler
            if let completionHandler = self.OAuthTokenCompletionHandler {
                completionHandler(requestError)
            }
        }
    }

    func isAuthenticated() -> Bool {
        return oauthKeys != nil
    }
    
    public func deleteOAuthToken() -> Bool {
        if oauthKeys != nil {
            do {
                if Locksmith.loadDataForUserAccount(ACCOUNT, inService: SERVICE) != nil {
                    try Locksmith.deleteDataForUserAccount(ACCOUNT, inService: SERVICE)
                    return true
                }
            } catch {
                handleKeychainError(error)
            }
        }
        return false
    }
    
    
    public func refreshAccessToken(callbackFunction: ((NSError?) -> Void)?) {
        let headers = [
            "Authorization": "Basic \(authorizationCode)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters = [
            "grant_type":"refresh_token",
            "refresh_token":"\(oauthKeys!.refreshToken)"
        ]
        
        Alamofire.request(.POST, accessTokenUrl, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                
            var requestError : NSError?
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    self.saveOAuthKeys(JSON(value))
                }
            case .Failure(let error):
                requestError = error
            }
            // if callback function is provided, call it
            if let callback = callbackFunction {
                callback(requestError)
            }
        }
    }
    
    private func handleOAuthError(error : ErrorType) {
        
    }
    
    
    private func saveOAuthKeys(json : JSON) {
        let accessToken = json["access_token"].string!
        let refreshToken = json["refresh_token"].string!
        let expiresIn = json["expires_in"].int!
        let oauthKeys = FitbitOAuthKeys(accessToken: accessToken,
                                        refreshToken: refreshToken,
                                        expiresIn: expiresIn,
                                        dateCreated: NSDate())
        do {
            /// first, check if OAuth keys have already been stored, and delete old keys
            if Locksmith.loadDataForUserAccount(ACCOUNT, inService: SERVICE) != nil{
                try Locksmith.deleteDataForUserAccount(ACCOUNT, inService: SERVICE)
            }
            /// save new keys
            try oauthKeys.createInSecureStore()
        } catch {
            handleKeychainError(error)
        }
    }
    
    // TODO:
    private func handleKeychainError(error: ErrorType) {
    }
    
    // MARK: Helper methods
    private func escapedString(str : String) -> String {
        return str.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    private func convertToBase64(str : String) -> String {
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}

extension NSURLComponents {
    var queryItemDictionary: [String : String] {
        var results = [String: String]()
        if queryItems != nil {
            for queryItem in queryItems! {
                results[queryItem.name.lowercaseString] = queryItem.value
            }
        }
        return results
    }
    
    var code: String? {
        if let _code = queryItemDictionary["code"] {
            return _code
        }
        return nil
    }
}