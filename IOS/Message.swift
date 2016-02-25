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
        conversationID: String,senderDisplayName: String,createdAt: String) {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.senderID = senderID
            self.senderHandle = senderDisplayName
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            self.timestamp = dateFormatter.dateFromString(createdAt)
            self.content = text
            self.conversationID = conversationID
            
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
        return false
    }
    
    func messageHash() -> UInt {
        let contentHash = self.content?.hash
        return UInt(abs(contentHash!))
    }
    
    func text() -> String! {
        return self.content
    }


}
