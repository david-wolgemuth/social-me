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


class ContactsViewController: UIViewController,ConnectionSocketDelegate,ConnectionAddFriendDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var friends = [Friend]()
    var ToConfirm = [String: String]()
    
   
    
    var AddFriendButton: UIBarButtonItem?


    override func viewDidLoad() {
        super.viewDidLoad()
        Connection.sharedInstance.delegate = self
        Connection.sharedInstance.addFriendDelegate = self
        
        
        
        let userPlusImage = UIImage.fontAwesomeIconWithName(.UserPlus, textColor: UIColor(red: 100.0/255.0, green: 255.0/255.0, blue: 197.0/255.0, alpha: 1.0), size: CGSizeMake(30,30))
        
        Connection.sharedInstance.checkFriendRequest({
            friendsRequest in
            if friendsRequest.count > 0 {
                for friends in friendsRequest {
                    self.ToConfirm[friends["_id"]! as! String] = friends["handle"]! as! String
                    
                }
                print(self.ToConfirm)
                let button = MIBadgeButton(type: .Custom)
                button.badgeString = String(friendsRequest.count)
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
        })

   

//        tableView.dataSource = self
//        tableView.delegate = self
        
    

 
//
//        if overwrite {
//            print("getting friend because the record has been overwritten")
//            if let urlToReq = NSURL(string: "http://192.168.1.227:8000/users/friends") {
//                let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
//                request.HTTPMethod = "POST"
//                let bodyData = "id=\(self.user.id!)"
//                print("user id is.....\(self.user.id!)")
//                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
//                let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//                let task = session.dataTaskWithRequest(request) {
//                    (data, response,error) in
//                    if let found_data = data {
//                        CoreDataManager.sharedInstance.add_friend(self.parseJSON(found_data)! as [AnyObject])
//                        self.friends = CoreDataManager.sharedInstance._friends()!
//                        self.tableView.reloadData()
//                    }
//                }
//                task.resume()
//            }
//        }
//        Connection.sharedInstance.listenForMessages()
    }
 
    func didReceiveMessages(data: AnyObject) {
        //implement notification 
        
    }
    
   
    func parseJSON(inputData: NSData) -> NSArray? {
        var arrOfObjects: NSArray?
        do {
            arrOfObjects = try NSJSONSerialization.JSONObjectWithData(inputData, options: .MutableContainers) as? NSArray
            
        } catch let error as NSError {
            print(error)
        }
        return arrOfObjects
    }
    
//   
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return friends.count
//    }
//    
    
    
// 
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//   
//        var cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
//        cell.usernameLabel?.text = friends[indexPath.row].username
//        cell.profilePicView.image = UIImage(named: "profile")
//        
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
//        return cell
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("talk", sender: indexPath.row)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "talk" {
//            let controller = segue.destinationViewController as! ConversationViewController
//            let friend = friends[sender as! Int]
////            controller.friend = friend
//            controller.hidesBottomBarWhenPushed = true;
//            
//            
//        }
//        
//      
//
//    }
    

 
    @IBAction func getSessionUsers(sender: UIButton) {
        Connection.sharedInstance.getSessionUsers()
    }
  
    
    func addFriendsButtonPressed(sender: UIBarButtonItem) {
        let alert = SCLAlertView()
        let friendEmail = alert.addTextField("xxxx@xxxx.com OR xxxx")
        var tapped: Bool = false
        alert.addButton("Add") {
            
            Connection.sharedInstance.FindFriend(friendEmail.text!)
            tapped = true

        }
        
        alert.hideWhenBackgroundViewIsTapped = true
        alert.showEdit("Add friend",subTitle: "Enter user's email address or username",closeButtonTitle: "Cancel")
        if tapped {
            AddFriendButton?.enabled = false
        }
        
    }
    
    func didFindFriend(success: Bool) {
        let alert = SCLAlertView()
        AddFriendButton?.enabled = true
     
        if success == false {
            alert.showError("Error!",subTitle: "No User Found!",closeButtonTitle: "Okay I get it")
        }
        
        
        
//        
//        if success == true {
////            alertViewResponder = alert.showWait("Sending request..",subTitle: "")
//         
//        } else {
//            alert.showCloseButton = true
//            alert.showError("Error! No user Found!",subTitle: "",closeButtonTitle: "Okay I get it")
//        }
    }
    
    func didAcceptFriendRequest(success: Bool) {
        let alert = SCLAlertView()

        if success == true {
            print("true")
            alert.showError("Oops!", subTitle: "You guys are already Friend",closeButtonTitle: "Close")
        } else {
            print("false")
            alert.showSuccess("Success",subTitle: "Sent Request!")
        }
 
    }
    

    
   
}
