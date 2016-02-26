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

class SettingsTableViewController: UITableViewController,ConnectionSocketDelegate{
    @IBOutlet weak var userLabel: UILabel!
    
    
    @IBOutlet weak var userName: UILabel!
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        userLabel.font = UIFont.fontAwesomeOfSize(20)
        userLabel.text = String.fontAwesomeIconWithName(.User)
        userName.text = NSUserDefaults.standardUserDefaults().stringForKey("user")
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
