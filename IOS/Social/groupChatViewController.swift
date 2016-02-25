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

class groupChatTableViewController: UITableViewController,UITextFieldDelegate{
    
    @IBOutlet weak var peopleLabel: UILabel!
    
    @IBOutlet weak var searchCell: UITableViewCell!
    
    @IBOutlet weak var searchLabel: UILabel!
    
    @IBOutlet weak var searchTextField: IsaoTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleLabel.font = UIFont.fontAwesomeOfSize(20)
        peopleLabel.text = String.fontAwesomeIconWithName(.Users)
        searchLabel.font = UIFont.fontAwesomeOfSize(20)
        searchLabel.text = String.fontAwesomeIconWithName(.Search)
        searchTextField.delegate = self
        tableView.allowsSelection = false
        searchCell.separatorInset = UIEdgeInsetsMake(0, searchCell.bounds.size.width, 0, 0);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print(textField.text)
    }
    

    
    
    
  
 
    
    
   

    
    
    

    
    
    
    
}

