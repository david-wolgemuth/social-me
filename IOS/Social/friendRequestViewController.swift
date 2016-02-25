//
//  friendRequestViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/19/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import CSNotificationView
import AVFoundation


protocol friendRequestDelegate {
    func didConfirmNewFriendRequest()
}

class friendRequestViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ConnectionSocketDelegate{
    
  
    var audioPlayer:AVAudioPlayer?

    
    var friendRequests =  [Dictionary<String,String>]()
    var delegate: friendRequestDelegate?
 
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        
        let requestSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("request", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: requestSound)
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("error ::: \(error)")
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        friendRequests = Connection.sharedInstance.getFriendRequest()
        Connection.sharedInstance.delegate = self
        self.tableView.reloadData()
        
    }
    
    
    func didReceiveFriendUpdate(action: String) {
        if action == "Request" {
            friendRequests = Connection.sharedInstance.getFriendRequest()
            self.tableView.reloadData()
            audioPlayer?.play()
        } else {
            self.delegate?.didConfirmNewFriendRequest()
            
        
        }
    }
    
    
    
    
    



    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }
    
    func didReceiveMessages(message: Message?) {
        
    }




    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell

        cell.usernameLabel?.text = friendRequests[indexPath.row]["handle"]
        cell.profilePicView.image = UIImage(named: "profile") //fetch image later
        
        return cell
    }
    
    
   
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
      
        let accept = UITableViewRowAction(style: .Normal, title: "\u{2713} \n Accept") { action, index in
            
            Connection.sharedInstance.respondFriend(indexPath.row, accept: true) {
                success,error in
                if success == false {
                    CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Error, message: error!)
                } else {
                    self.friendRequests = Connection.sharedInstance.getFriendRequest()
                    if let badge = self.tabBarItem.badgeValue {
                        let newBadgeValue = String(Int(badge)!-1)
                        if newBadgeValue == "0" {
                            self.tabBarItem.badgeValue = nil
                        } else {
                            self.tabBarItem.badgeValue = newBadgeValue
                        }
                        
                    }
                    
                    self.delegate?.didConfirmNewFriendRequest()
                    self.tableView.reloadData()
    
                }
            }
        }
        accept.backgroundColor = UIColor(red: 0, green: 192.0/255.0, blue: 0, alpha: 1.0)
        
        let ignore = UITableViewRowAction(style: .Normal, title: "\u{0FBE} \n Ignore") { action, index in
            Connection.sharedInstance.respondFriend(indexPath.row, accept: false) {
                success,error in
                if success == false {
                    CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Error, message: error!)
                } else {
                    self.friendRequests = Connection.sharedInstance.getFriendRequest()
                    
                    if let badge = self.tabBarItem.badgeValue {
                        let newBadgeValue = String(Int(badge)!-1)
                        if newBadgeValue == "0" {
                            self.tabBarItem.badgeValue = nil
                        } else {
                            self.tabBarItem.badgeValue = newBadgeValue
                        }
                        
                    }
                    self.tableView.reloadData()
                }
            }
        }
        ignore.backgroundColor = UIColor.redColor()
        
        return [ignore,accept]
    }
  
   
    
   

    
    
  

    
}
