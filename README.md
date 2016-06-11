# FitbitSwift

[![CI Status](http://img.shields.io/travis/Namhyun Jo/FitbitSwift.svg?style=flat)](https://travis-ci.org/Namhyun Jo/FitbitSwift)
[![Version](https://img.shields.io/cocoapods/v/FitbitSwift.svg?style=flat)](http://cocoapods.org/pods/FitbitSwift)
[![License](https://img.shields.io/cocoapods/l/FitbitSwift.svg?style=flat)](http://cocoapods.org/pods/FitbitSwift)
[![Platform](https://img.shields.io/cocoapods/p/FitbitSwift.svg?style=flat)](http://cocoapods.org/pods/FitbitSwift)

## About
FitbitSwift is an API wrapper for Fitbit written in Swift 2 and uses Alamofire, Locksmith, and SwiftyJSON. FitbitSwift provides OAuth2.0 authorization and manages refreshing and revoking access tokens.

## How to Use
Register your application on Fitbit. Remember to provide a callback url for your application and add a url scheme for your app.
![myimage-alt-tag](http://i.imgur.com/txNO2E2.png)

Add the following code to your app delegate.
```Swift
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if (url.host == "YOUR_CALL_BACK") {
            FitbitSwift.handleRedirectUrl(url)
        }
        return true
    }
    
```

This is an example to retrieve an array of recent activities.
```Swift
let clientID = "CLIENT_ID"
let clientSecret = "CLIENT_SECRET"
let redirectUrl = "SwiftBitExample://oauth-callback"

// you must call setUp before attempting to log in or use the shared client
FitbitSwift.setUp(clientID, clientSecret: clientSecret, redirectUrl: redirectUrl, scope: nil)
FitbitSwift.logIn { (error) in
  if (error == nil) {
    FitbitSwift.client().getRecentActivities({ (array, _error) in
      print(array)
    })
  }
}
```

To create a custom authenticated request, you can do the following:
```Swift
// GET
FitbitSwift.client().URLRequestWithMethod(.GET, url: url, optionalHeaders: optionalHeaders, parameters: parameters) {
  (json, error) in
  if (error == nil) {
    print(json)
}

// POST
FitbitSwift.client().URLRequestWithMethod(.POST, url: url, optionalHeaders: optionalHeaders, parameters: parameters) {
  (json, error) in
  if (error == nil) {
    print(json)
}
```

To logout, simply call
```Swift
FitbitSwift.logOut()
```

## Installation
```ruby
pod "FitbitSwift"
```


## Author

Albert Jo

## License

FitbitSwift is available under the MIT license. See the LICENSE file for more info.

