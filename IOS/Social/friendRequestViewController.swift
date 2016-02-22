//
//  friendRequestViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/19/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import CSNotificationView

class friendRequestViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
  
    
    
    var friendRequests: [Dictionary<String,String>] = Connection.sharedInstance.getFriendRequest()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    
    


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }




    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell

        cell.usernameLabel?.text = friendRequests[indexPath.row]["handle"]
        cell.profilePicView.image = UIImage(named: "profile") //fetch image later
        
        return cell
    }
    
 
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let accept = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            print("pressed")
            
            Connection.sharedInstance.respondFriend(self.friendRequests[indexPath.row]["id"]!, accept: true) {
                success,error in
                if success == false {
                    CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Error, message: error!)
                } else {
                    self.friendRequests.removeAtIndex(indexPath.row)
                    let newBadgeValue = String(Int(self.tabBarItem.badgeValue!)!-1)
                    if newBadgeValue == "0" {
                        self.tabBarItem.badgeValue = nil
                    } else {
                        self.tabBarItem.badgeValue = newBadgeValue
                    }
                    self.tableView.reloadData()
                }
            }
        }
        accept.backgroundColor = UIColor.greenColor()
        
        let ignore = UITableViewRowAction(style: .Normal, title: "Ignore") { action, index in
            Connection.sharedInstance.respondFriend(self.friendRequests[indexPath.row]["id"]!, accept: false) {
                success,error in
                if success == false {
                    CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Error, message: error!)
                } else {
                    self.friendRequests.removeAtIndex(indexPath.row)
                    let newBadgeValue = String(Int(self.tabBarItem.badgeValue!)!-1)
                    if newBadgeValue == "0" {
                        self.tabBarItem.badgeValue = nil
                    } else {
                        self.tabBarItem.badgeValue = newBadgeValue
                    }
                    self.tableView.reloadData()
                }
            }
        }
        ignore.backgroundColor = UIColor.redColor()
        
        return [ignore,accept]
    }
    
   

    
    
  

    
}
