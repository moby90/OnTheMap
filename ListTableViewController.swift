//
//  ListTableViewController.swift
//  On the Map
//
//  Created by Moritz Nossek on 28.03.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    @IBOutlet var studentTableView: UITableView!
    
    var students: [StudentInformation] = ParseClient.sharedInstance().studentLocations
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.populateListTableView()
    }
    
    func populateListTableView() {
        ParseClient.sharedInstance().getStudentLocationsUsingCompletionHandler() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.students = ParseClient.sharedInstance().studentLocations
                    self.studentTableView.reloadData()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("nameCell")! as UITableViewCell
        let image: UIImage = UIImage(named: "pin")!
        cell.imageView!.image = image
        let student = students[indexPath.row]
        cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students[indexPath.row]
        
        guard let url = NSURL(string: student.mediaURL) else {
            print("Could not unwrap student.mediaURL")
            return
        }
        
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
}
