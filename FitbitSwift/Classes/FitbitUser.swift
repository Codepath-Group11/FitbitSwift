//
//  FitbitUser.swift
//  FitFilter
//
//  Created by Albert Jo on 2/5/16.
//  Copyright © 2016 FitFilter. All rights reserved.
//

import SwiftyJSON

public enum Gender : String {
    case Female, Male, Na
    
    public init(gender: String) {
        switch(gender) {
        case "FEMALE": self = .Female
        case "MALE": self = .Male
        default: self = .Na
        }
    }
}

public enum WeightUnit {
    case Pounds, Metric
}

public class FitbitUser {
    
    // MARK : Properties
    public private(set) var json : JSON?
    public private(set) var aboutMe : String?
    public private(set) var avatar : String?
    public private(set) var avatar150 : String?
    public private(set) var city : String?
    public private(set) var country : String?
    public private(set) var dateOfBirth : String?
    public private(set) var displayName : String?
    public private(set) var distanceUnit : String?
    public private(set) var encodedId : String?
    public private(set) var foodsLocale : String?
    public private(set) var fullName : String?
    public private(set) var gender : Gender
    public private(set) var glucoseUnit : String?
    public private(set) var height : Float?
    public private(set) var heightUnit : String?
    public private(set) var locale : String?
    public private(set) var memberSince : String?
    public private(set) var nickname : String?
    public private(set) var offsetFromUTCMillis : String?
    public private(set) var startDayOfWeek : String?
    public private(set) var state : String?
    public private(set) var strideLengthRunning : String?
    public private(set) var strideLengthWalking : String?
    public private(set) var timezone : String?
    public private(set) var waterUnit : String?
    public private(set) var weight : Float?
    public private(set) var weightUnit : String?
    
    public required init(json : JSON) {
        self.json = json
        self.aboutMe = json["aboutMe"].string
        self.avatar = json["avatar"].string
        self.avatar150 = json["avatar150"].string
        self.city = json["city"].string
        self.country = json["country"].string
        self.dateOfBirth = json["dateOfBirth"].string
        self.displayName = json["displayName"].string
        self.distanceUnit = json["distanceUnit"].string
        self.encodedId = json["encodedId"].string
        self.foodsLocale = json["foodsLocale"].string
        self.fullName = json["fullName"].string
        self.gender = Gender(gender: json["gender"].string!)
        self.glucoseUnit = json["glucoseUnit"].string
        self.height = json["height"].float
        self.heightUnit = json["heightUnit"].string
        self.locale = json["locale"].string
        self.memberSince = json["memberSince"].string
        self.nickname = json["nickname"].string
        self.offsetFromUTCMillis = json["offsetFromUTCMillis"].string
        self.startDayOfWeek = json["startDayOfWeek"].string
        self.state = json["state"].string
        self.strideLengthRunning = json["strideLengthRunning"].string
        self.strideLengthWalking = json["strideLengthWalking"].string
        self.timezone = json["timezone"].string
        self.waterUnit = json["waterUnit"].string
        self.weight = json["weight"].float
        self.weightUnit = json["weightUnit"].string
    }
}

extension FitbitClient {
    public func getCurrentUser(completionHandler: (FitbitUser?, NSError?) -> Void ) {
        getUser("-", completionHandler: completionHandler)
    }
    
    public func getUser(userId : String, completionHandler: (FitbitUser?, NSError?) -> Void ) {
        let url = "https://api.fitbit.com/1/user/\(userId)/profile.json"
        FitbitClient.sharedClient.URLRequestWithMethod(.GET, url: url, optionalHeaders: nil, parameters: nil) {
            (json, error) in
            
            var user : FitbitUser?
            if (error == nil) {
                user = FitbitUser(json: json!)
            }
            completionHandler(user, error)
        }
    }
}

