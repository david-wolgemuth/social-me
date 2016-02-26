//
//  groupChatViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/24/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import Foundation
import TextFieldEffects

class groupChatTableViewController: UITableViewController,UITextFieldDelegate,updateGroupDelegate{
    
    @IBOutlet weak var peopleLabel: UILabel!
    
    @IBOutlet weak var searchCell: UITableViewCell!
    
    @IBOutlet weak var searchLabel: UILabel!
    
    @IBOutlet weak var searchTextField: IsaoTextField!
    
    @IBOutlet weak var groupPeopleLabel: UILabel!
    
    var selected = [Dictionary<String,String>]()
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleLabel.font = UIFont.fontAwesomeOfSize(20)
        peopleLabel.text = String.fontAwesomeIconWithName(.Users)
        searchLabel.font = UIFont.fontAwesomeOfSize(20)
        searchLabel.text = String.fontAwesomeIconWithName(.Search)
        searchTextField.delegate = self
        tableView.allowsSelection = false
        searchCell.separatorInset = UIEdgeInsetsMake(0, searchCell.bounds.size.width, 0, 0)
        searchTextField.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: .EditingChanged)
        let containerCtrl = self.childViewControllers[0] as! friendsContainerTableViewController
        containerCtrl.delegate = self
        groupPeopleLabel.text = ""
      
       
        
    }

  
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidChange(sender: UITextField) {
        
        let containerCtrl = self.childViewControllers[0] as! friendsContainerTableViewController
        containerCtrl.updateSearchResults(sender.text!)
    }
    
    func firstSelect(user: Dictionary<String, String>) {
        self.selected.append(user)
        self.updateUI()
    }
    
    
    func didUpdateGroupPeople(action: String, user: Dictionary<String, String>?, index: Int?) {
        if action == "delete" {
            self.selected.removeAtIndex(index!)
        } else {
            self.selected.append(user!)
        }
        self.updateUI()
        
    }
    
    func updateUI() {
        var string = ""
        for var i = 0; i < self.selected.count; i++ {
            if i != 0 {
                string+=","+self.selected[i]["handle"]!
            } else {
                string += self.selected[i]["handle"]!
            }
        }
        groupPeopleLabel.text = string
    }
    

    
    
    
  
 
    
    
   

    
    
    

    
    
    
    
}

