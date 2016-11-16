//
//  PushMessage.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/29.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class PushMessage: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    enum MessageType : Int {
        case Chat = 2004
        case System = 1
        case Date
        case Appointment = 2231
    }
    
    dynamic var push_msg_type = MessageType.Chat.rawValue
    
    dynamic var msg_type_ = MessageType.Chat.rawValue
    
    dynamic var from_uid_ = 0
    
    dynamic var to_uid_ = 0
    
    dynamic var appointment_id_ = 0
    
    dynamic var msg_time_:Int64 = 0
    
    dynamic var content_:String?
    
    dynamic var service_id_:String?
    
    
    func setInfo(messageInfo:Dictionary<String,AnyObject>?) {
        
        if messageInfo!["from_uid_"] != nil {
         from_uid_ = messageInfo!["from_uid_"] as! Int
        }
        if messageInfo!["content_"] != nil {
            content_ = messageInfo!["content_"] as? String
        }
        if messageInfo!["msg_type_"] != nil {
            msg_type_ = messageInfo!["msg_type_"] as! Int
        }
        if messageInfo!["to_uid_"] != nil {
            to_uid_ = messageInfo!["to_uid_"] as! Int
        }
        if messageInfo!["push_msg_type"] != nil {
            push_msg_type = messageInfo!["push_msg_type"] as! Int
        }
        if messageInfo!["msg_body_"] != nil {
            setBody(messageInfo!["msg_body_"] as! Dictionary)

        }
        
        
    }
    
    func setBody(body:Dictionary<String, AnyObject>) {
        
        if body["servantID"] != nil {
            service_id_ = body["servantID"] as? String
        }
        if body["appointment_id_"]  != nil {
            appointment_id_ = body["appointment_id_"] as! Int
        }
    }
}

class UserPushMessage: Object {
    
    dynamic var uid = 0
    
    dynamic var unread = 0
    
    let msgList = List<PushMessage>()
    
}
