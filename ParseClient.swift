//
//  ParseClient.swift
//  On the Map
//
//  Created by Moritz Nossek on 03.04.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    
    
    var session: NSURLSession
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    var studentLocations: [StudentInformation] = []
    
    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }
    
    func dateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        return dateFormatter.stringFromDate(date)
    }
    
    //"https://api.parse.com/1/classes/StudentLocation?limit=100"
    func getParseURL(date: NSDate) -> NSURL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.parse.com"
        urlComponents.path = "/1/classes/StudentLocation"
        
        let limitQuery = NSURLQueryItem(name: "limit", value: "100")
        let updatedAtQuery = NSURLQueryItem(name: "updatedAt", value: dateToString(date))
        
        urlComponents.queryItems = [limitQuery, updatedAtQuery]
        
        return urlComponents.URL
    }
    
    // MARK: - Parse API Call Functions
    
    // retrieve last 100 students and add them to the studentLocations array
    func getStudentLocationsUsingCompletionHandler(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: self.getParseURL(NSDate())!)
        request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.parseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                print(error)
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
                return
            }
            
            guard let data = data else {
                    return
            }
            
            let topLevelDict = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            
            let studentsArray = topLevelDict["results"] as! NSArray
                self.studentLocations = []
                for studentDictionary in studentsArray {
                    guard let student = self.studentLocationFromDictionary(studentDictionary as! NSDictionary) else{
                        return
                    }
                    self.studentLocations.append(student)
            }
            
            completionHandler(success: true, errorString: nil)
        }
        
        task.resume()
    }
    
    // post the logged-in user's location
    func postStudentLocation(uniqueID: String, firstName: String, lastName: String, mediaURL: String, locationString: String, locationLatitude: String, locationLongitude: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: ParseConstants.urlForPostRequest)!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.parseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueID)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(locationString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(locationLatitude), \"longitude\": \(locationLongitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode else {
                print("Could not get statusCode.")
                return
            }
            
            if !(statusCode >= 200 && statusCode <= 299){
                print("Bad statusCode.")
                
                var message = ""
                
                if (statusCode >= 100 && statusCode <= 199) {
                    
                    message = "The processing of the inquiry is still ongoing"
                }
                
                if (statusCode >= 300 && statusCode <= 399) {
                    
                    message = "You have been redirected. Try to login again."
                }
                
                if (statusCode >= 400 && statusCode <= 499) {
                    
                    message = "Bad credentials. Try again."
                }
                
                completionHandler(success: false, errorString: message)
                return
            }
            
            guard let data = data else {
                return
            }
            
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            
            guard (parsedResult["createdAt"] == nil) else {
                completionHandler(success: false, errorString: "An unknown error occurred")
                return
            }
            completionHandler(success: true, errorString: nil)
            
        }
        task.resume()
    }
    
    // convenience method for converting JSON into a Student object
    func studentLocationFromDictionary(studentDictionary: NSDictionary) -> StudentInformation? {
        let studentFirstName = studentDictionary["firstName"] as! String
        let studentLastName = studentDictionary["lastName"] as! String
        let studentLongitude = studentDictionary["longitude"] as! Float!
        let studentLatitude = studentDictionary["latitude"] as! Float!
        let studentMediaURL = studentDictionary["mediaURL"] as! String
        let studentMapString = studentDictionary["mapString"] as! String
        let studentObjectID = studentDictionary["objectId"] as! String
        let studentUniqueKey = studentDictionary["uniqueKey"] as! String
        let initializerDictionary = ["firstName": studentFirstName, "lastName": studentLastName, "longitude": studentLongitude, "latitude": studentLatitude, "mediaURL": studentMediaURL, "mapString": studentMapString, "objectID": studentObjectID, "uniqueKey": studentUniqueKey]
        return StudentInformation(dict: initializerDictionary as! [String:AnyObject])
    }
    
    // MARK: - Shared Instance
    
    // make this class a singleton to share across classes
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}