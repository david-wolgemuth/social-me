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
import SwiftyButton
import AVFoundation

extension String
{
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}


class searchFriendViewController: UIViewController,UISearchBarDelegate,ConnectionAddFriendDelegate,UITableViewDataSource,UITableViewDelegate,ConnectionSocketDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var friendFound = [Dictionary<String,AnyObject>]()
    var changeQuery: Bool = false
    var SubmitRequest: Bool = false
    var friendIndex: Int = -1
    
    var audioPlayer:AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    
    var delegate: friendRequestDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let requestSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("request", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: requestSound)
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("error ::: \(error)")
            
        }
        
        let sentSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sent", ofType: "wav")!)
        do {
            soundPlayer = try AVAudioPlayer(contentsOfURL: sentSound)
            soundPlayer?.prepareToPlay()
        } catch let error {
            print("error ::: \(error)")
            
        }
   


    }

    override func viewWillAppear(animated: Bool) {
        print("View appeared")
        searchBar.delegate = self
        Connection.sharedInstance.addFriendDelegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        Connection.sharedInstance.delegate = self
        super.viewWillAppear(animated)
    }
    
    func backgroundTapped(sender: UITapGestureRecognizer) {   
        self.view.endEditing(true)
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        let cancelGesture = UITapGestureRecognizer()
        cancelGesture.addTarget(self, action: Selector("backgroundTapped:"))
        self.view.addGestureRecognizer(cancelGesture)
        cancelGesture.cancelsTouchesInView = false
        if SubmitRequest {
            changeQuery = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return friendFound.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchUserCell")! as! SearchFriendUserCell
        
        cell.usernameLabel?.text = friendFound[indexPath.row]["handle"] as? String
        let friendAlready = friendFound[indexPath.row]["isFriend"]! as! Int
        let requestSentAlready = friendFound[indexPath.row]["requestSent"] as! Int
        cell.AddFriendButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.AddFriendButton.titleLabel?.textAlignment = .Center
     
        if friendAlready == 1 || requestSentAlready == 1{
            if friendAlready == 1 {
                cell.AddFriendButton.setTitle("Already\nFriends", forState: .Normal)
                
            } else if requestSentAlready == 1 {
                cell.AddFriendButton.setTitle("Request\nSent", forState: .Normal)
                
            }
            cell.AddFriendButton.enabled = false
            
        } else {
            cell.AddFriendButton.enabled = true
            cell.AddFriendButton.setTitle("Add\nFriend",forState:  .Normal)
            cell.AddFriendButton.tag = indexPath.row
            cell.AddFriendButton.addTarget(self, action: Selector("sendFriendRequest:"), forControlEvents: UIControlEvents.TouchUpInside)
            
        }
  
        cell.profilePicView.image = UIImage(named: "profile") //fetch image later
        cell.selectionStyle = UITableViewCellSelectionStyle.None
  

        return cell
    }
    
    func didSuccessSendRequest(success: Bool,error: String?) {
        if success == true {
            
            self.friendFound[friendIndex]["requestSent"] = 1
            self.tableView.reloadData()
            soundPlayer?.play()
            
            
        } else {
            CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Error, message: error!)
        }
        SubmitRequest = false
    }
    

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let trimText = self.searchBar.text!.trim()
        Connection.sharedInstance.FindFriend(trimText)
        searchBar.resignFirstResponder()
    }
    
    func sendFriendRequest(sender: SwiftyButton) {
        let index = sender.tag
        friendIndex = index
        Connection.sharedInstance.addFriend(self.friendFound[index]["id"] as! String)
        SubmitRequest = true
        
    }

    func didFindFriend(success: Bool, friendFound: [Dictionary<String, AnyObject>]?) {
        if success == true {
            self.friendFound = friendFound!
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Connection.sharedInstance.addFriendDelegate = nil
    }
    
    func didReceiveMessages(message: Message?) {
        
    }
    
    
    func didReceiveFriendUpdate(action: String) {
        if action == "Request" {
            var newBadge: String
            if let badge = self.tabBarController!.tabBar.items![1].badgeValue {
                newBadge = String(Int(badge)!+1)
            } else {
                newBadge = "1"
            }
            self.tabBarController!.tabBar.items![1].badgeValue = newBadge
            audioPlayer?.play()
        } else {
            self.delegate?.didConfirmNewFriendRequest()
        }
    }

    
  
}


