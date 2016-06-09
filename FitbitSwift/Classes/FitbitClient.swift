//
//  File.swift
//  Pods
//
//  Created by Albert Jo on 5/13/16.
//
//
import Alamofire
import SwiftyJSON

public class FitbitClient {
    var authManager : FitbitAuthManager

    /// Shared instance for convenience
    public static var sharedClient : FitbitClient!
    
    // MARK: Initializer
    public init(authManager : FitbitAuthManager) {
        self.authManager = authManager
    }
    
    public func URLRequestWithMethod(method: Alamofire.Method,
                                        url : String,
                                        optionalHeaders : [String : String]?,
                                        parameters : [String : AnyObject]?,
                                        completionHandler : ((JSON?, NSError?) -> Void)? ) {
        
        FitbitRequest(authManager: authManager,
                                    method: method,
                                    url: url,
                                    optionalHeaders: nil,
                                    parameters: parameters,
                                    completionHandler: completionHandler).startRequest()
    }
}

public enum OAuth2Error: String {
    case invalid_request
    case unsupported_grant_type
    case invalid_grant
    case invalid_client
    case message
    case request
    case expired_token
    case invalid_token
    case insufficient_scope
    case insufficient_permissions
    case unknown
    
    public init(errorType: String) {
        switch(errorType) {
        case "invalid_request": self = .invalid_request
        case "unsupported_grant_type": self = .unsupported_grant_type
        case "invalid_grant": self = .invalid_grant
        case "invalid_client": self = .invalid_client
        case "message": self = .message
        case "request": self = .request
        case "expired_token": self = .expired_token
        case "invalid_token": self = .invalid_token
        case "insufficient_scope": self = .insufficient_scope
        case "insufficient_permissions": self = .insufficient_permissions
        default: self = .unknown
        }
    }
}


class FitbitRequest {
    var authManager: FitbitAuthManager
    var method : Alamofire.Method
    var url: String
    var headers: [String: String]
    var parameters: [String: AnyObject]?
    var completionHandler : ((JSON?, NSError?) -> Void)?
    
    var json : JSON?
    var error : NSError?

    init(authManager: FitbitAuthManager, method: Alamofire.Method, url: String, optionalHeaders: [String: String]?,
                            parameters: [String: AnyObject]?, completionHandler : ((JSON?, NSError?) -> Void)?) {
        self.authManager = authManager
        self.method = method
        self.url = url
        self.parameters = parameters
        self.completionHandler = completionHandler
        
        self.headers = authManager.authorizationHeader
        // if optionalHeaders are not nil, add them to headers dictionary
        if optionalHeaders != nil {
            for key in optionalHeaders!.keys {
                self.headers[key] = optionalHeaders![key]
            }
        }
    }
    
    func startRequest() {
        // temporary solution is to refresh token at every request attempt
        authManager.refreshAccessToken { (authError) in
            if authError != nil {
                self.json = nil
                self.error = authError
                self.callCompletionHandler()
            } else {
                Alamofire.request(self.method, self.url, parameters: self.parameters, headers: self.headers)
                    .validate()
                    .responseJSON { (response) in
                        
                        switch(response.result) {
                        case .Success:
                            if let value = response.result.value {
                                self.json = JSON(value)
                            }
                        case .Failure(let error):
                            self.error = error
                        }
                        self.callCompletionHandler()
                }
            }
        }
    }
    
    
    func callCompletionHandler() {
        if let handler = self.completionHandler {
            handler(self.json, self.error)
        }
    }
}