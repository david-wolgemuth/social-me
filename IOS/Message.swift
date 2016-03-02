//
//  Message.swift
//  Social
//
//  Created by Shuhan Ng on 2/23/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import Foundation
import CoreData
import JSQMessagesViewController


class Message: NSManagedObject,JSQMessageData {

    convenience init(entity: NSEntityDescription,insertIntoManagedObjectContext context:NSManagedObjectContext,text:String,senderID: String,
        conversationID: String,senderDisplayName: String,createdAt: String,messageId: String, isMediaMessage: Bool,media: NSData?) {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.senderID = senderID
            self.senderHandle = senderDisplayName
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            self.timestamp = dateFormatter.dateFromString(createdAt)
            self.content = text
            self.conversationID = conversationID
            self.messageID = messageId
            self.mediaMessage = isMediaMessage
            self.mediaData = media
            
    }

    func senderId() -> String! {
        return self.senderID
    }
    
    func senderDisplayName() -> String! {
        return self.senderHandle
    }
    
    
    func date() -> NSDate! {
        return self.timestamp
    }
    
    func isMediaMessage() -> Bool {
        return self.mediaMessage as! Bool
    }
    
    
    func messageHash() -> UInt {
        let contentHash = self.isMediaMessage() ? self.messageID?.hashValue : self.content?.hash
        return UInt(abs(self.senderID!.hash ^ self.timestamp!.hash ^ contentHash!))
        
        
     
        
        
    }
    
    func text() -> String! {
        return self.content
    }
    
    
    func media() -> JSQMessageMediaData? {
        if let media = self.mediaData {
            let imageUI = UIImage(data: media)
            let photoItem: JSQPhotoMediaItem = JSQPhotoMediaItem(image: imageUI)
            if self.senderId() != NSUserDefaults.standardUserDefaults().stringForKey("id") {
                photoItem.appliesMediaViewMaskAsOutgoing = false
            }
           
            return photoItem
        } else {
            return nil
        }
    }
    
    
   
    

    
  
    


}
