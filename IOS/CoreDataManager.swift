//
//  CoreDataManager.swift
//  
//
//  Created by Shuhan Ng on 2/8/16.
//
//

import CoreData
import Foundation


class CoreDataManager {
    static let sharedInstance = CoreDataManager()
    
    private var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    private var Entities: [NSEntityDescription?]
    private var Requests: [NSFetchRequest?]
    
    private init() {
        Entities = [NSEntityDescription.entityForName("Message", inManagedObjectContext:managedObjectContext),NSEntityDescription.entityForName("Friend", inManagedObjectContext:managedObjectContext)]
        
        Requests = [NSFetchRequest(entityName:"Message"),NSFetchRequest(entityName:"Friend")]
     
    }
    
   
    func overwrite_user() {
     
        self.deleteAllMessages()
    }

   

    func get_messages(friend_id: String) -> [Message]? {
        var messages: [Message]?
        let predicate = NSPredicate(format: "(senderID == %@) OR (receiverID == %@)", friend_id,friend_id)
        Requests[0]?.predicate = predicate
        do {
            messages = try managedObjectContext.executeFetchRequest(Requests[1]!) as? [Message]
        } catch let error {
            print("error in fetching messages : \(error)")
        }
        return messages
        
    }
    


    
    
    
    
    func add_message(messageText: String,senderID: String, senderDisplayName: String!,receiverID: String)->Message? {
        let newMessage = Message(entity: Entities[1]!, insertIntoManagedObjectContext: managedObjectContext, text: messageText, senderID: senderID, receiverID: receiverID, senderDisplayName: senderDisplayName)
        do {
            try self.managedObjectContext.save()
            return newMessage
            
        } catch let error {
            print("error in adding new message to core data: \(error)")
            return nil
        }
        
    }
 
    
    func deleteAllMessages() {
        Requests[0]!.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: Requests[1]!)
        do {
            try self.managedObjectContext.executeRequest(deleteRequest)
            print("success in deleting messages")
            
            
        } catch let error {
            print("error in deleting messages: \(error)")
        }
    }
    
   
    
    
  
    
   
    
    
    
    
    
    
    
}
