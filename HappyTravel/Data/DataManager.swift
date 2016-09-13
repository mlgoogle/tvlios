//
//  DataManager.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
import XCGLogger

class DataManager: NSObject {
    
    static func setDefaultRealmForUID(uid: Int) {
        var config = Realm.Configuration()
        
        var path:NSString = (config.fileURL?.absoluteString)!
        path = path.stringByDeletingLastPathComponent
        path = path.stringByAppendingPathComponent("\(uid)")
        path = path.stringByAppendingPathExtension("realm")!
        config.fileURL = NSURL(string: path as String)
        Realm.Configuration.defaultConfiguration = config
        XCGLogger.debug("\(try! Realm().configuration.fileURL)")
    }
    
    //MARK: - UserInfo
    static let currentUser:UserInfo? = UserInfo()
    
    static func getUserInfo(uid: Int) -> UserInfo? {
        let realm = try! Realm()
        let users = realm.objects(UserInfo.self).first
        if users == nil {
            return nil
        }
        return realm.objects(UserInfo.self).filter("uid = \(uid)").first
    }
    
    static func updateUserInfo(info: UserInfo) {
        let realm = try! Realm()
        let user = realm.objects(UserInfo.self).filter("uid = \(info.uid)").first
        try! realm.write({
            if user == nil {
                let userInfo = UserInfo()
                userInfo.updateInfo(info)
                realm.add(userInfo)
            } else {
                user!.updateInfo(info)
            }
            
        })
    }
    
    //MARK: - PushMessage
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
                if obj.uid != DataManager.currentUser!.uid {
                    cnt += obj.unread
                }
                
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
        if message.from_uid_ == DataManager.currentUser?.uid {
            uid = message.to_uid_
        } else if message.to_uid_ == DataManager.currentUser?.uid {
            uid = message.from_uid_
        }
        var userPushMessage = realm.objects(UserPushMessage.self).filter("uid = \(uid)").first
        try! realm.write({
            if userPushMessage == nil {
                userPushMessage = UserPushMessage()
                userPushMessage!.uid = uid
                userPushMessage!.msgList.append(message)
                realm.add(userPushMessage!)
            } else {
                userPushMessage!.msgList.append(message)
            }
            if message.from_uid_ != DataManager.currentUser?.uid {
                userPushMessage!.unread += 1
            }
            
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
