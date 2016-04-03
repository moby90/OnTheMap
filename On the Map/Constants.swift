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
    static let parseAppId: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let parseApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static let UdacityBaseURL: String = "https://www.udacity.com/api/"
    static let ParseBaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
    
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
    
    struct RequestToServer {
        static let udacity : String = "udacity"
        static let parse : String = "parse"
    }
    
    struct Methods {
        // get udacity session
        static let CreateSession : String = "session"
        // get public users data
        static let Users : String = "users/"
        // parse limit
        static let limit : String = ""
    }
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
}

struct UdacityConstants {
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    static let MediaUrl = "mediaURL"
}

struct ParseConstants {
    static let urlForGetRequest = "https://api.parse.com/1/classes/StudentLocation?limit=100"
    static let urlForPostRequest = "https://api.parse.com/1/classes/StudentLocation"
}