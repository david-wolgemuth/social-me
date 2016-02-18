//
//  Friend+CoreDataProperties.swift
//  Social
//
//  Created by Shuhan Ng on 2/17/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Friend {

    @NSManaged var id: String?
    @NSManaged var username: String?

}
