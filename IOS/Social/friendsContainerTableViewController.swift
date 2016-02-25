//
//  friendsContainerTableViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/24/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
class friendsContainerTableViewController: UITableViewController {
    
    var friends = Connection.sharedInstance.getFriends()
    var filteredFriends = [Dictionary<String,String>]()
    var search: Bool = false


    var resultSearchController: UISearchController!
    var selected: Bool = false

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
//    
//    func updateSearchResults(text) {
//        if searchController.searchBar.text?.characters.count > 0 {
//            //                filteredFriends.removeAll(keepCapacity: false)
//            //                let searchPredicate = NSPredicate(format: "handle CONTAINS[cd] %@", searchController.searchBar.text!)
//            //                let array = (friends as NSArray).filteredArrayUsingPredicate(searchPredicate)
//            //                filteredFriends = array as! [Dictionary<String,String>]
//            //                tableView.reloadData()
//            //
//            //            } else {
//            //                filteredFriends.removeAll(keepCapacity: false)
//            //                filteredFriends = friends
//            //                tableView.reloadData()
//            //            }
//        
//        
//        
//        
//    }
//    
    
//    
//        func updateSearchResultsForSearchController(searchController: UISearchController) {
//    
//            if searchController.searchBar.text?.characters.count > 0 {
//                filteredFriends.removeAll(keepCapacity: false)
//                let searchPredicate = NSPredicate(format: "handle CONTAINS[cd] %@", searchController.searchBar.text!)
//                let array = (friends as NSArray).filteredArrayUsingPredicate(searchPredicate)
//                filteredFriends = array as! [Dictionary<String,String>]
//                tableView.reloadData()
//    
//            } else {
//                filteredFriends.removeAll(keepCapacity: false)
//                filteredFriends = friends
//                tableView.reloadData()
//            }
//    
//        }

//        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
////            var newText = ""
////            if resultSearchController.active {
////                newText = self.filteredFriends[indexPath.row]["handle"]!
////            }
////            else {
////                newText = self.friends[indexPath.row]["handle"]!
////            }
////            if let currentText = self.resultSearchController.searchBar.text {
////    
////                if currentText != "" {
////                    newText = currentText + "," + newText
////                }
////            }
////            self.selected = true
////            resultSearchController.searchBar.text = newText
//    
//          
//        }

    
}
