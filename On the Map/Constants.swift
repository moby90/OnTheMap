//
//  Constants.swift
//  On the Map
//
//  Created by Moritz Nossek on 26.03.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import UIKit

// MARK: - Constants
struct Constants {
    
    
    static let ParseBaseURL = "https://api.parse.com/1/classes/StudentLocation"
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        // udacity
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        
        // parse
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let ObjectID = "objectID"
    }
    
    struct JSONResponseKeys {
        
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let Results = "results"
        
    }
    
    struct RequestToServer {
        static let udacity = "udacity"
        static let parse = "parse"
    }
    
    struct Methods {
        // get udacity session
        static let CreateSession = "session"
        // get public users data
        static let Users = "users/"
        // parse limit
        static let limit = ""
        
        static let httpPOST = "POST"
    }
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        static let LoginBlue = UIColor(red: 63/255, green: 116/255, blue: 167/255, alpha: 1.0)
    }
}

struct Student {
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let mapString = "mapString"
    static let mediaURL = "mediaURL"
    static let results = "results"
    static let objectID = "objectId"
    static let uniqueKey = "uniqueKey"
    
}

struct UdacityConstants {
    static let signUpURL = "https://www.udacity.com/account/auth#!/signup"
    static let baseURL = "https://www.udacity.com/api/"
    
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    static let MediaUrl = "mediaURL"
}

struct ParseConstants {
    static let parseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let parseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let jsonValue = "application/json"
    
    static let urlForGetRequest = "https://api.parse.com/1/classes/StudentLocation?limit=100"
    static let urlForPostRequest = "https://api.parse.com/1/classes/StudentLocation"
    
    struct QueryItems {
        static let limit = "limit"
        static let updatedAt = "updatedAt"
    }
    
    struct RequestValues {
        static let appId = "X-Parse-Application-Id"
        static let apiKey = "X-Parse-REST-API-Key"
        static let jsonValue = "Content-Type"
    }
    
    struct UrlComponents {
        static let scheme = "https"
        static let host = "api.parse.com"
        static let path = "/1/classes/StudentLocation"
    }
}