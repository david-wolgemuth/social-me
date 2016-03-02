//
//  Message+CoreDataProperties.swift
//  Social
//
//  Created by Shuhan Ng on 2/26/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var content: String?
    @NSManaged var conversationID: String?
    @NSManaged var mediaData: NSData?
    @NSManaged var mediaMessage: NSNumber?
    @NSManaged var messageID: String?
    @NSManaged var senderHandle: String?
    @NSManaged var senderID: String?
    @NSManaged var timestamp: NSDate?

}
