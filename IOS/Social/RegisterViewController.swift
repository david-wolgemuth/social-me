//
//  RegisterViewController.swift
//  Social
//
//  Created by Shuhan Ng on 1/30/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import RSKImageCropper
import TextFieldEffects
import SCLAlertView
import CoreData



class RegisterViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate{
    
  
  
    
    @IBOutlet weak var addPhotoButton: UIButton!
    let kPhotoDiameter:CGFloat = 130.0
    let kPhotoFrameViewPadding:CGFloat = 2

    @IBOutlet weak var confirmPasswordTextField: YoshikoTextField!
    @IBOutlet weak var passwordTextField: YoshikoTextField!
    @IBOutlet weak var usernameTextField: YoshikoTextField!
    @IBOutlet weak var emailTextField: YoshikoTextField!
    var imageChosen: UIImage?
    @IBOutlet weak var photoFrameView: UIView!
    
    
    override func viewDidLoad() {
        self.photoFrameView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        confirmPasswordTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        self.addPhotoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
 
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func addPhotoButtonPressed(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
 
    }
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@",emailRegEx)
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }
    
 
    @IBAction func submitFormButtonPressed(sender: UIBarButtonItem) {
        submitButton.enabled = false
        let alert = SCLAlertView()
        var ErrorStr = [String]()
        if !isValidEmail(emailTextField.text!) {
            ErrorStr.append("Email address is not valid ")
        }
        if usernameTextField.text == "" {
            ErrorStr.append("username cannot be empty ")
        }
        if passwordTextField.text?.characters.count < 6 {
            ErrorStr.append("password cannot be less than 6 characters ")
        }
        if confirmPasswordTextField.text != passwordTextField.text {
            ErrorStr.append("confirm password does not match password ")
        }
        self.view.endEditing(true)
        if ErrorStr.count > 0 {
            var errors = ""
            for error in ErrorStr {
                errors += error
            }
            alert.showError("Error",subTitle: "Please re-entered: \(errors)")
        } else {

            if let urlToReq = NSURL(string: "http://192.168.1.227:8000/users") {
                let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                
                let userData: NSMutableDictionary = ["email": emailTextField.text!, "username": usernameTextField.text!,"password": passwordTextField.text!,"image": ""]
                if let image = imageChosen {
                    let data = UIImageJPEGRepresentation(image, 0.1)
                    let imageData = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                    userData.setValue(imageData, forKey: "image")
                }
                var userJsonData: NSData?
                do {
                    userJsonData = try NSJSONSerialization.dataWithJSONObject(userData, options: NSJSONWritingOptions.PrettyPrinted)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue(NSString(format: "%lu", userJsonData!.length) as String, forHTTPHeaderField: "Content-Length")
                    request.HTTPBody = userJsonData!
                    let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                    let task = session.dataTaskWithRequest(request) {
                        (data, response ,error) in
                        let message = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        
 
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            if message == "error" {
                                alert.showError("Error", subTitle: "this email has been used, please use another one")
                                self.submitButton.enabled = true
                            } else {
                                CoreDataManager.sharedInstance.saveUser(message, email: self.emailTextField.text!, password: self.passwordTextField.text!)
                                
                                
                                
                              
                                alert.addButton("Log me in",target:self, selector:  Selector("logNewUserIn"))
                              
                                alert.showSuccess("Success!", subTitle: "You have successfully registered!")
                                self.submitButton.enabled = true

                            }
                        }
                    }
                    task.resume()
                } catch let error {
                    print("send http request FAILS! :::: \(error)")
                }
            }
        }
    }
    
    func logNewUserIn() {
        Connection.sharedInstance
        performSegueWithIdentifier("finishReg", sender: nil)
    }
    
  
    
  

        
    
    
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: { ()->Void in
            var imageCropVC: RSKImageCropViewController
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.Circle)
            imageCropVC.delegate = self
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
            
            })
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.addPhotoButton.setImage(croppedImage, forState: .Normal)
        imageChosen = croppedImage
        self.navigationController?.popViewControllerAnimated(true)
    }
  
    
    

}









