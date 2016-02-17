//
//  CoreDataManager.swift
//  
//
//  Created by Shuhan Ng on 2/8/16.
//
//

import CoreData
import Foundation
import KeychainSwift

class CoreDataManager {
    static let sharedInstance = CoreDataManager()
    
    private var user: User?
    private var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    private var keychain: KeychainSwift
    
    private var friends: [Friend]?
    
    private var Entities: [NSEntityDescription?]
    private var Requests: [NSFetchRequest?]
    
    private var overwrite: Bool = false

    

    private init() {
    
        
        keychain = KeychainSwift()
 
      
        Entities = [NSEntityDescription.entityForName("User", inManagedObjectContext:managedObjectContext),NSEntityDescription.entityForName("Message", inManagedObjectContext:managedObjectContext),NSEntityDescription.entityForName("Friend", inManagedObjectContext:managedObjectContext)]
        
        Requests = [NSFetchRequest(entityName:"User"),NSFetchRequest(entityName:"Message"),NSFetchRequest(entityName:"Friend")]
    
        
        var users : [NSManagedObject]?
        do {
            users = try managedObjectContext.executeFetchRequest(Requests[0]!) as? [User]
            
            if users!.count > 0 {
                user = users![0] as? User
            }
   
 
        } catch let error {
            print("errors in fetching users.. \(error)")
        }
        
        do{
            friends = try managedObjectContext.executeFetchRequest(Requests[2]!) as? [Friend]
            
  
        } catch let error {
            print("error in fetching friends....\(error)")
        }

  
    }
    
    func get_overwrite() -> Bool {
        return overwrite
        
    }

    
    func get_user() -> User? {
        return user
    }
    
    
    func get_friends() -> [Friend]? {
        return friends
    }
    
    func get_messages(friend_id: String) -> [Message]? {
        var messages: [Message]?
        let predicate = NSPredicate(format: "(senderID == %@) OR (receiverID == %@)", friend_id,friend_id)
        Requests[1]?.predicate = predicate
        do {
            messages = try managedObjectContext.executeFetchRequest(Requests[1]!) as? [Message]
        } catch let error {
            print("error in fetching messages : \(error)")
        }
        return messages
        
    }
    


    
    
    func add_friend(friend_arr: [AnyObject]) {

        for index in 0..<friend_arr.count {
            let friendToSave =  NSManagedObject(entity: Entities[2]!, insertIntoManagedObjectContext: self.managedObjectContext)
            
            let id = friend_arr[index]["_id"] as? String

            let username = friend_arr[index]["username"] as? String
            friendToSave.setValue(id,forKey: "id")
            friendToSave.setValue(username, forKey:"username")
            do {
                try self.managedObjectContext.save()
                friends?.append((friendToSave as? Friend)!)
            } catch let error {
                print("error in saving user to coredata:: \(error)")
            }
         
        }
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
    

        

    
    
    
    
    
    
    

    func password() -> String? {
        return keychain.get("password")
        
    }
    
    func saveUser(id:String,email:String,password:String) {
        var userToSave: NSManagedObject? = NSManagedObject(entity: Entities[0]!, insertIntoManagedObjectContext: self.managedObjectContext)
        if self.user != nil { //we saved a user before
            if email != self.user!.email {
                userToSave = user
                self.deleteAllFriends()
                self.deleteAllMessages()
                overwrite = true
            } else {
                userToSave = nil
            }
            
        } else {
            overwrite = true
        }
        
        
        userToSave?.setValue(email,forKey: "email")
        userToSave?.setValue(id,forKey: "id")
        if userToSave != nil {
            keychain.set(password,forKey:"password")
            do {
                try self.managedObjectContext.save()
                user = userToSave as? User
                
            } catch let error {
                print("error in saving user to coredata:: \(error)")
            }
        }
        
        
    }
    
    
    func deleteAllMessages() {
     
        Requests[1]!.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: Requests[1]!)
        do {
            try self.managedObjectContext.executeRequest(deleteRequest)
            print("success in deleting messages")
            
            
        } catch let error {
            print("error in deleting messages: \(error)")
        }
        
        
    }
    
    func deleteAllFriends() {
        
   
        Requests[2]!.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: Requests[2]!)
        do {
            try self.managedObjectContext.executeRequest(deleteRequest)
            self.friends = []
            print("success in deleting friends")
            
        } catch let error {
            print("error in deleting friends: \(error)")
        }
        
    }
    
    
    
  
    
   
    
    
    
    
    
    
    
}
