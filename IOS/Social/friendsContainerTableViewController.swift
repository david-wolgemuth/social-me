//
//  friendsContainerTableViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/24/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

protocol updateGroupDelegate {
    func firstSelect(user: Dictionary<String,String>)
    func didUpdateGroupPeople(action: String, user: Dictionary<String,String>?, index: Int?)
    
}

import UIKit
class friendsContainerTableViewController: UITableViewController{
    
    var friends = Connection.sharedInstance.getFriends()
    var filteredFriends = [Dictionary<String,String>]()
    var search: Bool = false
    var firstSelect: Bool = true

    var delegate: updateGroupDelegate?
    
    var selectedFriends = [Dictionary<String,String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
       

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int)->Int {
        if search {
            return filteredFriends.count
        }
        else {
            return friends.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCellWithIdentifier("userCell")! as! UserCell
        
        // Configure the cell...
        if search {
            cell.usernameLabel.text = filteredFriends[indexPath.row]["handle"]
        }
        else {
            cell.usernameLabel.text = friends[indexPath.row]["handle"]
           
        }
        cell.profilePicView.image = UIImage(named: "profile")
        return cell
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        var currentId = ""
        if search {
            currentId = self.filteredFriends[indexPath.row]["id"]!
        }
        else {
            currentId = self.friends[indexPath.row]["id"]!
            
        }
        if checkIfSelected(currentId) > -1 {
            cell.setSelected(true, animated: false)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            
        }
        
    
        
    }
    
   
    func updateSearchResults(searchText: String) {
        search = true
        if searchText.characters.count > 0 {
            filteredFriends.removeAll(keepCapacity: false)
            let searchPredicate = NSPredicate(format: "handle CONTAINS[cd] %@", searchText)
            let array = (friends as NSArray).filteredArrayUsingPredicate(searchPredicate)
            filteredFriends = array as! [Dictionary<String,String>]
        } else {
            filteredFriends.removeAll(keepCapacity: false)
            filteredFriends = friends
            
        }
        tableView.reloadData()
    }
    

    
    func checkIfSelected(id:String) -> Int {
        for (var i = 0 ; i < selectedFriends.count; i++) {
            if self.selectedFriends[i]["id"] == id {
                return i
            }
        }
        return -1
    }
    
    
   
    
  
    
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var userAdd =  Dictionary<String,String>()
        if search {
            userAdd = self.filteredFriends[indexPath.row]
            
            
        } else {
            userAdd = self.friends[indexPath.row]
            
        }
        selectedFriends.append(userAdd)
        
        if firstSelect {
            delegate?.firstSelect(selectedFriends[0])
            firstSelect = false
        } else {
            delegate?.didUpdateGroupPeople("add", user: userAdd, index: nil)
        }
              
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var id: String
        if search {
            id = self.filteredFriends[indexPath.row]["id"]!
        } else {
            id = self.friends[indexPath.row]["id"]!
        }
        let index = checkIfSelected(id)
        selectedFriends.removeAtIndex(index)
        delegate?.didUpdateGroupPeople("delete", user: nil, index: index)
        
    }

    
}
