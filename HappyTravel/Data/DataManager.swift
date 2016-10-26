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

enum HodometerType : Int {
    case All
    case Business
    case Highend
}

class DataManager: NSObject {
    
    enum OrderType : Int {
        case All
        case Business
        case Highend
    }
    
    static var initialized = false
    
    static func setDefaultRealmForUID(uid: Int) {
        var config = Realm.Configuration()
        
        var path:NSString = (config.fileURL?.absoluteString)!
        path = path.stringByDeletingLastPathComponent
        path = path.stringByAppendingPathComponent("\(uid)")
        path = path.stringByAppendingPathExtension("realm")!
        config.fileURL = NSURL(string: path as String)
        config.schemaVersion = 1
        config.migrationBlock = {migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                migration.enumerate(OrderInfo.className()) { oldObject, newObject in
                    newObject!["start_time_"] = 123
                }
            }
        }
        Realm.Configuration.defaultConfiguration = config
        DataManager.initialized = true
        XCGLogger.debug("\(try! Realm().configuration.fileURL)")
    }
    
    //MARK: - UserInfo
    static let currentUser:UserInfo? = UserInfo()
    
    static func getUserInfo(uid: Int) -> UserInfo? {
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        let users = realm.objects(UserInfo.self).first
        if users == nil {
            return nil
        }
        return realm.objects(UserInfo.self).filter("uid = \(uid)").first
    }
    
    static func updateUserInfo(info: UserInfo) {
        if DataManager.initialized == false {
            return
        }
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
        if DataManager.initialized == false {
            return 0
        }
        let realm = try! Realm()
        if uid == -1 {
            return realm.objects(UserPushMessage.self).count
        }
        return (realm.objects(UserPushMessage.self).filter("uid = \(uid)").first?.msgList.count)!
    }
    
    static func getUnreadMsgCnt(uid: Int) -> Int {
        if DataManager.initialized == false {
            return 0
        }
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
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        return realm.objects(UserPushMessage.self).filter("uid = \(uid)").first
    }
    
    static func insertMessage(message: PushMessage) {
        if DataManager.initialized == false {
            return
        }
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
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let objs = realm.objects(UserPushMessage.self).filter("uid = \(uid)")
        try! realm.write({
            objs.setValue(0, forKey: "unread")
        })
        
    }
    
    //MARK: - OrderInfo
    static func getOrderInfo(oid: Int) -> OrderInfo? {
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        return realm.objects(OrderInfo.self).filter("oid_ = \(oid)").first
    }
    
    static func getOrderCount(type: OrderType) -> Int {
        if DataManager.initialized == false {
            return 0
        }
        let realm = try! Realm()
        if type == .All {
            return realm.objects(OrderInfo.self).count
        } else if type == .Business {
            return 0
        }
        return 0
    }
    
    static func insertOrderInfo(info: OrderInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let orderInfo = realm.objects(OrderInfo.self).filter("oid_ = \(info.oid_)").first
        try! realm.write({
            if orderInfo == nil {
                realm.add(info)
                
            }
        })
        
    }
    
    static func updateOrderStatus(info: OrderInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let orderInfo = realm.objects(OrderInfo.self).filter("oid_ = \(info.oid_)").first
        try! realm.write({
            if orderInfo == nil {
                realm.add(info)
            } else {
                orderInfo?.order_status_ = info.order_status_
            }
        })
    }
    
    //MARK: - HodometerInfo
    static func getHodometerInfo(oid: Int) -> HodometerInfo? {
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        return realm.objects(HodometerInfo.self).filter("order_id_ = \(oid)").first
    }
    
    static func getHodometerCount(type: HodometerType) -> Int {
        if DataManager.initialized == false {
            return 0
        }
        let realm = try! Realm()
        if type == .All {
            return realm.objects(HodometerInfo.self).count
        } else if type == .Business {
            return 0
        }
        return 0
    }
    
    static func insertHodometerInfo(info: HodometerInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let hodometerInfo = realm.objects(HodometerInfo.self).filter("order_id_ = \(info.order_id_)").first
        try! realm.write({
            if hodometerInfo == nil {
                realm.add(info)
            } else {
                hodometerInfo?.setInfo(info)
            }
        })
        
    }
    
    static func getHodometerHistory() ->Results<HodometerInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        let hodometerInfos = realm.objects(HodometerInfo.self).filter("status_ = \(HodometerStatus.Paid.rawValue)")
        return hodometerInfos
    }
    
    // MARK: - CenturionCardServiceInfo
    static func getCenturionCardServiceWithID(id: Int) ->Results<CenturionCardServiceInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let centurionCardServiceInfos = realm.objects(CenturionCardServiceInfo.self).filter("privilege_id_ = \(id)")
        return centurionCardServiceInfos
    }
    
    static func getCenturionCardServiceWithLV(lv: Int) ->Results<CenturionCardServiceInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let centurionCardServiceInfos = realm.objects(CenturionCardServiceInfo.self).filter("privilege_lv_ = \(lv)")
        return centurionCardServiceInfos
    }
    
    static func insertCenturionCardServiceInfo(info: CenturionCardServiceInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let centurionCardServiceInfo = realm.objects(CenturionCardServiceInfo.self).filter("privilege_id_ = \(info.privilege_id_)").first
        try! realm.write({
            if centurionCardServiceInfo == nil {
                realm.add(info)
            } else {
                centurionCardServiceInfo?.setInfo(info)
            }
        })
        
    }
    
    // MARK: - CerturionCardConsumedInfo
    static func getCerturionCardConsumedInfo(oid: Int) -> CenturionCardConsumedInfo? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let centurionCardConsumedInfo = realm.objects(CenturionCardConsumedInfo.self).filter("order_id_ = \(oid)").first
        return centurionCardConsumedInfo
    }
    
    static func getCerturionCardConsumedInfos(lv: Int) -> Results<CenturionCardConsumedInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let centurionCardConsumedInfos = realm.objects(CenturionCardConsumedInfo.self)
        return centurionCardConsumedInfos
    }
    
    static func insertCerturionCardConsumedInfo(info: CenturionCardConsumedInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let centurionCardConsumedInfo = realm.objects(CenturionCardConsumedInfo.self).filter("order_id_ = \(info.order_id_)").first
        try! realm.write({
            if centurionCardConsumedInfo == nil {
                realm.add(info)
            } else {
                centurionCardConsumedInfo?.setInfo(info)
            }
        })
        
    }
    
    static func insertData<T: Object>(type: T.Type, data: AnyObject) {
        if DataManager.initialized == false {
            return
        }
        
        let realm = try! Realm()
        switch type.className() {
        case SkillInfo.className():
            let obj = data as! SkillInfo
            let info = realm.objects(SkillInfo.self).filter("skill_id_ = \(obj.skill_id_)").first
            try! realm.write({
                if info == nil {
                    realm.add(obj)
                } else {
                    info?.setInfo(obj)
                }
            })
            break
        default:
            break
        }
        
    }
    
    static func getData<T: Object>(type: T.Type, filter: String?) -> AnyObject? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        switch type.className() {
        case SkillInfo.className():
            let objs = realm.objects(SkillInfo.self)
            if filter == nil {
                return objs
            } else {
                return objs.filter(filter!)
            }
            
        default:
            break
        }
        
        return nil
    }
    
    static func updateData<T: Object>(type: T.Type, data: AnyObject) -> Bool {
        if DataManager.initialized == false {
            return false
        }
        let realm = try! Realm()
        switch type.className() {
        case HodometerInfo.className():
            let dict = data as! [String: Int]
            let obj = realm.objects(HodometerInfo.self).filter("order_id_ = \(dict["order_id_"]!)").first
            try! realm.write({
                if obj != nil {
                    obj?.status_ = dict["invoice_status_"]!
                }
            })
            
        default:
            break
        }
        
        return false
    }
    
}