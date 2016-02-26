//
//  Connection.swift
//  Social
//
//  Created by Shuhan Ng on 2/8/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import Foundation
import KeychainSwift
import CoreData


protocol ConnectionSocketDelegate {
    func didReceiveMessages(message: Message?,count:Int?)
   func didReceiveFriendUpdate(action: String)
}

protocol ConnectionLoginDelegate {
    func didLogin(success: Bool)
}

protocol ConnectionRegisterDelegate {
    func didRegister(success:Bool)
}

protocol ConnectionAddFriendDelegate {
    func didFindFriend(success: Bool,friendFound: [Dictionary<String,AnyObject>]?)
    func didSuccessSendRequest(success: Bool,error:String?)
}




class Connection {
    
    static let sharedInstance = Connection()
    private var socket: SocketIOClient
    
    private var friendRequest = [Dictionary<String,String>]()
    private var Friends = [Dictionary<String,String>]()
    
    private var getFriendAlready = false
    private var getFriendRequestAlready = false
 
    
    var delegate: ConnectionSocketDelegate?
    var loginDelegate: ConnectionLoginDelegate?
    var RegisterDelegate: ConnectionRegisterDelegate?
    var addFriendDelegate: ConnectionAddFriendDelegate?
    private var url: String
    
    var listeners = [String]();
    
    private init() {
        url = "http://ShuHans-MacBook-Air.local:5000"
        socket = SocketIOClient(socketURL: url)
        socket.connect()
        socket.on("connect") { data, ack in
            print("IOS::: WE ARE USING SOCKETS!!!")
        }
    }
    
