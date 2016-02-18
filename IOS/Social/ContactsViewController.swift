//
//  ContactsViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/5/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import SCLAlertView



class ContactsViewController: UIViewController,ConnectionSocketDelegate{
    
    @IBOutlet weak var tableView: UITableView!
//    var user: User = CoreDataManager.sharedInstance.get_user()!
    
//    var friends = CoreDataManager.sharedInstance.get_friends()!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Connection.sharedInstance.delegate = self
    
//
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
        //implement notification/bages
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
  
    
    @IBAction func addFriendsButtonPressed(sender: UIBarButtonItem) {
        let alert = SCLAlertView()
    
        let friendEmail = alert.addTextField("xxxx@xxxx.com")
   
//        alert.addButton("Add") {
//            if let urlToReq = NSURL(string: "http://192.168.1.227:8000/users/add") {
//                let newRowIndex = self.friends.count
//
//                let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
//                request.HTTPMethod = "POST"
//                let bodyData = "my_email=\(self.user.email!)&email=\(friendEmail.text!)"
//                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
//                let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//                let task = session.dataTaskWithRequest(request) {
//                    (data, response,error) in
//                    if let found_data = data {
//                        dispatch_sync(dispatch_get_main_queue()) {
//                            CoreDataManager.sharedInstance.add_friend(self.parseJSON(found_data)! as [AnyObject])
//                            self.friends = CoreDataManager.sharedInstance.get_friends()!
//                            let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
//                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                            
//                        }
//                        
//                    }
//                
//                }
//                task.resume()
//
//            }
//            
//        }
//        
     
        alert.showEdit("Add friend",subTitle: "Enter user's email address",closeButtonTitle: "Cancel")
        
        
        
        
    }

    
   
}
