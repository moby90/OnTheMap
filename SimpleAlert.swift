//
//  SimpleAlert.swift
//  On the Map
//
//  Created by Moritz Nossek on 24.04.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showSimpleAlert(viewController: UIViewController, title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: {action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
        })
        alertView.addAction(alertAction)
        
        performUIUpdatesOnMain{
            viewController.presentViewController(alertView, animated: false, completion: nil)
        }
    }
}