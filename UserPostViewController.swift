//
//  UserPostViewController.swift
//  On the Map
//
//  Created by Moritz Nossek on 28.03.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import UIKit

class UserPostViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet var showOnTheMapSubView: UIView!
    @IBOutlet weak var linkView: UIView!
    
    var keyboardOnScreen = false
    var mKeyboardHeight: CGFloat = 0.0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setOnTheMapSubView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationTextField(locationTextField)
        configureLinkTextField(linkTextField)
    }
    
    func setOnTheMapSubView() {
        subscribeToKeyboardNotifications()
        linkView.hidden = true
        showOnTheMapSubView.hidden = false
    }
    
    func setLinkSubView() {
        unsubscribeToKeyboardNotifications()
        linkView.hidden = false
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
    }
    
    
}

extension UserPostViewController: UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserPostViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserPostViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            mKeyboardHeight = keyboardHeight(notification)
            view.frame.origin.y -= mKeyboardHeight
            keyboardOnScreen = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += mKeyboardHeight
            keyboardOnScreen = false
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}
