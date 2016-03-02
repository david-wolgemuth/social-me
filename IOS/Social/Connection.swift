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
    func didReceiveConversation()
}

protocol ConnectionLoginDelegate {
    func didLogin(success: Bool)
}

protocol ConnectionRegisterDelegate {
    func didRegister(success:Bool,error: String?)
}

protocol ConnectionAddFriendDelegate {
    func didFindFriend(success: Bool,friendFound: [Dictionary<String,AnyObject>]?)
    func didSuccessSendRequest(success: Bool,error:String?)
}

protocol ConnectionImageDelegate{
    func didUploadImage(success: Bool)
    func didDownloadImage()
    
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
    var imageDelegate: ConnectionImageDelegate?
    private var url: String
    
  
    
    private init() {
        url = "http://52.36.153.231"
//        url = "http://shuhan.local:5000"
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
    
    
    func getProfile(id: String,didGetImage:(imageGot: UIImage?)->()) {
        
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
            let urlString = self.url + "/images/profiles/\(id).jpeg"
            let urlToReq = NSURL(string: urlString)
            if let data = NSData(contentsOfURL: urlToReq!) {

                if let image = UIImage(data: data) {
                    didGetImage(imageGot: image)
                    return
                } else {
                    didGetImage(imageGot: nil)
                    return
                }

            } else {
                didGetImage(imageGot: nil)
            }
        }

    }
    
