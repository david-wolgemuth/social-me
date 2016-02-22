//
//  ContactsViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/5/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import SCLAlertView
import MIBadgeButton_Swift


class ContactsViewController: UIViewController,ConnectionSocketDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var ToConfirm = [String: String]()
    
   
    var count = 0
    var AddFriendButton: UIBarButtonItem?
    var Friends = [Dictionary<String,String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Connection.sharedInstance.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Connection.sharedInstance.checkFriendRequest()
        
        let userPlusImage = UIImage.fontAwesomeIconWithName(.UserPlus, textColor: UIColor(red: 100.0/255.0, green: 255.0/255.0, blue: 197.0/255.0, alpha: 1.0), size: CGSizeMake(30,30))
        
        count = Connection.sharedInstance.getFriendRequest().count
        if count > 0 {
            let button = MIBadgeButton(type: .Custom)
            button.badgeString = String(count)
            button.frame = CGRectMake(0, 0, 70, 40)
            button.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 15)
            button.setImage(userPlusImage, forState: .Normal)
            button.addTarget(self, action: Selector("addFriendsButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
            
        } else {
            self.AddFriendButton = UIBarButtonItem(image:userPlusImage, style: UIBarButtonItemStyle.Plain, target:self, action:  Selector("addFriendsButtonPressed:"))
            self.navigationItem.rightBarButtonItem = self.AddFriendButton
        }
        Connection.sharedInstance.getFriend({
            friends in
            self.Friends = friends
            self.tableView.reloadData()
            
        })

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
            tabBar.count = self.count
            
        }
        
      

    }
    


  
    
    func addFriendsButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("friendView", sender: nil)
    }
   

    

    
   
}
