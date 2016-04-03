//
//  StudentInformation.swift
//  On the Map
//
//  Created by Moritz Nossek on 02.04.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    var firstName = ""
    var lastName = ""
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    var mediaURL = ""
    var studentID = ""
    var mapString: String
    var uniqueKey: String
    
    init(dict : [String : AnyObject]) {
        firstName = dict[Constants.JSONBodyKeys.FirstName] as! String
        lastName = dict[Constants.JSONBodyKeys.LastName] as! String
        latitude = dict[Constants.JSONBodyKeys.Latitude] as! CLLocationDegrees
        longitude = dict[Constants.JSONBodyKeys.Longitude] as! CLLocationDegrees
        mediaURL = dict[Constants.JSONBodyKeys.MediaURL] as! String
        mapString = dict[Constants.JSONBodyKeys.MapString] as! String!
        uniqueKey = dict[Constants.JSONBodyKeys.UniqueKey] as! String!
    }
    
    /* Convert an array of dictionaries to an array of student information struct objects */
    static func convertFromDictionaries(array: [[String : AnyObject]]) -> [StudentInformation] {
        var resultArray = [StudentInformation]()
        
        for dictionary in array {
            resultArray.append(StudentInformation(dict: dictionary))
        }
        
        return resultArray
    }
}