    func getMessageImage(id: String,didGetImage:(imageGot: UIImage?)->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
            let urlString = self.url + "/images/messages/\(id).jpeg"
            let urlToReq = NSURL(string: urlString)
            if let data = NSData(contentsOfURL: urlToReq!) {
                if let image = UIImage(data: data) {
                    didGetImage(imageGot: image)
                    return
                } else {
                    didGetImage(imageGot: nil)
                }
              
            } else {
                didGetImage(imageGot: nil)
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
            print("ready to log in..")
            let task = session.dataTaskWithRequest(request) {
                (data,response,error) in
                    print("get data back")
                    if let found_data = data {
                        if let userInfo = self.parseJSON(found_data) {
                            
//                            dispatch_async(dispatch_get_main_queue()) {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
                            if let user = userInfo["user"] {
                                print("here")
                                if let _ = user!["_id"] {
                                    let userId = user!["_id"]!
                                    let prefs = NSUserDefaults.standardUserDefaults()
                                    let keychain = KeychainSwift()
                                 
                                    if let saved_userId = prefs.stringForKey("id") {//we have a saved user
                                        if saved_userId != userId as! String{
                                            print("overwrite")
                                            dispatch_sync(dispatch_get_main_queue()) {
                                                CoreDataManager.sharedInstance.overwrite_user()
                                                
                                            }
                            
                                        }
                                    
                                    }
                                    prefs.setValue(userId as! String,forKey: "id")
                                    prefs.setValue(email,forKey:"user")
                                    prefs.setValue(user!["profileImage"],forKey:"profileImage")
                                    keychain.set(password,forKey: "password")
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.loginDelegate?.didLogin(true)
                                        
                                    }
                                    
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
                let imageData = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
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
              
                     dispatch_async(dispatch_get_main_queue()) {
                        if let found_data = data {
                            if let message = self.parseJSON(found_data) {
                                if let success = message["success"] {
                                    if (success! as! Int == 1) {             
                                        self.RegisterDelegate?.didRegister(true,error: nil)
                                    } else {
                                        self.RegisterDelegate?.didRegister(false,error: message["error"] as! String )
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
                        
                        var hasImage = "0"
                        if  user["profileImage"] as! Int == 1 {
                            hasImage = "1"
                        }
                        friendResult.append(["id":user["_id"]!!,"handle":user["handle"]!!,"isFriend":user["isFriend"]!!, "requestSent":user["requestSent"]!!,"profileImage":hasImage])
                        
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
              
                        var hasImage = "0"
                        if friend["profileImage"] as! Int == 1 {
                            hasImage = "1"
                        }
                        self.Friends.append(["id":friend["_id"]! as! String, "handle": friend["handle"]! as! String, "profileImage": hasImage])
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
             
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
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
    
    func makeTitle(users:[Dictionary<String,String>]) -> String {
        var title = ""
        for var i = 0; i < users.count; i++ {
            if i == 0 {
                title += users[i]["handle"]! as! String
               
            } else {
                 title += "," + (users[i]["handle"]! as! String)
            }
        }
        
        return title
        
        
    }
    
    func createGroupConversation(users:[Dictionary<String,String>], title: String?) {
        var usersToSend = Array<String>()
        for var i = 0; i < users.count; i++ {
            usersToSend.append(users[i]["id"]!)
        }
        
        var titleToSend = title!
        if titleToSend  == "" {
            self.makeTitle(users)
            titleToSend = self.makeTitle(users)
        }
    
        if let urlToReq = NSURL(string: url+"/conversations") {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            let userData: NSMutableDictionary = ["users":usersToSend,"title":titleToSend]
            var userJsonData: NSData?
            do {
                userJsonData = try NSJSONSerialization.dataWithJSONObject(userData, options: NSJSONWritingOptions.PrettyPrinted)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(NSString(format: "%lu", userJsonData!.length) as String, forHTTPHeaderField: "Content-Length")
                request.HTTPBody = userJsonData!
                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                let task = session.dataTaskWithRequest(request) {
                    data,response,error in
                    if let found_data = data {
                        if let JSON = self.parseJSON(found_data) {
                        }
                    }
                    
                }
                task.resume()
            } catch let error {
                print("error : \(error)")
            }
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
                dispatch_async(dispatch_get_main_queue()) {
                    if let found_data = data {
                        if let message = self.parseJSON(found_data) {
                            if let success = message["success"] {
                                if (success! as! Int == 1) {
                                    if (accept == true) {
                                        self.Friends.append(["id":FriendId,"handle":self.friendRequest[Index]["handle"]!,"profileImage":self.friendRequest[Index]["profileImage"]!])
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
                            var hasImage = "0"
                            if friends["profileImage"] as! Int == 1 {
                                hasImage = "1"
                            }
                            self.friendRequest.append(["id":friends["_id"]! as! String,"handle": friends["handle"]! as! String,"profileImage":hasImage])
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
            print("get conversation...")
            if let data = NSData(contentsOfURL: urlToReq) {
                if let info = self.parseJSON(data) as? NSArray{
                    for var i = 0; i < info.count; i++ {
                        let convoId = info[i]["_id"] as! String
                        let savedConvo = CoreDataManager.sharedInstance.GetConversationById(convoId)
                        let friendId = getFriendInConversation(info[i]["users"] as! NSArray)
                        var writeToCoreData: Bool = false
                        if savedConvo?.count == 0 { //newConvo
                            let date = info[i]["createdAt"] as! String
                            CoreDataManager.sharedInstance.create_conversation(convoId, friendId: friendId, lastMsg: "", updatedAt: date.toNSDate(), unreadMsg: "0")
                    
                            writeToCoreData = true
                        } else {
                            let conversation = savedConvo![0]
                            if let unread = conversation.unreadMsg {
                                count += Int(unread)!
                            }
                            var lastUpdateCoreData = conversation.updatedAt
                            let lastUpdateServerString = info[i]["updatedAt"] as! String
//                            print("conversation::: \(info[i])")
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
                         
                            if let savedMsg = newMessage{
                            
                      
                               
                                for (var i = savedMsg.count; i < convo!.count ; i++) {
                                    let message = convo![i]
                                    var hasImage: Bool = false
                                    if message["image"] as? Int == 1 {
                                        hasImage = true
                                    }
                                    if hasImage {
                                        let date = message["createdAt"] as! String
                                        
                                        CoreDataManager.sharedInstance.create_conversation(convoId, friendId: friendId, lastMsg:
                                        "[Picture]", updatedAt: date.toNSDate(), unreadMsg: "1")
                                        Connection.sharedInstance.getMessageImage(message["_id"]! as! String) {
                                            image in
                                            dispatch_async(dispatch_get_main_queue()) {
                                                if let imageReceived = image {
                                                    CoreDataManager.sharedInstance.update_message(message["_id"]! as! String, media: imageReceived)
                                                    self.imageDelegate?.didDownloadImage()
                                                }

                                                
                                                
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                    var content = message["content"] as? String
                                    if (content == nil) {
                                        content = ""
                                    }
                                    var newMsg = CoreDataManager.sharedInstance.add_message(message["_id"]! as! String,messageText:content!, senderId: message["_user"]!!["_id"]! as! String, senderHandle: message["_user"]!!["handle"]! as! String, conversationId: convoId,createdAt: message["createdAt"]! as! String)
                                    
                                    if newMsg != nil && !hasImage {
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
                    loadedMsg(ConversationId: info["conversation"]!!["_id"]! as! String,Message: newMessage)
                }
            }
        }
    }
    
    
    func Convert(dict: [Dictionary<String,AnyObject>]) -> [Dictionary<String,String>] {
        var returnDict = [Dictionary<String,String>]()
        for var i = 0; i < dict.count; i++ {
            returnDict.append(["id":dict[i]["_id"]! as! String,"handle":dict[i]["handle"]! as! String])
            
        
        }
        return returnDict
        
        
    }
    
    
    
    func showGroupConversation(convoId: String,loadedConvo:(title:String,Message: [Message]?)->()) {
        var newMessage: [Message]?
        if let urlToReq = NSURL(string: url+"/conversations/"+convoId) {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let info = self.parseJSON(data) as? NSDictionary {
                    newMessage = CoreDataManager.sharedInstance.get_messages(convoId)
                 
                    if info["title"] == nil {
                        let users = self.Convert((info["users"] as? [Dictionary<String,AnyObject>])!)
                        let Title = self.makeTitle(users)
                        loadedConvo(title: Title, Message: newMessage)
                        
                    } else {
                        loadedConvo(title: info["title"] as! String, Message: newMessage)
                    }
                    
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
                        var hasImage: Bool = false
                        if info["image"] as? Int == 1 {
                            hasImage = true
                
                        }
                        if hasImage {
                            let date = info["createdAt"]! as! String
                            CoreDataManager.sharedInstance.create_conversation(info["_conversation"]! as! String, friendId:info["_user"]!!["_id"]! as! String, lastMsg: "[Picture]", updatedAt:date.toNSDate() , unreadMsg: "1")
                            Connection.sharedInstance.getMessageImage(messageId) {
                                image in
                                    if let imageReceived = image {
                                        CoreDataManager.sharedInstance.update_message(messageId, media: imageReceived)
                                        self.imageDelegate?.didDownloadImage()
                                    }
                            }
                        }
                        print(info)
                        var content = info["content"] as? String
                        if content == nil {
                            content = ""
                        }
                        receiveMsg = CoreDataManager.sharedInstance.add_message(messageId,messageText: content!, senderId: info["_user"]!!["_id"]! as! String, senderHandle: info["_user"]!!["handle"]! as! String, conversationId: info["_conversation"]! as! String, createdAt: info["createdAt"]! as! String)
                        print(receiveMsg)
                        if receiveMsg != nil  && !hasImage{
                            CoreDataManager.sharedInstance.create_conversation(receiveMsg!.conversationID!, friendId:info["_user"]!!["_id"]! as! String, lastMsg: receiveMsg!.content!, updatedAt: receiveMsg!.timestamp!, unreadMsg: "1")
                        }
                     }
                }
            }
        }
        return receiveMsg
    }
    
 
    func getFriendUserName(FriendId: String)-> Dictionary<String,String> {
        var result = Dictionary<String,String>()
        for (var i = 0; i < self.Friends.count; i++) {
            if self.Friends[i]["id"] == FriendId {
                result["handle"] = self.Friends[i]["handle"]!
                result["profileImage"] = self.Friends[i]["profileImage"]!
             
            }
        }
        return result
    }
    
    func uploadImage(image: UIImage) {
        let id = NSUserDefaults.standardUserDefaults().stringForKey("id")
        if let urlToReq = NSURL(string: url+"/users/"+id!) {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "PUT"
            let userData: NSMutableDictionary = ["image":""]
            let data = UIImageJPEGRepresentation(image, 0.1)
            let imageData = data?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            userData.setValue(imageData, forKey: "image")
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
//                                print(message)
                                if let success = message["success"] {
                                    if (success! as! Int == 1) {
                                        self.imageDelegate?.didUploadImage(true)
                                    } else {
                                        self.imageDelegate?.didUploadImage(false)
                                    }
                                }
                            }
                            
                        }
                    }

                    
                }
                task.resume()
                
            } catch let error {
                print(error)
                self.imageDelegate?.didUploadImage(false)
                
            }
            
            
        }
        
    }
    
   
    func sendMessage(conversationId: String,content: String,image:UIImage?,sendToFriend: String,didSuccessSendMsg:(newMessage: Message?)->()) {
        
       
        if let urlToReq = NSURL(string: url+"/messages") {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            let userData: NSMutableDictionary = ["conversationId":conversationId,"content":content,"image":""]
            if let sendImage = image {
                let data = UIImageJPEGRepresentation(sendImage, 0.1)
                let imageData = data?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
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
                        var newMsg: Message?
                        if let found_data = data {
                            if let message = self.parseJSON(found_data) {
                                var hasImage: Bool = false
                               
                                if message["image"] as? Int == 1 {
                                    hasImage = true
                                }
                                if hasImage {
                                    let date = message["createdAt"] as! String
                                    CoreDataManager.sharedInstance.create_conversation(conversationId, friendId: sendToFriend, lastMsg: "[Picture]", updatedAt: date.toNSDate(), unreadMsg: "0")
                                    
                                    Connection.sharedInstance.getMessageImage(message["_id"]! as! String) {
                                        image in
                                        
                                        if let imageReceived = image {
                                            dispatch_sync(dispatch_get_main_queue()) {
                                                CoreDataManager.sharedInstance.update_message(message["_id"]! as! String, media: imageReceived)
                                                
                                            }
                                            
                                            self.imageDelegate?.didDownloadImage()
                                         
                                        }
                                    }
                                }
                                newMsg = CoreDataManager.sharedInstance.add_message(message["_id"]! as! String,messageText:message["content"]! as! String, senderId: message["_user"]!!["_id"]! as! String, senderHandle: message["_user"]!!["handle"]! as! String, conversationId: message["_conversation"]! as! String, createdAt: message["createdAt"]! as! String)
                                if newMsg !== nil && !hasImage {
                                    CoreDataManager.sharedInstance.create_conversation(conversationId, friendId: sendToFriend, lastMsg: newMsg!.content!, updatedAt: newMsg!.timestamp!, unreadMsg: "0")
                                }
                            }
                            didSuccessSendMsg(newMessage: newMsg)
                        }
                    }
                }
                task.resume()
            }catch let error {
                print("error : \(error)")
            }
        }
    }
    
    func listenForNewConversation() {
        socket.on("newConversation") {
            data, ack in
            let userArray = data[0]["conversation"]!!["users"] as! NSArray
            var friendIdString = ""
            for var i = 0; i < userArray.count; i++ {
                if i != 0 {
                    friendIdString += ","+(userArray[i] as! String)
                } else {
                    friendIdString += userArray[i] as! String
                }
            }
            let date = data[0]["conversation"]!!["createdAt"] as! String
            CoreDataManager.sharedInstance.create_conversation(data[0]["conversation"]!!["_id"] as! String, friendId: friendIdString, lastMsg: "", updatedAt: date.toNSDate(), unreadMsg: "1")
            self.delegate?.didReceiveConversation()
            
        }
    }

    
 

    func listenForFriendUpdate() {
        socket.on("friendRequest") {
            data, ack in
            print("get friend request")
            let user = data[0]["user"]
            
          

            
            var hasImage = "0"
            if  user!!["profileImage"] as! Int == 1 {
                hasImage = "1"
            }
            
            self.friendRequest.append(["id":user!!["_id"]! as! String,"handle":user!!["handle"]! as! String, "profileImage":hasImage])
            self.delegate?.didReceiveFriendUpdate("Request")
                
            
            
           
        }
        socket.on("friendAccepted") {
            data, ack in
            print("get new friend accept")
            let user = data[0]["user"]
            
            var hasImage = "0"
            if  user!!["profileImage"] as! Int == 1 {
                hasImage = "1"
            }
            self.Friends.append(["id": user!!["_id"]! as! String, "handle":user!!["handle"]! as! String,"profileImage":hasImage])
            self.delegate?.didReceiveFriendUpdate("Accepted")
                
    
           
        }
    }

}
