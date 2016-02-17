//
//  Message.swift
//  Social
//
//  Created by Shuhan Ng on 2/15/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import Foundation
import CoreData
import JSQMessagesViewController


class Message: NSManagedObject,JSQMessageData {
    
    convenience init(entity: NSEntityDescription,insertIntoManagedObjectContext context:NSManagedObjectContext,text:String,senderID: String,
        receiverID: String,senderDisplayName: String) {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.senderID = senderID
            self.senderUsername = senderDisplayName
            self.sent_received_date = NSDate()
            self.context = text
            self.receiverID = receiverID
        
            
    }
    
    
    
    
    func senderId() -> String! {
        return self.senderID
    }
    
    func senderDisplayName() -> String! {
        return self.senderUsername
    }
    
    
    func date() -> NSDate! {
        return self.sent_received_date
    }
    
    func isMediaMessage() -> Bool {
        return false
    }
    
    func messageHash() -> UInt {
        let contentHash = self.context?.hash
        return UInt(abs(contentHash!))
    }
    
    func text() -> String! {
        return self.context!
    }
    
    
 
    
    
    


}


