//
//  Message.swift
//  Social
//
//  Created by Shuhan Ng on 2/17/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import Foundation
import CoreData


class Message: NSManagedObject {

    convenience init(entity: NSEntityDescription,insertIntoManagedObjectContext context:NSManagedObjectContext,text:String,senderID: String,
        receiverID: String,senderDisplayName: String) {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.senderID = senderID
            self.senderUsername = senderDisplayName
            self.timestamp = NSDate()
            self.content = text
            self.receiverID = receiverID
            
    }
    
    
    
    func senderId() -> String! {
        return self.senderID
    }
    
    func senderDisplayName() -> String! {
        return self.senderUsername
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
