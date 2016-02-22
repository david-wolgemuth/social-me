//
//  Connection.swift
//  Social
//
//  Created by Shuhan Ng on 2/8/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import Foundation
import KeychainSwift


protocol ConnectionSocketDelegate {
    func didReceiveMessages(data: AnyObject)
}

protocol ConnectionLoginDelegate {
    func didLogin(success: Bool)
}

protocol ConnectionRegisterDelegate {
    func didRegister(success:Bool)
}

protocol ConnectionAddFriendDelegate {
    func didFindFriend(success: Bool,friendFound: Dictionary<String,String>?)
    func didSuccessSendRequest(success: Bool,error:String?)
}




class Connection {
    
    static let sharedInstance = Connection()
    private var socket: SocketIOClient
    
    private var friendRequest = [Dictionary<String,String>]()
    private var Friends = [Dictionary<String,String>]()
 
    
    var delegate: ConnectionSocketDelegate?
    var loginDelegate: ConnectionLoginDelegate?
    var RegisterDelegate: ConnectionRegisterDelegate?
    var addFriendDelegate: ConnectionAddFriendDelegate?
    private var url: String
    
    private init() {
        url = "http://ShuHans-MacBook-Air.local:5000"
        socket = SocketIOClient(socketURL: url)
        socket.connect()
        socket.on("connect") { data, ack in
            print("IOS::: WE ARE USING SOCKETS!!!")
        }
    }
    
    
    func disconnect() {
        print("IOS::: user disconnected!")
        socket.disconnect()
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
                                    self.socket.emit("login",userId as! String)
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
    
        if let urlToReq = NSURL(string: url + "/users?user=" + friend) {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let userInfo = self.parseJSON(data) {
                    if let userId = userInfo["_id"]  {
                        let userHandle = userInfo["handle"]
                        
                        self.addFriendDelegate?.didFindFriend(true,friendFound: ["id":userId! as! String,"handle":userHandle! as! String])
                        
                    } else {
                        self.addFriendDelegate?.didFindFriend(false,friendFound: nil)
                    }
                } else {
                    self.addFriendDelegate?.didFindFriend(false,friendFound:nil)
                }
                
            }
            
        }
        
    }
    
    
    func getFriendRequest()->[Dictionary<String,String>] {
        return self.friendRequest
    }
    
    
    func getFriend(friendReceived:([Dictionary<String,String>])->()) {
        self.Friends = []
        if let urlToReq = NSURL(string: url + "/friends") {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let friends = self.parseJSON(data) as? [AnyObject] {
                    for friend in friends {
                        self.Friends.append(["id":friend["_id"]! as! String, "handle": friend["handle"]! as! String])
                    }
                }
                
            }
            
        }
        friendReceived(self.Friends)
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
    
  


    
    
    
    func respondFriend(FriendId: String,accept: Bool,didRespondRequest:(success:Bool,error: String?)->()) {
  
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
                                    didRespondRequest(success: true,error:nil)
                                } else {
                                    let error = message["error"]
                                    didRespondRequest(success: true,error: error! as? String)
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
        self.friendRequest = []
        
        if let urlToReq = NSURL(string: url + "/friends/requests") {
            if let data = NSData(contentsOfURL: urlToReq) {
                if let requests = self.parseJSON(data) as? [AnyObject] {
                    if requests.count > 0 {
                        for friends in requests {
                            self.friendRequest.append(["id":friends["_id"]! as! String,"handle": friends["handle"]! as! String])
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
    
 
    
    
    
    func listenForMessages() {
        socket.on("updateMessage") {data, ack in
            print("Connection::: got message")
            // data will be messageId
            // send http request for message
            self.delegate?.didReceiveMessages(data[0])
        }
    }  
    
    func sendMessages(data: AnyObject) {
        // Instead of emitting with socket,
        // http POST to server (restfully: "/messages") 
        socket.emit("newMessage",data)
    }
    
    
    
    

    
    
   
    
}

