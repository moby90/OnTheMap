//
//  ViewController.swift
//  On the Map
//
//  Created by Moritz Nossek on 26.03.16.
//  Copyright © 2016 moritz nossek. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var mKeyboardHeight: CGFloat = 0.0
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    @IBAction func signUpPressed(sender: UIButton) {
        // set url
        let signUpURL = "https://www.udacity.com/account/auth#!/signup"
        // open url in browser
        UIApplication.sharedApplication().openURL(NSURL(string: signUpURL)!)
    }
    
    @IBAction func loginFacebookPressed(sender: UIButton) {
        //TODO implement facebook login!
        //Currently for debugging
        self.goToNextView()
        //Only debugging purpose
    }

    @IBAction func loginPressed(sender: UIButton) {
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
                setUIEnabled(false)
            
        }
        userLogin()
    }
    
    private func userLogin() {
        
        guard let email = usernameTextField.text else {
            print("Unable to read email address")
            return
        }
        
        guard let password = passwordTextField.text else {
            print("Unable to read password.")
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacityBaseURL + Constants.Methods.CreateSession)!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = UdacityClient.sharedInstance().session.dataTaskWithRequest(request) { data, response, error in
            
            func displayError(error: String, debugLabelText: String? = nil) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = debugLabelText
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)", debugLabelText: "Could not connect to the internet.")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode != 403 else {
                displayError("There was an statusCode issue. \(response)", debugLabelText: "Username or Password wrong.")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            self.completeLogin()
            
            
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let sessionConfig: NSURLSessionConfiguration = appDelegate.sharedSession.configuration
        sessionConfig.timeoutIntervalForRequest = 1.0;
        sessionConfig.timeoutIntervalForResource = 1.0;
        configureUI()
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            self.goToNextView()
        }
    }
    
    private func goToNextView() {
        let nc = self.storyboard!.instantiateViewControllerWithIdentifier("rootNavigationController") as! UINavigationController
        self.presentViewController(nc, animated: true, completion: nil)
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            mKeyboardHeight = keyboardHeight(notification)
            view.frame.origin.y -= mKeyboardHeight
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += mKeyboardHeight
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

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

