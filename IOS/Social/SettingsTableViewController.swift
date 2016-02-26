//
//  SettingsTableViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/21/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView
import CSNotificationView
import AVFoundation
import RSKImageCropper


class SettingsTableViewController: UITableViewController,ConnectionSocketDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,ConnectionImageDelegate{
    @IBOutlet weak var userLabel: UILabel!
    let kPhotoDiameter:CGFloat = 100.0
    let kPhotoFrameViewPadding:CGFloat = 2
    
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var audioPlayer: AVAudioPlayer?
    
    
    var image: UIImage?
    @IBAction func saveButtonClicked(sender: UIButton) {
        if let image = self.image {
            Connection.sharedInstance.uploadImage(image)
            
        }
        
    }
    @IBAction func chooseImageButtonClicked(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        picker.dismissViewControllerAnimated(true, completion: { ()->Void in
            var imageCropVC: RSKImageCropViewController
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.Circle)
            imageCropVC.delegate = self
            self.navigationController?.presentViewController(imageCropVC, animated: true, completion: nil)

            
        })
        
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)

        
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        userProfileImageView.image = croppedImage
        self.image = croppedImage
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)

    }

    
    override func viewDidLoad() {
        userLabel.font = UIFont.fontAwesomeOfSize(20)
        userLabel.text = String.fontAwesomeIconWithName(.User)
        userName.text = NSUserDefaults.standardUserDefaults().stringForKey("user")
        Connection.sharedInstance.imageDelegate = self
        
        
        if NSUserDefaults.standardUserDefaults().boolForKey("profileImage") {
   
            Connection.sharedInstance.getProfile(NSUserDefaults.standardUserDefaults().stringForKey("id")!) {
                image in
                if let imageReceived = image {
                    self.userProfileImageView.image = imageReceived

                } else {
                    self.userProfileImageView.image = UIImage(named: "profile")
                }
            }
        } else {
            self.userProfileImageView.image = UIImage(named: "profile")
        }
        
    
        
        let requestSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("request", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: requestSound)
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("error ::: \(error)")
            
        }
    }
    
    func didReceiveFriendUpdate(action: String) {
        
        var newBadge: String
        if let badge = self.tabBarController!.tabBar.items![0].badgeValue {
            newBadge = String(Int(badge)! + 1)
        } else {
            newBadge = "1"
        }
        self.tabBarController!.tabBar.items![0].badgeValue = newBadge
        audioPlayer?.play()
            
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Connection.sharedInstance.delegate = self
    }
    func didUploadImage(success: Bool) {
        if success == true {
            CSNotificationView.showInViewController(self, style: .Success, message: "Successfully uploaded image")
        } else {
            CSNotificationView.showInViewController(self, style: .Error, message: "fails to upload image")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let alert = SCLAlertView()
            alert.addButton("Yes!") {
                Connection.sharedInstance.logout() {
                    success in
                    if success == true {
                        self.performSegueWithIdentifier("logout", sender: nil)
                        
                    } else {
                        CSNotificationView.showInViewController(self, style: .Error, message: "Cannot Logout")
                        
                        
                    }
                }
                
            }
            alert.showWarning("Logout", subTitle: "Are you sure?",closeButtonTitle: "No, I will stay.")
            
            
        }
        
        
   
        
        
    }
    
    func didReceiveMessages(message: Message?,count:Int?) {
        
        
        var newBadge: String
        if let badge = self.tabBarController!.tabBar.items![1].badgeValue {
            newBadge = String(Int(badge)! + 1)
        } else {
            newBadge = "1"
        }
        self.tabBarController!.tabBar.items![1].badgeValue = newBadge
        audioPlayer?.play()
        
    }
  
    
}
