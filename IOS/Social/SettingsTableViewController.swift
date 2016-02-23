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

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var userLabel: UILabel!
    
    
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        userLabel.font = UIFont.fontAwesomeOfSize(20)
        userLabel.text = String.fontAwesomeIconWithName(.User)
        userName.text = NSUserDefaults.standardUserDefaults().stringForKey("user")
        
        

        
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
  
    
}
