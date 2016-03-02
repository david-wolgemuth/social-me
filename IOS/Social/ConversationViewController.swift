//
//  ConversationViewController.swift
//  Social
//
//  Created by Shuhan Ng on 2/7/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import JSQSystemSoundPlayer
import Foundation
import CoreData
import AVFoundation

class ConversationViewController: JSQMessagesViewController,ConnectionSocketDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ConnectionImageDelegate{
    
    var friend: Dictionary<String,String>?
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())

    var messages = [Message]()
    var conversationId: String = ""

    var avatars = Dictionary<String, JSQMessageAvatarImageDataSource>()
    
    var audioPlayer: AVAudioPlayer?
    var groupChat: Bool = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        Connection.sharedInstance.delegate = self
       
        self.senderId = NSUserDefaults.standardUserDefaults().stringForKey("id")
        self.senderDisplayName = NSUserDefaults.standardUserDefaults().stringForKey("user")
     
        automaticallyScrollsToMostRecentMessage = true
        Connection.sharedInstance.imageDelegate = self
        
        if self.friend!["handle"] == nil {
            groupChat = true
            Connection.sharedInstance.showGroupConversation(self.conversationId) {
                title,messages in
                self.navigationItem.title = title
                if messages != nil {
                    self.messages = messages!
                }
                 CoreDataManager.sharedInstance.update_conversation(self.conversationId)
                
                
                
            }
        } else {
            self.navigationItem.title = friend!["handle"]!
            Connection.sharedInstance.showConversation(friend!["id"]!) {
                conversationId,messages in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.conversationId = conversationId
                    CoreDataManager.sharedInstance.update_conversation(self.conversationId)
                    if messages != nil {
                        self.messages = messages!
                        
                        self.finishReceivingMessage()
                    }
                }
            }
        }
      
        
        
            
        
        let requestSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("request", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: requestSound)
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("error ::: \(error)")
            
        }
        
        scrollToBottomAnimated(true)

    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        
        let view = UIAlertController(title: "Media Messages", message:nil , preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Default) {
            action  in
            view.dismissViewControllerAnimated(true, completion: nil)
        }
        let photo = UIAlertAction(title: "Send Photo",style: .Default) {
            action in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
            
        }
        view.addAction(photo)
        view.addAction(cancel)
        self.presentViewController(view, animated: true, completion: nil)
    }
    
    func didDownloadImage() {
        self.messages = CoreDataManager.sharedInstance.get_messages(self.conversationId)!
        dispatch_async(dispatch_get_main_queue()) {
           
            self.collectionView?.reloadData()
            self.scrollToBottomAnimated(true)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        Connection.sharedInstance.sendMessage(self.conversationId, content:"",image:image,sendToFriend: self.friend!["id"]!) {
            newMsg in
            dispatch_async(dispatch_get_main_queue()) {
                if newMsg?.mediaMessage != false {
                    self.messages.append(newMsg!)
                    self.finishSendingMessage()
                }
                JSQSystemSoundPlayer.jsq_playMessageSentSound()

            }
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
       

        
    }
    func didUploadImage(success: Bool) {
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    

        
    
        
        
        
    
    
    
    
    
    

    func didReceiveMessages(message: Message?,count:Int?) {
        if let newMsg = message {
            if newMsg.conversationID == self.conversationId {
                self.messages.append(newMsg)
                self.finishReceivingMessage()
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                CoreDataManager.sharedInstance.update_conversation(self.conversationId)
                self.scrollToBottomAnimated(true)
            } else {
                audioPlayer?.play()
                
            }
        }
    }
    
    
    func didReceiveFriendUpdate(action: String) {
        
    }

    
    func setupAvatarImage(name: String,incoming: Bool) {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)

       
        Connection.sharedInstance.getProfile(name) {
            image in
            
            dispatch_async(dispatch_get_main_queue()) {
                if let imageReceived = image {
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(imageReceived,diameter: diameter)
                    self.avatars[name] = avatarImage
                    self.collectionView?.reloadData()
                    return
                }
            }
        }
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profile"), diameter: diameter)
        self.avatars[name] = defaultAvatar

    }
    
     
        


    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
    
        let message = messages[indexPath.item]

        if let avatar = avatars[message.senderId()] { //if avator is already set up
            return avatar
        } else {
            setupAvatarImage(message.senderId(),incoming: true)
            return avatars[message.senderId()]
      
        }
        
        
    
    }


    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        Connection.sharedInstance.sendMessage(self.conversationId, content: text,image:nil,sendToFriend: self.friend!["id"]!) {
            newMsg in
   
            if newMsg != nil {
                
                self.messages.append(newMsg!)
                self.finishSendingMessage()
            }
        }
    }
    
    

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {

        let message = self.messages[indexPath.item]
        return message
        
    
    }
    
   
    

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
    
        let message = messages[indexPath.item]
        
        
        if message.senderId() == self.senderId {
            return outgoingBubble
        }
        return incomingBubble
    }
    
  
    
    //show timestamp for every 3rd message
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date())
        }
        return nil
        
    }
    
    //show username
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        
        if groupChat {
      
            let message = messages[indexPath.item];
            
            // Sent by me, skip
            if message.senderId() == self.senderId {
                
                return nil;
            }
            
            // Same as previous sender, skip
            if indexPath.item > 0 {
                let previousMessage = messages[indexPath.item - 1];
                if previousMessage.senderId() == message.senderId() {
                    return nil;
                }
            }
          
            return NSAttributedString(string:message.senderDisplayName())
            
        } else {
            return nil
        }
        
        
    }
    
    
    

    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let msg = self.messages[indexPath.item]
//        print("msg text: \(msg.content)")
       
        if !msg.isMediaMessage() {
            if msg.senderId() == self.senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
            let attribute: [String: AnyObject] = [NSForegroundColorAttributeName: (cell.textView?.textColor)! ,NSUnderlineStyleAttributeName:1]
            cell.textView!.linkTextAttributes = attribute
        }
        return cell
        
    
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0 
    }
    
    
    func didReceiveConversation() {
        
        audioPlayer?.play()
                
        
    }
       
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        
        if groupChat {
            let message = messages[indexPath.item]
            
            
            if message.senderId() == self.senderId{ //sent by me skip
                return CGFloat(0.0);
            }
            
            // Same as previous sender, skip
            if indexPath.item > 0 {
                let previousMessage = messages[indexPath.item - 1];
                if previousMessage.senderId() == message.senderId() {
                    return CGFloat(0.0);
                }
            }
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
            
            
            
            
        } else {
            return CGFloat(0.0)
        }
       
    }

    
  
   
    
    
    
    

    
    
    
    
}
