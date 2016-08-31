//
//  PushMessageManager.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/26.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift

class PushMessageManager : NSObject {
    
    class var manager : PushMessageManager {
        struct Static {
            static let instance:PushMessageManager = PushMessageManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
    }
    
    static func getMessageCount(uid: Int) -> Int {
        let realm = try! Realm()
        if uid == -1 {
            return realm.objects(UserPushMessage.self).count
        }
        return (realm.objects(UserPushMessage.self).filter("uid = \(uid)").first?.msgList.count)!
    }
    
    static func getUnreadMsgCnt(uid: Int) -> Int {
        let realm = try! Realm()
        if uid == -1 {
            var cnt = 0
            let objs = realm.objects(UserPushMessage.self)
            for obj in objs {
                cnt += obj.unread
            }
            return cnt
        }
        return realm.objects(UserPushMessage.self).filter("uid = \(uid)").count
    }
    
    static func getMessage(uid: Int) -> UserPushMessage? {
        let realm = try! Realm()
        return realm.objects(UserPushMessage.self).filter("uid = \(uid)").first
    }
    
    static func insertMessage(message: PushMessage) {
        let realm = try! Realm()
        var uid = -1
        if message.from_uid_ == UserInfoManager.currentUser?.uid {
            uid = message.to_uid_
        } else if message.to_uid_ == UserInfoManager.currentUser?.uid {
            uid = message.from_uid_
        }
        var userPushMessage = realm.objects(UserPushMessage.self).filter("uid = \(uid)").first
        try! realm.write({
            if userPushMessage == nil {
                userPushMessage = UserPushMessage()
                userPushMessage!.uid = message.from_uid_
                userPushMessage!.msgList.append(message)
                realm.add(userPushMessage!)
            } else {
                userPushMessage!.msgList.append(message)
            }
            userPushMessage!.unread += 1
            
        })

    }
    
    static func readMessage(uid: Int) {
        let realm = try! Realm()
        let objs = realm.objects(UserPushMessage.self).filter("uid = \(uid)")
        try! realm.write({ 
            objs.setValue(0, forKey: "unread")
        })
        
    }
    
}