    func logout(didLogOut:(success:Bool)->()) {
        if let urlToReq = NSURL(string: url + "/logout") {
            if let _ = NSData(contentsOfURL: urlToReq) {
                didLogOut(success: true)
                self.getFriendAlready = false
                self.getFriendRequestAlready = false
                self.Friends = []
                self.friendRequest = []
                socket.removeAllHandlers()
                
            } else {
                didLogOut(success: false)
            }
            
        }
        
    }
    
    


    
    func login(email:String,password:String){

        if let urlToReq = NSURL(string: url + "/login") {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            let bodyData = "user=\(email.trim())&password=\(password)"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) {
                (data,response,error) in
                
                dispatch_sync(dispatch_get_main_queue()) {
                    if let found_data = data {
                        if let userInfo = self.parseJSON(found_data) {
                            if let user = userInfo["user"] {
                                if let _ = user!["_id"] {
                                    let userId = user!["_id"]!
                                    let prefs = NSUserDefaults.standardUserDefaults()
                                    let keychain = KeychainSwift()
                                    var setValue: Bool = false
                                    if let saved_userId = prefs.stringForKey("id") {//we have a saved user
                                        if saved_userId != userId as! String{
                                            CoreDataManager.sharedInstance.overwrite_user()
                                            setValue = true
                                        }
                                    
                                    } else {
                                        setValue = true
                                    }
                                    if setValue {
                                        prefs.setValue(userId as! String,forKey: "id")
                                        prefs.setValue(email,forKey:"user")
                                        keychain.set(password,forKey: "password")
                                    }
                                    self.loginDelegate?.didLogin(true)
                                    self.socket.emit("loggedIn",userId as! String)
                                } else {
                                    self.loginDelegate?.didLogin(false)
                                }
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    

    func register(email:String,username:String,password:String,profilePic: UIImage?) {
        if let urlToReq = NSURL(string: url+"/users") {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL:urlToReq)
            request.HTTPMethod = "POST"
            let userData: NSMutableDictionary = ["email": email, "handle": username, "password":password,"image":""]
            if let image = profilePic {
                let data = UIImageJPEGRepresentation(image, 0.1)
                let imageData = data?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                userData.setValue(imageData, forKey: "image")
            }
            var userJsonData: NSData?
            do {
                userJsonData = try NSJSONSerialization.dataWithJSONObject(userData, options: NSJSONWritingOptions.PrettyPrinted)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(NSString(format: "%lu", userJsonData!.length) as String, forHTTPHeaderField: "Content-Length")
                request.HTTPBody = userJsonData!
                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                let task = session.dataTaskWithRequest(request) {
                    (data,response,error) in
                     dispatch_sync(dispatch_get_main_queue()) {
                        if let found_data = data {
                            if let message = self.parseJSON(found_data) {
                                if let success = message["success"] {
                                    if (success! as! Int == 1) {             
                                        self.RegisterDelegate?.didRegister(true)
                                    } else {
                                        self.RegisterDelegate?.didRegister(false)
                                    }
                                }
                            }
     
                        }
                    }
                }
                task.resume()
            } catch let error {
                print("error in converting into JSON object :\(error)")         
            }
        }
        
    }

    func parseJSON(inputData: NSData) -> AnyObject? {
        var arrOfObjects: AnyObject?
        do {
            arrOfObjects = try NSJSONSerialization.JSONObjectWithData(inputData, options: .MutableContainers)
        } catch {
            return nil
        }
        return arrOfObjects
    }
    
    
    func FindFriend(friend: String) {
        var friendResult: Array = [Dictionary<String,AnyObject>]()
        if let urlToReq = NSURL(string: url + "/friends?user=" + friend) {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let userInfo = self.parseJSON(data) {
                    let userArray = userInfo as! NSArray
                    for var i = 0; i < userArray.count; i++ {
                        let user = userArray[i]
                 
                        friendResult.append(["id":user["_id"]!!,"handle":user["handle"]!!,"isFriend":user["isFriend"]!!, "requestSent":user["requestSent"]!!])
                        
                    }
                    self.addFriendDelegate?.didFindFriend(true,friendFound: friendResult)
                } else {
                    self.addFriendDelegate?.didFindFriend(false,friendFound:nil)
                }
            }
            
        }
        
    }

    func getFriendRequestCount() -> Int {
        if !self.getFriendRequestAlready {
             self.checkFriendRequest()
        }
        return self.friendRequest.count
    }
    
    func getFriendRequest()->[Dictionary<String,String>] {
        if !getFriendRequestAlready {
            self.checkFriendRequest()
        }
        return self.friendRequest
    }
    
    func getFriends() -> [Dictionary<String,String>] {
        if !getFriendAlready {
            self.checkFriend()
        }
        return self.Friends
    }
    
    func checkFriend() {
    
        
        if let urlToReq = NSURL(string: url + "/friends") {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let friends = self.parseJSON(data) as? [AnyObject] {
                    for friend in friends {
                        self.Friends.append(["id":friend["_id"]! as! String, "handle": friend["handle"]! as! String])
                    }
                }
                self.getFriendAlready = true
            }
        }
    }
    
    
    
    
    func addFriend(friend: String) {
        if let urlToReq = NSURL(string: url+"/friends") {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            let bodyData = "id=\(friend)"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) {
                (data,response,error) in
                dispatch_sync(dispatch_get_main_queue()) {
                    if let found_data = data {
                        if let message = self.parseJSON(found_data) {
                            if let success = message["success"] {
                                if (success! as! Int == 1) {
                                    self.addFriendDelegate?.didSuccessSendRequest(true,error: nil)
                                } else {
                                    let error = message["error"]
                                    self.addFriendDelegate?.didSuccessSendRequest(false, error: error! as? String)
                                }
                            }
                        }
                        
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func respondFriend(Index: Int,accept: Bool,didRespondRequest:(success:Bool,error: String?)->()) {
        let FriendId = self.friendRequest[Index]["id"]!
        if let urlToReq = NSURL(string: self.url + "/friends/" + FriendId) {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "PUT"
            let bodyData = "confirmed=\(accept)"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) {
                (data,response,error) in
                dispatch_sync(dispatch_get_main_queue()) {
                    if let found_data = data {
                        if let message = self.parseJSON(found_data) {
                            if let success = message["success"] {
                                if (success! as! Int == 1) {
                                    if (accept == true) {
                                        self.Friends.append(["id":FriendId,"handle":self.friendRequest[Index]["handle"]!])
                                    }
                                    self.friendRequest.removeAtIndex(Index)
                                    didRespondRequest(success: true,error:nil)
                                } else {
                                    let error = message["error"]
                                    didRespondRequest(success: false,error: error! as? String)
                                }
                            }
                        }
                        
                    }
                }

            }
            task.resume()
        }
    }
    
    func checkFriendRequest() {
        if let urlToReq = NSURL(string: url + "/friends/requests") {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let requests = self.parseJSON(data) as? [AnyObject] {
                    if requests.count > 0 {
                        for friends in requests {
                            self.friendRequest.append(["id":friends["_id"]! as! String,"handle": friends["handle"]! as! String])
                        }
                        
                    }
                }
                self.getFriendRequestAlready = true
                
            }
        }
    }
    
    func getFriendInConversation(users: NSArray) -> String{
        var returnString = ""
        for var i = 0; i < users.count; i++ {
            if users[i] as! String != NSUserDefaults.standardUserDefaults().stringForKey("id")! {
                let userId = users[i] as! String
                if returnString == "" {
                    returnString += userId
                    
                } else {
                    returnString += "," + userId
                }
              
                
            }
        }
        return returnString
    }
    
    func getConversation() {
        var count = 0
        if let urlToReq = NSURL(string: url+"/history") {
       
            if let data = NSData(contentsOfURL: urlToReq) {
                if let info = self.parseJSON(data) as? NSArray{
                    for var i = 0; i < info.count; i++ {
                        let convoId = info[i]["_id"] as! String
                        let savedConvo = CoreDataManager.sharedInstance.GetConversationById(convoId)
                        let friendId = getFriendInConversation(info[i]["users"] as! NSArray)
                        
                        var writeToCoreData: Bool = false
                        if savedConvo?.count == 0 { //newConvo
                            CoreDataManager.sharedInstance.create_conversation(convoId, friendId: friendId)
                            writeToCoreData = true
                        } else {
                            let conversation = savedConvo![0]
                            if let unread = conversation.unreadMsg {
                                count += Int(unread)!
                            }
                            var lastUpdateCoreData = conversation.updatedAt
                            let lastUpdateServerString = info[i]["updatedAt"] as! String
                            let lastUpdateServer = lastUpdateServerString.toNSDate()
                            if let lastUpdate = lastUpdateCoreData {
                                if lastUpdate.compare(lastUpdateServer) != NSComparisonResult.OrderedSame {
                                    writeToCoreData = true
                                }
                            }
                        }
                        if writeToCoreData { //new message since user offline
                            let convo = info[i]["messages"] as? NSArray
                            
                            var newMessage = CoreDataManager.sharedInstance.get_messages(convoId)
                         
                            if let savedMsg = newMessage {
                                print("saveMsg count: \(savedMsg.count)")
                                print("convo count: \(convo!.count)")
                                for (var i = savedMsg.count; i < convo!.count ; i++) {
                                    let message = convo![i]
                                    var newMsg: Message? = CoreDataManager.sharedInstance.add_message(message["content"]! as! String, senderId: message["_user"]!!["_id"]! as! String, senderHandle: message["_user"]!!["handle"]! as! String, conversationId: convoId, createdAt: message["createdAt"]! as! String)
                                    if newMsg != nil {
                                        count += 1
                                        CoreDataManager.sharedInstance.create_conversation(convoId, friendId: friendId, lastMsg: newMsg!.content!, updatedAt: newMsg!.timestamp!, unreadMsg: "1")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        delegate?.didReceiveMessages(nil,count:count)
    }
    
    
    
    func showConversation(friendId: String, loadedMsg: (ConversationId: String ,Message: [Message]?) -> ()) {
        var newMessage: [Message]?
        if let urlToReq = NSURL(string: url+"/friends/"+friendId) {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let info = self.parseJSON(data) {
                    newMessage = CoreDataManager.sharedInstance.get_messages(info["conversation"]!!["_id"]! as! String)
//                    if let savedMsg = newMessage {
//                        let convo = info["conversation"]!!["messages"] as? NSArray
//                        if let conversation = convo { //new msg since user offline
//                            for (var i = savedMsg.count; i < conversation.count ; i++) {
//                                let message = conversation[i]
//                                var newMsg: Message? = CoreDataManager.sharedInstance.add_message(message["content"]! as! String, senderId: message["_user"]!!["_id"]! as! String, senderHandle: message["_user"]!!["handle"]! as! String, conversationId: info["conversation"]!!["_id"]! as! String, createdAt: message["createdAt"]! as! String)
//                                if newMsg != nil {
//                                    newMessage!.append(newMsg!)
//                                    CoreDataManager.sharedInstance.create_conversation(info["conversation"]!!["_id"] as! String, friendId: friendId, lastMsg: newMsg!.content!, updatedAt: newMsg!.timestamp!, unreadMsg: "1")
//                                    
//                                }
//                            }
//                            
//                        }
//                    }
                    loadedMsg(ConversationId: info["conversation"]!!["_id"]! as! String,Message: newMessage)
                }
            }
        }
    }
    
  

    
    func listenForMessages() {
        socket.on("newMessage") {data, ack in
            print("Connection::: got message")
            let msg = self.get_message(data[0]["message"]! as! String)
            self.delegate?.didReceiveMessages(msg,count:nil)
   
        }
    }
    
    
    func get_message(messageId: String) -> Message? {
        var receiveMsg: Message?
        if let urlToReq = NSURL(string: url+"/messages/"+messageId) {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let info = self.parseJSON(data) {
                    if info["_user"]!!["_id"]! as? String != NSUserDefaults.standardUserDefaults().stringForKey("id") { //i did not send the message
                        receiveMsg = CoreDataManager.sharedInstance.add_message(info["content"]! as! String, senderId: info["_user"]!!["_id"]! as! String, senderHandle: info["_user"]!!["handle"]! as! String, conversationId: info["_conversation"]! as! String, createdAt: info["createdAt"]! as! String)
                        if receiveMsg != nil {
                            CoreDataManager.sharedInstance.create_conversation(receiveMsg!.conversationID!, friendId:info["_user"]!!["_id"]! as! String, lastMsg: receiveMsg!.content!, updatedAt: receiveMsg!.timestamp!, unreadMsg: "1")
                        }
                    }
                }
            }
        }
        
        return receiveMsg
        
    }
    
    func getFriendUserName(FriendId: String)-> String {
        for (var i = 0; i < self.Friends.count; i++) {
            if self.Friends[i]["id"] == FriendId {
                return self.Friends[i]["handle"]!
            }
        }
        return ""
    }
    

    
    
    func sendMessage(conversationId: String,content: String,sendToFriend: String,didSuccessSendMsg:(newMessage: Message?)->()) {
        
        if let urlToReq = NSURL(string: url+"/messages") {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            let bodyData = "conversationId=\(conversationId)&content=\(content)"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) {
                (data,response,error) in
                dispatch_sync(dispatch_get_main_queue()) {
                    if let found_data = data {                        
                        if let message = self.parseJSON(found_data) {
                            var newMsg = CoreDataManager.sharedInstance.add_message(message["content"]! as! String, senderId: message["_user"]!!["_id"]! as! String, senderHandle: message["_user"]!!["handle"]! as! String, conversationId: message["_conversation"]! as! String, createdAt: message["createdAt"]! as! String)
                            if (newMsg !== nil ) {
                                CoreDataManager.sharedInstance.create_conversation(conversationId, friendId: sendToFriend, lastMsg: newMsg!.content!, updatedAt: newMsg!.timestamp!, unreadMsg: "0")
                            }
                       
                            didSuccessSendMsg(newMessage: newMsg)
                        }
                        
                    }
                }
            }
            task.resume()
        }
    }

    func listenForFriendUpdate() {
        socket.on("friendRequest") {
            data, ack in
            print("get friend request")
            let user = data[0]["user"]
            self.friendRequest.append(["id":user!!["_id"]! as! String,"handle":user!!["handle"]! as! String])
            self.delegate?.didReceiveFriendUpdate("Request")
        }
        socket.on("friendAccepted") {
            data, ack in
            print("get new friend accept")
            let user = data[0]["user"]
            self.Friends.append(["id": user!!["_id"]! as! String, "handle":user!!["handle"]! as! String])
            self.delegate?.didReceiveFriendUpdate("Accepted")
        }
    }

}
