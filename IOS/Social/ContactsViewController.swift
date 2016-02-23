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


class ContactsViewController: UIViewController,ConnectionSocketDelegate,UITableViewDataSource,friendRequestDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var AddFriendButton: UIBarButtonItem?
    
    var Friends = Connection.sharedInstance.getFriends()
    

    
    
 
    
    var audioPlayer:AVAudioPlayer?
    
    var button = MIBadgeButton(type: .Custom)
    let userPlusImage = UIImage.fontAwesomeIconWithName(.UserPlus, textColor: UIColor(red: 100.0/255.0, green: 255.0/255.0, blue: 197.0/255.0, alpha: 1.0), size: CGSizeMake(30,30))

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
        Connection.sharedInstance.delegate = self
        self.tableView.dataSource = self
        button.frame = CGRectMake(0,0,70,40)
        button.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 15)
        button.setImage(userPlusImage, forState: .Normal)
        button.addTarget(self, action: Selector("addFriendsButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
 
        
        Connection.sharedInstance.listenForFriendUpdate()
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
        
        
        let count = Connection.sharedInstance.getFriendRequestCount()
        if count > 0 {
            button.badgeString = String(count)
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
            
        } else {
            self.AddFriendButton = UIBarButtonItem(image:userPlusImage, style: UIBarButtonItemStyle.Plain, target:self, action:  Selector("addFriendsButtonPressed:"))
            self.navigationItem.rightBarButtonItem = self.AddFriendButton
        }
        

    }
  

   


//        tableView.delegate = self
        
    

 

 
    func didReceiveMessages(data: AnyObject) {
        //implement notification 
        
    }
    
  
    

    
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Friends.count
    }
    
    
    
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
        cell.usernameLabel?.text = Friends[indexPath.row]["handle"]
        cell.profilePicView.image = UIImage(named: "profile")
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
//            let id = self.friends[indexPath.row].id
//            let urlString = "http://192.168.1.227:8000/\(id!).jpeg"
// 
//            let urltoReq = NSURL(string: urlString)
//          
//            let image = UIImage(data: NSData(contentsOfURL: urltoReq!)!)
//            dispatch_async(dispatch_get_main_queue()) {
//                cell = tableView.cellForRowAtIndexPath(indexPath) as! UserCell
//                cell.profilePicView.image = image
//                
//            }
//            
//        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("talk", sender: indexPath.row)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "talk" {
//            let controller = segue.destinationViewController as! ConversationViewController
//            let friend = friends[sender as! Int]
////            controller.friend = friend
//            controller.hidesBottomBarWhenPushed = true;
//            
//            
//        }
        if segue.identifier == "friendView" {
            let tabBar = segue.destinationViewController as! TabBarController2
            let controller = tabBar.viewControllers![1] as! friendRequestViewController
            controller.delegate = self
        }

    }
    
    func didConfirmNewFriendRequest() {
        self.Friends = Connection.sharedInstance.getFriends()
        self.tableView.reloadData()
       
    }
 
    
    func addFriendsButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("friendView", sender: nil)
    }
   
    func didReceiveFriendUpdate(action: String) {
   
        
        if action == "Request" {
            print("new request")
            button.badgeString = String(Connection.sharedInstance.getFriendRequestCount())
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
            audioPlayer?.play()
            
        } else { //new friend from confirming request
            print("new friend")
            Friends = Connection.sharedInstance.getFriends()
            self.tableView.reloadData()
            audioPlayer?.play()
        }
    }
    
 

    

    
   
}
