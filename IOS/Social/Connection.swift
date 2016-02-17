//
//  Connection.swift
//  Social
//
//  Created by Shuhan Ng on 2/8/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

protocol ConnectionDelegate {
    func didReceiveMessages(data: AnyObject)
   
}

class Connection {
    
    static let sharedInstance = Connection()
    private var socket: SocketIOClient
    
    var delegate: ConnectionDelegate?
    
    private init() {
        socket = SocketIOClient(socketURL: "http://192.168.1.227:8000")
        socket.connect()
        socket.on("connect") { data, ack in
            // Wait To Do This Until Login Success
            // Server will send User Id, check that it's the same id as in CoreData (or maybe NSDefaults? maybe delete all messages??)
            let userId = CoreDataManager.sharedInstance.get_user()?.id
            self.socket.emit("login", userId!)
            print("IOS::: WE ARE USING SOCKETS!!!")
        }
    }
    
    
    func disconnect() {
        print("IOS::: user disconnected!")
        socket.disconnect()
    }
    
    func listenForMessages() {
        socket.on("updateMessage") {data, ack in
            print("Connection::: got message")
            // data will be messageId
            // send http request for message
            self.delegate?.didReceiveMessages(data[0])
        
            
        }
    }
    // Move Login Function Into This File
  
    
    func sendMessages(data: AnyObject) {
        // Instead of emitting with socket,
        // http POST to server (restfully: "/messages") 
        socket.emit("newMessage",data)
    }
    
    
    
    

    
    
   
    
}

