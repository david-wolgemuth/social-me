//
//  CoreDataManager.swift
//  
//
//  Created by Shuhan Ng on 2/8/16.
//
//

import CoreData
import Foundation


extension String{
    func toNSDate() -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(self)!
        
    }
}

class CoreDataManager {
    static let sharedInstance = CoreDataManager()
    
    private var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext


    
    private init() {
     
    }
    
   
    func overwrite_user() {
     
        self.deleteAllMessages()
        self.deleteAllConversation()
    }

   

    func get_messages(conversationId: String) -> [Message]? {
        var messages = [Message]()
        let predicate = NSPredicate(format: "(conversationID == %@)", conversationId)
        let request = NSFetchRequest(entityName: "Message")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        do {
            messages = try managedObjectContext.executeFetchRequest(request) as! [Message]
     
            return messages
        } catch let error {
            print("error in fetching messages : \(error)")
        }
        return nil
        
    }
    
    
    
    func add_message(messageId: String,messageText: String,senderId: String,senderHandle: String, conversationId: String,createdAt:String)-> Message? {
        
        
        let newMessage = Message(entity: NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext)!,insertIntoManagedObjectContext: self.managedObjectContext,text: messageText,senderID: senderId,conversationID: conversationId,senderDisplayName: senderHandle,createdAt: createdAt,messageId:messageId,isMediaMessage: false,media: nil)
    
        do {
            try self.managedObjectContext.save()
            return newMessage
        } catch let error {
            print("error in adding new message to core data: \(error)")
            
        }
        return nil
    }
    
    
    func update_message(messageId: String,media: UIImage) {
        var imageData: NSData?
        
        imageData = UIImagePNGRepresentation(media)
   
        
        let predicate = NSPredicate(format: "(messageID == %@)", messageId)
        let request = NSFetchRequest(entityName: "Message")
        request.predicate = predicate
        var message: [Message]
        do {
            message = try self.managedObjectContext.executeFetchRequest(request) as! [Message]
            if message.count != 0 {
                message[0].mediaMessage = true
                message[0].mediaData = imageData
            }
            do {
                try self.managedObjectContext.save()
            } catch let error {
                print("error in saving convo: \(error)")
            }
            
        } catch let error {
            print("error in update message :\(error)")
        }
        
    }
    
    func update_conversation(id: String) { //setting unread msg = '0'
        let predicate = NSPredicate(format: "(id == %@)", id)
        let request = NSFetchRequest(entityName: "Conversation")
        request.predicate = predicate
        var conversation: [Conversation]
        do {
            conversation = try self.managedObjectContext.executeFetchRequest(request) as! [Conversation]
            if conversation.count != 0 { //conversation id already exists
                conversation[0].unreadMsg!  = "0"
            }
            do {
                try self.managedObjectContext.save()
            } catch let error {
                print("error in saving convo: \(error)")
            }
            
        } catch let error {
            print("error in fetching conversation :\(error)")
        }
    }
    
    
    func create_conversation(id:String,friendId:String) {
        let _ = Conversation(entity: NSEntityDescription.entityForName("Conversation", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext, id: id,updatedAt: nil,lastMsg: nil,friendId: friendId,unreadMsg: nil)
        do {
            try self.managedObjectContext.save()
        } catch let error {
            print("error in saving convo: \(error)")
        }
    }











    func create_conversation(id: String,friendId: String,lastMsg: String,updatedAt: NSDate,unreadMsg:String) {
        let predicate = NSPredicate(format: "(id == %@)", id)
        let request = NSFetchRequest(entityName: "Conversation")
        request.predicate = predicate
        var conversation = [Conversation]()
        do {
            conversation = try self.managedObjectContext.executeFetchRequest(request) as! [Conversation]
            if conversation.count != 0 { //conversation id already exists
                conversation[0].lastMessage = lastMsg
                conversation[0].updatedAt = updatedAt
                if unreadMsg == "0" {
                    conversation[0].unreadMsg!  = unreadMsg

                } else {
                    if (conversation[0].unreadMsg == nil) {
                        conversation[0].unreadMsg = "1"
                    } else {
                        conversation[0].unreadMsg! = String(Int(conversation[0].unreadMsg!)! + 1)
                    }
                    
                }
                
            } else {
                let _ = Conversation(entity: NSEntityDescription.entityForName("Conversation", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext, id: id,updatedAt: updatedAt,lastMsg: lastMsg,friendId: friendId,unreadMsg: unreadMsg)
            }
            do {
                try self.managedObjectContext.save()
            } catch let error {
                print("error in saving convo: \(error)")
            }
            
        } catch let error {
            print("error in fetching conversation :\(error)")
        }
    }
    
    
    
    

    
    func checkConversation()-> [Conversation] {
        var result = [Conversation]()
        let request = NSFetchRequest(entityName: "Conversation")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending:false)]
        do {
            result = try self.managedObjectContext.executeFetchRequest(request) as! [Conversation]
        } catch let error {
            print("error in fetching conversation: \(error)")
        }
        return result
        
        
    }
    
    func GetConversationById(id:String) -> [Conversation]? {
        let predicate = NSPredicate(format: "(id == %@)", id)
        let request = NSFetchRequest(entityName: "Conversation")
        request.predicate = predicate
        var conversation: Conversation?
        do {
            let conversationResult = try self.managedObjectContext.executeFetchRequest(request) as! [Conversation]
            return conversationResult
           
            
        } catch {
            return nil
            
            
        }
    }

    func deleteAllMessages() {
        let request = NSFetchRequest(entityName: "Message")
        request.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.managedObjectContext.executeRequest(deleteRequest)
            print("success in deleting messages")
            
            
        } catch let error {
            print("error in deleting messages: \(error)")
        }
    }
    
    func deleteAllConversation() {
        let request = NSFetchRequest(entityName: "Conversation")
        request.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.managedObjectContext.executeRequest(deleteRequest)
            print("success in deleting conversation")
        } catch let error {
            print("error in deleting conversation : \(error)")
        }

        
    }
    
   
    
    
  
    
   
    
    
    
    
    
    
    
}
