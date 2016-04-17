//
//  UserPostViewController.swift
//  On the Map
//
//  Created by Moritz Nossek on 28.03.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import UIKit
import MapKit

class UserPostViewController: UIViewController {
    
    var firstName: String = UdacityClient.sharedInstance().userFirstName
    var lastName: String = UdacityClient.sharedInstance().userLastName
    var uniqueID: String = UdacityClient.sharedInstance().uniqueID
    
    var mapString: String = ""
    var locationLatitude: Double = 0
    var locationLongitude: Double = 0
    var mediaURL: String = ""
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet var showOnTheMapSubView: UIView!
    @IBOutlet weak var linkSubView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var keyboardOnScreen = false
    var mKeyboardHeight: CGFloat = 0.0
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        setOnTheMapSubView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationTextField(locationTextField)
        configureLinkTextField(linkTextField)
    }
    
    func setOnTheMapSubView() {
        linkSubView.hidden = true
        showOnTheMapSubView.hidden = false
    }
    
    func setLinkSubView() {
        linkSubView.hidden = false
        showOnTheMapSubView.hidden = true
    }
    
    private func configureLocationTextField(textField: UITextField) {
        textField.delegate = self
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.textColor = Constants.UI.LoginBlue
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: Constants.UI.LoginBlue])
    }
    
    private func configureLinkTextField(textField: UITextField) {
        textField.delegate = self
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.textColor = UIColor.whiteColor()
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: UIButton) {
        if locationTextField.text!.isEmpty {
            // show an alert if the UITextField doesn't have a value
            let emptyStringAlert = UIAlertController(title: "Please enter your location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            emptyStringAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyStringAlert, animated: true, completion: nil)
            return
        } else {
            // set locationString class variable
            // call function to geocode the locationString
            // transition from first subview group to second subview group
            mapString = locationTextField.text!
            getLatitudeAndLongitudeFromString(mapString)
        }
    }
    
    func getLatitudeAndLongitudeFromString(location: String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.startAnimating()
        })
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error: NSError?) in
            if let placemark = placemarks?[0] {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                let locationCoordinate = placemark.location!.coordinate as CLLocationCoordinate2D
                self.setMapViewRegionAndScale(locationCoordinate)
                self.setLinkSubView()
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let errorAlert = UIAlertController(title: "Couldn't geocode your location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    func setMapViewRegionAndScale(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.13, 0.13)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        locationLatitude = location.latitude
        locationLongitude = location.longitude
    }
    
    @IBAction func submit(sender: UIButton) {
        if linkTextField.text!.isEmpty {
            let emptyStringAlert = UIAlertController(title: "Please enter a link to share", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            emptyStringAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyStringAlert, animated: true, completion: nil)
            return
        } else {
            mediaURL = linkTextField.text!
            ParseClient.sharedInstance().postStudentLocation(uniqueID, firstName: firstName, lastName: lastName, mediaURL: mediaURL, mapString: mapString, locationLatitude: locationLatitude, locationLongitude: locationLongitude) { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
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
    }
    
}

extension UserPostViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
