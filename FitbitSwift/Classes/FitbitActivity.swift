//
//  FitbitActivities.swift
//  FitFilter
//
//  Created by Albert Jo on 2/25/16.
//  Copyright © 2016 FitFilter. All rights reserved.
//
import SwiftyJSON

/// Constants
let FEET_IN_MILE : Float = 5280
let METERS_IN_MILE : Float = 1609.34
let KM_IN_MILE : Float = 1.609344

public class FitbitActivity {
    public var inMetric : Bool = false
    
    public private(set) var json : JSON?
    public private(set) var activityId : String?
    public private(set) var activityParentId : String?
    public private(set) var name : String?
    public private(set) var description : String?
    public private(set) var calories : Float?
    public private(set) var distance : Float?       // in Miles
    public private(set) var duration : Float?       // in Seconds
    public private(set) var hasStartTime = false
    public private(set) var isFavorite = false
    public private(set) var logId : String?
    public private(set) var steps : Int?       // in Seconds
    public private(set) var startTime : String?
    
    public var durationInSeconds : Float? {
        if (self.duration == nil) {
            return nil
        }
        return self.duration!/1000.0
    }
    
    public var durationInMinutes : Float? {
        if (duration == nil) {
            return nil
        }
        return durationInSeconds!/60.0
    }
    
    public var distanceKilometers : Float? {
        if (self.distance == nil) {
            return nil
        }
        return self.distance! * KM_IN_MILE
    }
    
    public var availableInformation : [String : Float] {
        var availableInformation : [String : Float] = [String : Float]()
        availableInformation["calories"] = self.calories
        
        if (self.inMetric) {
            availableInformation["distance"] = self.distanceKilometers
            availableInformation["pace"] = kilometerPace()
        } else {
            availableInformation["distance"] = self.distance
            availableInformation["pace"] = milePace()
        }
        return availableInformation
    }
    
    public required init(json : JSON) {
        self.json = json
        self.activityId = json["activityId"].string
        self.name = json["name"].string
        self.description = json["description"].string
        self.calories = json["calories"].float
        self.distance = json["distance"].float
        self.duration = json["duration"].float
    }
    
    // MARK: - getters
    
    public func milePace() -> Float? {
        if self.distance == nil || self.duration == nil || self.duration! == 0 {
            return nil
        }
        return self.durationInMinutes!/self.distance!
    }
    
    public func kilometerPace() -> Float? {
        if self.distance == nil || self.duration == nil || self.duration! == 0 {
            return nil
        }
        return self.durationInMinutes!/self.distanceKilometers!
    }
    
    public func getMinutesSecondsString() -> String? {
        if duration == nil {
            return nil
        }
        let minutes : Int = Int(self.duration!/60)
        let seconds : Int = Int(self.duration!) % 60
        if (seconds > 9) {
            return "\(minutes):\(seconds)"
        }
        return "\(minutes):0\(seconds)"
    }
}

extension FitbitClient {
    
    public func getRecentActivities(completionHandler: (Array<FitbitActivity>, NSError?) -> Void) {
        let url = "https://api.fitbit.com/1/user/-/activities/recent.json"
        getActivitiesHelper(url, completionHandler: completionHandler)
    }
    
    public func getFrequentActivities(completionHandler: (Array<FitbitActivity>, NSError?) -> Void) {
        let url = "https://api.fitbit.com/1/user/-/activities/frequent.json"
        getActivitiesHelper(url, completionHandler: completionHandler)
    }
    
    private func getActivitiesHelper(url: String, completionHandler: (Array<FitbitActivity>, NSError?) -> Void) {
        FitbitClient.sharedClient.URLRequestWithMethod(.GET, url: url, optionalHeaders: nil, parameters: nil) {
            (json, error) in
            var activities = Array<FitbitActivity>()
            if (error == nil) {
                if let _json = json {
                    for (_,subJson):(String, JSON) in _json {
                        activities.append(FitbitActivity(json: subJson))
                    }
                }
            }
            completionHandler(activities, error)
        }
    }

}


