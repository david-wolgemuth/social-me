//
//  ContactsViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/5/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import SCLAlertView
import CSNotificationView
import MIBadgeButton_Swift
import AVFoundation



class ContactsViewController: UIViewController,ConnectionSocketDelegate,UITableViewDataSource,friendRequestDelegate,UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var AddFriendButton: UIBarButtonItem?
    
    var Friends = Connection.sharedInstance.getFriends()
    

    
    var playSound = false
 
    
    var audioPlayer:AVAudioPlayer?
    
    var button = MIBadgeButton(type: .Custom)
    let userPlusImage = UIImage.fontAwesomeIconWithName(.UserPlus, textColor: UIColor(red: 100.0/255.0, green: 255.0/255.0, blue: 197.0/255.0, alpha: 1.0), size: CGSizeMake(30,30))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController!.tabBar.items![0].image = UIImage.fontAwesomeIconWithName(.Users, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        self.tabBarController!.tabBar.items![1].image = UIImage.fontAwesomeIconWithName(.Commenting, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        self.tabBarController!.tabBar.items![2].image = UIImage.fontAwesomeIconWithName(.Cog, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        
        

        self.tableView.delegate = self
        self.tableView.dataSource = self
        button.frame = CGRectMake(0,0,70,40)
        button.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 15)
        button.setImage(userPlusImage, forState: .Normal)
        button.addTarget(self, action: Selector("addFriendsButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
 
        Connection.sharedInstance.delegate = self
        Connection.sharedInstance.listenForFriendUpdate()
        
        Connection.sharedInstance.listenForMessages()
        Connection.sharedInstance.listenForNewConversation()
        
        let requestSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("request", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: requestSound)
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("error ::: \(error)")
            
        }
        Connection.sharedInstance.getConversation()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Connection.sharedInstance.delegate = self
        if playSound {
            audioPlayer?.play()
            playSound = false
            
        }
        let count = Connection.sharedInstance.getFriendRequestCount()
        if count > 0 {
            button.badgeString = String(count)
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
            
        } else {
            self.AddFriendButton = UIBarButtonItem(image:userPlusImage, style: UIBarButtonItemStyle.Plain, target:self, action:  Selector("addFriendsButtonPressed:"))
            self.navigationItem.rightBarButtonItem = self.AddFriendButton
        }
        self.tabBarController!.tabBar.items![0].badgeValue = nil
        

        

    }
    

   



        
    

 

 
    func didReceiveMessages(message: Message?,count: Int?) {
        var newBadge: String
 
        if count == nil {
            
            if let badge = self.tabBarController!.tabBar.items![1].badgeValue {
                newBadge = String(Int(badge)! + 1)
            } else {
                newBadge = "1"
            }
             self.tabBarController!.tabBar.items![1].badgeValue = newBadge
            audioPlayer?.play()
        } else {
            
            if count != 0 {
                newBadge = String(count!)
                playSound = true
                self.tabBarController!.tabBar.items![1].badgeValue = newBadge
                
            }
            
        }
       
    }
    
    func didReceiveConversation() {
        var newBadge: String
        
            if let badge = self.tabBarController!.tabBar.items![1].badgeValue {
                newBadge = String(Int(badge)! + 1)
            } else {
                newBadge = "1"
            }
            self.tabBarController!.tabBar.items![1].badgeValue = newBadge
            audioPlayer?.play()
        
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Friends.count
    }
    
    
    
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
        var cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
        cell.usernameLabel?.text = Friends[indexPath.row]["handle"]
        
     
        if Friends[indexPath.row]["profileImage"] == "1" {
            Connection.sharedInstance.getProfile(self.Friends[indexPath.row]["id"]!) {
                image in
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageReceived = image {
                        if tableView.cellForRowAtIndexPath(indexPath) != nil {
                            cell = tableView.cellForRowAtIndexPath(indexPath) as! UserCell
                            cell.profilePicView.image = imageReceived

                            
                        }
                    } else {
                        cell.profilePicView.image = UIImage(named: "profile")
                    }
                }
               
                
            }
        } else {
            cell.profilePicView.image = UIImage(named: "profile")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("talk", sender: indexPath.row)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "talk" {
            let controller = segue.destinationViewController as! ConversationViewController
            let friend = self.Friends[sender as! Int]
            controller.friend = friend
            controller.hidesBottomBarWhenPushed = true
            
        }
        if segue.identifier == "friendView" {
            let tabBar = segue.destinationViewController as! TabBarController2
            let friendReqCtrl = tabBar.viewControllers![1] as! friendRequestViewController
            friendReqCtrl.delegate = self
            let searchReqCtrl = tabBar.viewControllers![0] as! searchFriendViewController
            searchReqCtrl.delegate = self
            
        }

    }
    
    func didConfirmNewFriendRequest() {
        self.Friends = Connection.sharedInstance.getFriends()
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
       
    }
 
    
    func addFriendsButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("friendView", sender: nil)
    }
   
    func didReceiveFriendUpdate(action: String) {
   
        
        if action == "Request" {
            print("Contacts view controller got new request")
            button.badgeString = String(Connection.sharedInstance.getFriendRequestCount())
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
            
            audioPlayer?.play()
            
        } else { //new friend from confirming request
            print("contacts view controller got now friend")
            Friends = Connection.sharedInstance.getFriends()
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                
            }
            
            audioPlayer?.play()
        }
    }
    
 

    

    
   
}
