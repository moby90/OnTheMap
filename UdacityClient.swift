//
//  UdacityClient.swift
//  On the Map
//
//  Created by Moritz Nossek on 03.04.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UdacityClient : NSObject {
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func openURL(urlString: String) {
        guard let url = NSURL(string: urlString) else {
            return
        }
        UIApplication.sharedApplication().openURL(url)
    }
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func logoutRequest(completionHandler: (result: AnyObject?, error: NSError?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacityBaseURL + Constants.Methods.CreateSession)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        
        guard let sharedCookieStorageCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies else {
            return
        }
        
        for cookie in sharedCookieStorageCookies {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            
            guard let data = data else {
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))/* subset response data! */
            completionHandler(result: newData, error: nil)
        }
        task.resume()
    }
    
    func taskForGETMethod(server: String, method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Set server base url */
        var baseUrl : String = ""
        if (server == Constants.RequestToServer.udacity) {
            baseUrl = Constants.UdacityBaseURL
        } else if (server == Constants.RequestToServer.parse) {
            baseUrl = Constants.ParseBaseURL
        }
        
        /* Build the URL and configure the request */
        let urlString = baseUrl + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if (server == Constants.RequestToServer.parse) {
            request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.parseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
            } else {
                
                var newData: NSData?
                newData = nil
                guard let data = data else {
                    return
                }
                
                if (server == Constants.RequestToServer.udacity) {
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                if newData != nil {
                    UdacityClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
                }
                else {
                    UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                }
            }
        }
        return task
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        do {
        let parsedResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        
            completionHandler(result: parsedResult, error: nil)
            
        } catch let JSONError as NSError{
            completionHandler(result: nil, error: JSONError)
        }
    }
    
    func getStudentLocations(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        // make the request
        let task = taskForGETMethod(Constants.RequestToServer.parse, method: Constants.Methods.limit, parameters: ["limit":200]) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let locations = result as? [NSObject: NSObject] {
                    if let usersResult = locations["results"] as? [[String : AnyObject]] {
                        let studentsData = StudentInformation.convertFromDictionaries(usersResult)
                        completionHandler(result: studentsData, error: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func createAnnotations(users: [StudentInformation], mapView: MKMapView) {
        for user in users {
            // set pin location
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2DMake(user.latitude, user.longitude)
            annotation.title = "\(user.firstName) \(user.lastName)"
            annotation.subtitle = user.mediaURL
            
            mapView.addAnnotation(annotation)
        }
    }
}

