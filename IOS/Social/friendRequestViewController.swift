//
//  friendRequestViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/19/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
class friendRequestViewController: UIViewController,UITableViewDataSource{
    
  
    
    
    var friendRequests: [Dictionary<String,String>] = Connection.sharedInstance.getFriendRequest()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        print(friendRequests)
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
    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        
        let accept = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            print("Accept tapped")
        }
        accept.backgroundColor = UIColor.greenColor()
        
        let ignore = UITableViewRowAction(style: .Normal, title: "Ignore") { action, index in
            print("Ignore")
        }
        ignore.backgroundColor = UIColor.redColor()
        
        return [accept,ignore]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
  

    
}
