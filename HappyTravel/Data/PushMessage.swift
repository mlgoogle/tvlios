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
        case Appointment
    }
    
    dynamic var msg_type_ = MessageType.Chat.rawValue
    
    dynamic var from_uid_ = 0
    
    dynamic var to_uid_ = 0
    
    dynamic var msg_time_:Int64 = 0
    
    dynamic var content_:String?

}

class UserPushMessage: Object {
    
    dynamic var uid = 0
    
    dynamic var unread = 0
    
    let msgList = List<PushMessage>()
    
}
