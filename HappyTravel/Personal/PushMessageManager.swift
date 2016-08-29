//
//  PushMessageManager.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/26.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class PushMessage: NSObject {
    
    enum MessageType {
        case ChatMessage
        case SystemMessage
        
    }
    
    var type:MessageType = .ChatMessage
    
    var fromUid:Int?
    
    var toUid:Int?
    
    var time:Int64?
    
    var content:String?
    
    
    override init() {
        super.init()
        
    }
    
    func setInfo(type: MessageType, info: Dictionary<String, AnyObject>?) {
        self.type = type
        for (key, value) in info! {
            switch key {
            case "from_uid_":
                fromUid = value as? Int
                break
            case "to_uid_":
                toUid = value as? Int
                break
            case "msg_time_":
                time = (value as? NSNumber)!.longLongValue
                break
            case "content_":
                content = value as? String
                break
            default:
                XCGLogger.debug("Exception:[\(key) : \(value)]")
                break
            }
        }
    }
    
}


class PushMessageManager : NSObject {
    
    class var manager : PushMessageManager {
        struct Static {
            static let instance:PushMessageManager = PushMessageManager()
        }
        return Static.instance
    }
    
    /*
     [["uid": [message], "new": 3], ["uid": [message], "new": 2]]
     */
    var messageList:NSMutableArray = []
    
    var unreadMessageCnt = 0
    
    override init() {
        super.init()
        
    }
    
    static func getMessageCount() -> Int {
        let manager = PushMessageManager.manager
        return manager.messageList.count
    }
    
    static func getUnreadMsgCnt() -> Int {
        let manager = PushMessageManager.manager
        return manager.unreadMessageCnt
    }
    
    static func getMessage(uid: Int) -> NSMutableArray? {
        let manager = PushMessageManager.manager
        for (_, d) in manager.messageList.enumerate() {
            let dict = d as! NSMutableDictionary
            if let _ = dict.valueForKey("\(uid)") {
                return dict.objectForKey("\(uid)") as? NSMutableArray
            }
        }
        
        return nil
    }
    
    static func insertMessage(message: PushMessage) {
        let manager = PushMessageManager.manager
        manager.unreadMessageCnt += 1
        let key = "\(message.fromUid!)"
        for (index, d) in manager.messageList.enumerate() {
            let dict = d as! NSMutableDictionary
            if let msgList = dict.valueForKey(key) as? NSMutableArray {
                msgList.addObject(message)
                dict.setValue(msgList, forKey: key)
                let unreadCount = dict.valueForKey("new") as! Int + 1
                dict.setValue(unreadCount, forKey: "new")
                manager.messageList.removeObjectAtIndex(index)
                manager.messageList.insertObject(dict, atIndex: 0)
                return
            }
        }
        
        let msgList = NSMutableArray()
        msgList.insertObject(message, atIndex: 0)
        let dict = NSMutableDictionary()
        dict.setValue(msgList, forKey: key)
        dict.setValue(1, forKey: "new")
        manager.messageList.insertObject(dict, atIndex: 0)
        
    }
    
    static func readMessage(uid: Int) {
        let manager = PushMessageManager.manager
        for (index, d) in manager.messageList.enumerate() {
            let dict = d as! NSMutableDictionary
            if let _ = dict.valueForKey("\(uid)") {
                let cnt = dict.valueForKey("new") as! Int
                manager.unreadMessageCnt -= cnt
                dict.setValue(0, forKey: "new")
                manager.messageList.removeObjectAtIndex(index)
                manager.messageList.insertObject(dict, atIndex: index)
                return
            }
        }

    }
    
}
