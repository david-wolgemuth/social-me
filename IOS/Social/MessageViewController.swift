//
//  MessageViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/7/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class MessageViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ConnectionSocketDelegate{
    
    var conversations = [Conversation]()
    @IBOutlet weak var tableView: UITableView!
    var audioPlayer:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let requestSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("request", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: requestSound)
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("error ::: \(error)")
            
        }

        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        conversations = CoreDataManager.sharedInstance.checkConversation()
        self.tableView.reloadData()
        Connection.sharedInstance.delegate = self
        self.tabBarController!.tabBar.items![1].badgeValue = nil

    }
    
    
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell")! as! conversationCell
        cell.lastMessageLabel?.text = conversations[indexPath.row].lastMessage
        
        let tempo = Tempo(date: self.conversations[indexPath.row].updatedAt!)
         cell.dateLabel?.text = tempo.timeAgoNow()
        
   
        
  
        
        
        
        
        
        
        
        
        
//        print(self.conversations[indexPath.row].unreadMsg!)
        if Int(self.conversations[indexPath.row].unreadMsg!)! > 0 {
            let fontSize: CGFloat = 14.0
            let label = UILabel()
            label.font = UIFont.systemFontOfSize(fontSize)
            label.textAlignment = .Center
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColor.redColor()
            label.text = self.conversations[indexPath.row].unreadMsg
            label.sizeToFit()
            var frame: CGRect = label.frame
            frame.size.height += CGFloat(0.4*Double(fontSize))
            frame.size.width = (Int(self.conversations[indexPath.row].unreadMsg!)! <= 9) ? frame.size.height: frame.size.width + fontSize
            label.frame = frame
            label.layer.cornerRadius = frame.size.height / 2.0
            label.clipsToBounds = true
            cell.accessoryView = label
            cell.accessoryType = .None
        } else {
            cell.accessoryView = nil;
            cell.accessoryType = .DisclosureIndicator
        }
        
        
        cell.userNameLabel?.text = Connection.sharedInstance.getFriendUserName(conversations[indexPath.row].friendId!)
        cell.conversationImage.image = UIImage(named: "profile")
  
    
      
     
        
       

//        cell.profilePicView.image = UIImage(named: "profile")
        
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
        performSegueWithIdentifier("goToConvo", sender: indexPath.row)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func didReceiveFriendUpdate(action: String) {
        var newBadge: String
        if let badge = self.tabBarController!.tabBar.items![0].badgeValue {
            newBadge = String(Int(badge)! + 1)
        } else {
            newBadge = "1"
        }
        self.tabBarController!.tabBar.items![0].badgeValue = newBadge
        audioPlayer?.play()
            
        
        
    }
    
    func didReceiveMessages(message: Message?) {
        if message != nil {
            conversations = CoreDataManager.sharedInstance.checkConversation()
            audioPlayer?.play()
            self.tableView.reloadData()
            
        }
    }
    
  
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToConvo" {
            let controller = segue.destinationViewController as! ConversationViewController
            let friendId = self.conversations[sender as! Int].friendId
            controller.friend = ["id":friendId!,"handle":Connection.sharedInstance.getFriendUserName(friendId!)]
            controller.hidesBottomBarWhenPushed = true
        }
        
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    @IBAction func unwindFromConvo(segue: UIStoryboardSegue) {
        
    }
    
    
    
    
}