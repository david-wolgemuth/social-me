//
//  LoginViewController.swift
//  Social
//
//  Created by Shuhan Ng on 1/30/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import TextFieldEffects
import FontAwesome_swift
import LTMorphingLabel
import SwiftyButton
import SCLAlertView



class LoginViewController: UIViewController,UITextFieldDelegate,LTMorphingLabelDelegate{
    
    private var i = 0
    private var textArray = [
        "Welcome",
        "to Social ME",
        "An App that..",
        "connects you",
        "with your friends!"]
    
    @IBOutlet weak var passwordTextField: IsaoTextField!
    @IBOutlet weak var emailTextField: IsaoTextField!

    
    var timer = NSTimer()
    private var text:String {
        if i >= textArray.count {
            i = 0
        }
        return textArray[i++]
    }
    
    override func viewDidLoad() {
 
        passwordTextField.delegate = self
        emailTextField.delegate = self
        emailLabel.font = UIFont.fontAwesomeOfSize(20)
        emailLabel.text = String.fontAwesomeIconWithName(FontAwesome.EnvelopeO)
        passwordLabel.font = UIFont.fontAwesomeOfSize(20)
        passwordLabel.text = String.fontAwesomeIconWithName(FontAwesome.Lock)
        titleLabel.delegate = self
        titleLabel.morphingEffect = .Evaporate
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: Selector("changeText"), userInfo: nil,repeats:true)
        
        
        if let user = CoreDataManager.sharedInstance.get_user() {
             emailTextField.text = user.email
            if let password = CoreDataManager.sharedInstance.password() {
               passwordTextField.text = password
            }
        }
    }
  
    
    @IBOutlet weak var loginButton: SwiftyButton!
    @IBAction func loginButtonPressed(sender: SwiftyButton) {
        loginButton.enabled = false
        if let urlToReq = NSURL(string: "http://192.168.1.227:8000/users/login") {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            let bodyData = "email=\(emailTextField.text!)&password=\(passwordTextField.text!)"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) {
                (data,response,error) in
                let message = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if message == "wrong" {
                        let alert = SCLAlertView()
                        alert.showError("Error", subTitle: "Email/Password is wrong.")
                        self.loginButton.enabled = true
                        
                    } else {
                        CoreDataManager.sharedInstance.saveUser(message!, email: self.emailTextField.text!, password: self.passwordTextField.text!)
                        Connection.sharedInstance
                        self.performSegueWithIdentifier("finishLog", sender:nil)
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func changeText() {
    
        titleLabel.text = text
    }

    @IBOutlet weak var titleLabel: LTMorphingLabel!
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    @IBAction func unwindFromReg(segue: UIStoryboardSegue) {
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        loginButton.enabled = true
    }
}
