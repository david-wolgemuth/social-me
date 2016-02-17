//
//  Message+CoreDataProperties.swift
//  Social
//
//  Created by Shuhan Ng on 2/15/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var sent_received_date: NSDate?
    @NSManaged var senderUsername: String?
    @NSManaged var senderID: String?
    @NSManaged var context: String?
    @NSManaged var receiverID: String?

}
