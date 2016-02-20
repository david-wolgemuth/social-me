//
//  searchFriendViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/19/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import SCLAlertView
import CSNotificationView

extension String
{
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}


class searchFriendViewController: UIViewController,UISearchBarDelegate,ConnectionAddFriendDelegate,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var friendFound = [Dictionary<String,String>]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.delegate = self
        Connection.sharedInstance.addFriendDelegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func backgroundTapped(sender: UITapGestureRecognizer) {   
        self.view.endEditing(true)
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        let cancelGesture = UITapGestureRecognizer()
        cancelGesture.addTarget(self, action: Selector("backgroundTapped:"))
        self.view.addGestureRecognizer(cancelGesture)
        cancelGesture.cancelsTouchesInView = false
        friendFound = []
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return friendFound.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
        
        cell.usernameLabel?.text = friendFound[indexPath.row]["handle"]
        cell.profilePicView.image = UIImage(named: "profile") //fetch image later
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alert = SCLAlertView()
        
        alert.addButton("Yes") {
            Connection.sharedInstance.addFriend(self.friendFound[0]["id"]!)
            
        }
        alert.showNotice("Friend Request", subTitle: "Do you want to add this user as a friend?",closeButtonTitle: "No")
    
    }
    
    func didAcceptFriendRequest(success: Bool) {
        if success == true {
            CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Error, message: "Already Friend")
        } else {
            CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Success, message: "Request Sent")
            
        }
    }
   
 
    
    
  
    
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let trimText = self.searchBar.text!.trim()
        Connection.sharedInstance.FindFriend(trimText)
        searchBar.resignFirstResponder()
    }
    
    
    func didFindFriend(success: Bool, friendFound: Dictionary<String, String>?) {
 
        if success == true {
            self.friendFound.append(friendFound!)
            self.tableView.reloadData()
        } else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "No user \(searchBar.text!) was found",closeButtonTitle: "Close")
        
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Connection.sharedInstance.addFriendDelegate = nil
    }
    
    
  
}


