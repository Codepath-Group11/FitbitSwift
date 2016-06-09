//
//  SwiftBit.swift
//  Pods
//
//  Created by Albert Jo on 5/12/16.
//
//
public class FitbitSwift {
    
    static var authManager : FitbitAuthManager?
    
    public static func setUp(clientID: String,
                             clientSecret: String,
                             redirectUrl: String,
                             scope : [FitbitScope]?) {
        precondition(authManager == nil, "Only call 'SwiftBit.setUp' once")
        authManager = FitbitAuthManager(clientID: clientID, clientSecret: clientSecret, redirectUrl: redirectUrl, scope: scope)
        FitbitClient.sharedClient = FitbitClient(authManager: authManager!)
    }
    
    public static func isLoggedIn() -> Bool {
        return (authManager?.isAuthenticated())!
    }
    
    public static func logIn(completionHandler: (NSError? -> Void)?) {
        precondition(authManager != nil, "You must call 'SwiftBit.setUp' first")
        //precondition(!isLoggedIn(), "Only call SwiftBit.logIn once")
        authManager?.OAuthTokenCompletionHandler = completionHandler
        authManager?.beginOAuthRequest()
    }
    
    public static func logOut() {
        precondition(authManager != nil, "You must call 'SwiftBit.setUp' first")
        precondition(isLoggedIn(), "You are not logged in to Fitbit")
        authManager?.deleteOAuthToken()
    }
    
    public static func handleRedirectUrl(url : NSURL) {
        authManager?.processOAuthResponse(url)
    }
    
    public static func client() -> FitbitClient {
        precondition(authManager != nil, "You must call 'SwiftBit.setUp' first")
        precondition(isLoggedIn(), "You are not logged in to Fitbit")
        return FitbitClient.sharedClient
    }
}