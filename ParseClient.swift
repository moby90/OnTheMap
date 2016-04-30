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
    
    func getParseURL(date: NSDate) -> NSURL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = ParseConstants.UrlComponents.scheme
        urlComponents.host = ParseConstants.UrlComponents.host
        urlComponents.path = ParseConstants.UrlComponents.path
        
        let limitQuery = NSURLQueryItem(name: ParseConstants.QueryItems.limit, value: "100")
        let updatedAtQuery = NSURLQueryItem(name: ParseConstants.QueryItems.updatedAt, value: dateToString(date))
        
        urlComponents.queryItems = [limitQuery, updatedAtQuery]
        
        return urlComponents.URL
    }
    
    // MARK: - Parse API Call Functions
    
    // retrieve last 100 students and add them to the studentLocations array
    func getStudentLocationsUsingCompletionHandler(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: self.getParseURL(NSDate())!)
        request.addValue(ParseConstants.parseAppId, forHTTPHeaderField: ParseConstants.RequestValues.appId)
        request.addValue(ParseConstants.parseApiKey, forHTTPHeaderField: ParseConstants.RequestValues.apiKey)
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
            
                for studentDictionary in studentsArray {
                    guard let student = self.studentLocationFromDictionary(studentDictionary as! NSDictionary) else{
                        return
                    }
                    StudentData.sharedInstance().usersData.append(student)
            }
            
            completionHandler(success: true, errorString: nil)
        }
        
        task.resume()
    }
    
    // post the logged-in user's location
    func postStudentLocation(uniqueID: String, firstName: String, lastName: String, mediaURL: String, mapString: String, locationLatitude: Double, locationLongitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let jsonBodyParameters: [String: AnyObject] = [
            Constants.JSONBodyKeys.UniqueKey :UdacityClient.sharedInstance().uniqueID,
            Constants.JSONBodyKeys.FirstName : UdacityClient.sharedInstance().userFirstName,
            Constants.JSONBodyKeys.LastName : UdacityClient.sharedInstance().userLastName,
            Constants.JSONBodyKeys.MediaURL : mediaURL,
            Constants.JSONBodyKeys.MapString : mapString,
            Constants.JSONBodyKeys.Latitude : locationLatitude,
            Constants.JSONBodyKeys.Longitude : locationLongitude
        ]
        
        taskForPOSTMethod(jsonBodyParameters, completionHandler: { parsedResult, error in
            
            guard error == nil else {
                print("error in taskForPOSTMethod")
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
            
            guard let parsedData = parsedResult[Constants.JSONResponseKeys.CreatedAt] as? String else {
                completionHandler(success: false, errorString: " Could not find key : \(Constants.JSONResponseKeys.CreatedAt) in parsedResult, method : addStudentLocation/taskForPOSTMethod ")
                return
            }
            completionHandler(success: true, errorString: nil)
            
        })
    }
    
    func taskForPOSTMethod(jsonBodyParameters: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?)->Void) -> NSURLSessionTask {
        
        /* 1. Set the parameters */
        
        /* 2. Build the URL */
        let urlString = ParseConstants.urlForPostRequest
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = Constants.Methods.httpPOST
        request.addValue(ParseConstants.parseAppId, forHTTPHeaderField: ParseConstants.RequestValues.appId)
        request.addValue(ParseConstants.parseApiKey, forHTTPHeaderField: ParseConstants.RequestValues.apiKey)
        request.addValue(ParseConstants.jsonValue, forHTTPHeaderField: ParseConstants.RequestValues.jsonValue)
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBodyParameters, options: .PrettyPrinted)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* 5/6. Parse the data and use the data (happens in the completion handler) */
            if let error = error {
                print(error.localizedDescription)
                completionHandler(result: nil, error: error)
                
            } else {
                self.parseDataWithJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        /* 7. Start the request */
        task.resume()
        return task
        
    }
    
    func parseDataWithJSONWithCompletionHandler (data: NSData!, completionHandler: (result: AnyObject!, error: NSError?)-> Void ) {
        do {
            let parsedData: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            
            completionHandler(result: parsedData, error: nil)
        }
        catch let JSONError as NSError{
            completionHandler(result: nil, error: JSONError)
        }
    }
    
    // convenience method for converting JSON into a Student object
    func studentLocationFromDictionary(studentDictionary: NSDictionary) -> StudentInformation? {
        let studentFirstName = studentDictionary[Student.firstName] as! String
        let studentLastName = studentDictionary[Student.lastName] as! String
        let studentLongitude = studentDictionary[Student.longitude] as! Float!
        let studentLatitude = studentDictionary[Student.latitude] as! Float!
        let studentMediaURL = studentDictionary[Student.mediaURL] as! String
        let studentMapString = studentDictionary[Student.mapString] as! String
        let studentObjectID = studentDictionary[Student.objectID] as! String
        let studentUniqueKey = studentDictionary[Student.uniqueKey] as! String
        let initializerDictionary = [Student.firstName: studentFirstName, Student.lastName: studentLastName, Student.longitude: studentLongitude, Student.latitude: studentLatitude, Student.mediaURL: studentMediaURL, Student.mapString: studentMapString, Student.objectID: studentObjectID, Student.uniqueKey: studentUniqueKey]
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