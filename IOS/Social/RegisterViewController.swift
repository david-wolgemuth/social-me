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



class RegisterViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,ConnectionRegisterDelegate,ConnectionLoginDelegate{
    
  
  
    
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
        
        Connection.sharedInstance.loginDelegate = self
        Connection.sharedInstance.RegisterDelegate = self
        
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
            submitButton.enabled = true
        } else {
            Connection.sharedInstance.register(emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!, profilePic: imageChosen)
        }
    }
    
    func logNewUserIn() {
        Connection.sharedInstance.login(emailTextField.text!, password: passwordTextField.text!)
       
    }
    
    func didLogin(success: Bool) {
        if success == true {
            performSegueWithIdentifier("finishReg", sender: nil)
        } else {
            let alert = SCLAlertView()
            alert.showError("Error",subTitle: "Email/Password is wrong.")
        }
    }
    
    
  
    func didRegister(success: Bool) {
        let alert = SCLAlertView()
        if success == true {
            alert.addButton("Log me in",target:self, selector:  Selector("logNewUserIn"))
            alert.showSuccess("Success!", subTitle: "You have successfully registered!")
           
        } else {
            alert.showError("Error", subTitle: "Sorry, we could not get you registered. Makesure email and username have not been used before")
        }
        self.submitButton.enabled = true
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









