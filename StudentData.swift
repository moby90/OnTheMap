//
//  StudentData.swift
//  On the Map
//
//  Created by Moritz Nossek on 30.04.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import Foundation

class StudentData : AnyObject {
    
    var usersData : [StudentInformation] = [StudentInformation]()
    

    // MARK: - Shared Instance
    // make this class a singleton to share across classes
    class func sharedInstance() -> StudentData {
        
        struct Singleton {
            static var sharedInstance = StudentData()
        }
        
        return Singleton.sharedInstance
    }
}
