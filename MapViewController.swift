//
//  MapViewController.swift
//  On the Map
//
//  Created by Moritz Nossek on 28.03.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let parentVC = self.parentViewController else {
            return
        }
        
        guard let tabBarVC = parentVC.parentViewController else {
            return
        }
        
        tabBarVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(self.logout))
        
        let pinImage = UIImage(named: "pin")
        let pinButton = UIBarButtonItem(image: pinImage, style: .Plain, target: self, action: #selector(self.setNewPin))
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(self.reload))
        
        let rightBarButtonItems = [reloadButton, pinButton]
        
        tabBarVC.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: true)
        
        map.delegate = self
        map.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let annotations = map.selectedAnnotations
        for obj in annotations {
            map.deselectAnnotation(obj, animated: false)
        }
        reload();
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinView.pinTintColor = UIColor.redColor()
            pinView.canShowCallout = true
            
            // pin button
            let pinButton = UIButton(type:UIButtonType.InfoLight)
            pinButton.frame.size.width = 44
            pinButton.frame.size.height = 44
            
            pinView.rightCalloutAccessoryView = pinButton
            
            return pinView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else {
            return
        }
        UdacityClient.sharedInstance().openURL(annotation.subtitle!!)
    }
    
    @objc func logout()
    {
        print("Logout")
        UdacityClient.sharedInstance().logoutRequest { (result, error) -> Void in
            if error != nil {
                print("error on logout")
            }
            else {
                performUIUpdatesOnMain({
                    let loginView = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.presentViewController(loginView, animated: true, completion: nil)
                })
            }
        }
    }
    
    @objc func reload()
    {
        print("reload")
        UdacityClient.sharedInstance().getStudentLocations { users, error in
            if let usersData =  users {
                dispatch_async(dispatch_get_main_queue(), {
                    StudentInformation.sharedInstance.usersData = usersData
                    UdacityClient.sharedInstance().createAnnotations(usersData, mapView: self.map)
                })
            }
        }
    }
    
    @objc func setNewPin()
    {
        print("setNewPin")
        let postController:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("postView") as! UserPostViewController
        self.presentViewController(postController, animated: true, completion: nil)
    }
}
