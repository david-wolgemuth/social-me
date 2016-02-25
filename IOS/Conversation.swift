//
//  Conversation.swift
//  Social
//
//  Created by Shuhan Ng on 2/23/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import Foundation
import CoreData


class Conversation: NSManagedObject {

    convenience init(entity: NSEntityDescription,insertIntoManagedObjectContext context:NSManagedObjectContext, id:String,updatedAt: NSDate?,lastMsg: String?,friendId: String?,unreadMsg: String?) {
        self.init(entity: entity,insertIntoManagedObjectContext: context)
        self.id = id
        if updatedAt != nil {
            self.updatedAt = updatedAt
            
        }
        if lastMsg != nil {
            self.lastMessage = lastMsg
            
        }
        if friendId != nil {
            self.friendId = friendId
        }
        if unreadMsg != nil {
            self.unreadMsg = unreadMsg
        }
    }

}
