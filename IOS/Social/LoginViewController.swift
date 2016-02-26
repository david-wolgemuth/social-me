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
import KeychainSwift



class LoginViewController: UIViewController,UITextFieldDelegate,LTMorphingLabelDelegate,ConnectionLoginDelegate{
    
    private var i = 0
    private var textArray = [
        "Social-ME",
        "- A Cross-platform",
        "Messenger App 🗣"]
    
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
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let keychain = KeychainSwift()
        
        if let user = prefs.stringForKey("user"){
             emailTextField.text = user
            print(keychain.get("password"))
            if let password = keychain.get("password") {
               passwordTextField.text = password
            }
        }
    }
  
    
    @IBOutlet weak var loginButton: SwiftyButton!
    @IBAction func loginButtonPressed(sender: SwiftyButton) {
        
        loginButton.enabled = false
        Connection.sharedInstance.loginDelegate = self
        Connection.sharedInstance.login(emailTextField.text!,password: passwordTextField.text!)
    }
    
    
    func didLogin(success: Bool) {
        if success == true {
            self.performSegueWithIdentifier("finishLog", sender: nil)
            
        } else {
            let alert = SCLAlertView()
            alert.showError("Error",subTitle: "Email/Password is wrong.")
            loginButton.enabled = true
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
