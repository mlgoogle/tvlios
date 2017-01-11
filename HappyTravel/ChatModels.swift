//
//  ChatModels.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/10.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

enum MessageType : Int {
    case Chat = 2004
    case System = 0
    case Location = 1
    case Date
    case OrderAnswer = 2012
    case Appointment = 2231
}
class ChatModel: Object {
//    dynamic var doubi = "doubi"

    dynamic var from_uid_ = 0

    dynamic var to_uid_ = 0
    
    dynamic var msg_time_:Int64 = 0
    
    dynamic var content_:String?
    dynamic var msg_type_ = MessageType.Chat.rawValue

}
class MessageModel: ChatModel {
//    dynamic var msg_type_ = MessageType.Chat.rawValue

    dynamic var push_msg_type_ = MessageType.Chat.rawValue
    
    dynamic var appointment_id_ = 0
    
    dynamic var servant_id_:String?
}

class ChatSessionModel: Object {
   
    dynamic var msg_time_:Int64 = 0
    
    dynamic var uid_ = 0
    
    dynamic var unread_ = 0
    
    let msgList = List<MessageModel>()
}


