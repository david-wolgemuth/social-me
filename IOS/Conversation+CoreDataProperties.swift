//
//  Conversation+CoreDataProperties.swift
//  Social
//
//  Created by Shuhan Ng on 2/23/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Conversation {

    @NSManaged var friendId: String?
    @NSManaged var id: String?
    @NSManaged var lastMessage: String?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var unreadMsg: String?

}
