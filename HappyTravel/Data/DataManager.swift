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
    
    static var realm:Realm?
    
    static var curLocation:CLLocation?
    
    static func setDefaultRealmForUID(uid: Int) {
        var config = Realm.Configuration()
        
        var path:NSString = (config.fileURL?.absoluteString)!
        path = path.stringByDeletingLastPathComponent
        path = path.stringByAppendingPathComponent("\(uid)")
        path = path.stringByAppendingPathExtension("realm")!
        config.fileURL = NSURL(string: path as String)
        config.schemaVersion = 2
        config.migrationBlock = {migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                migration.enumerate(AppointmentInfo.className()) { oldObject, newObject in
                    newObject!["recommend_uid_"] = "1,2"
                }
            }
        }
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
        DataManager.initialized = true
        DataManager.realm = try! Realm()
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
                user?.updateInfo(info)
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
                if obj.uid != CurrentUser.uid_ {
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
        if message.from_uid_ == CurrentUser.uid_ {
            uid = message.to_uid_
        } else if message.to_uid_ == CurrentUser.uid_ {
            uid = message.from_uid_
        }
        var userPushMessage = realm.objects(UserPushMessage.self).filter("uid = \(uid)").first
        try! realm.write({
            if userPushMessage == nil {
                userPushMessage = UserPushMessage()
                userPushMessage!.uid = uid
                userPushMessage!.msgList.append(message)
                userPushMessage!.msg_time_ = message.msg_time_
                realm.add(userPushMessage!)
            } else {
                userPushMessage?.msgList.append(message)
            }
            if message.from_uid_ != CurrentUser.uid_ {
                userPushMessage?.unread += 1
            }
            
        })
        
    }
    
    /**
     远程通知消息处理
     
     - parameter message:
     */
    static func insertPushMessage(message: PushMessage) {
        if DataManager.initialized == false {
            return
        }
        
        message.msg_time_ = Int64(NSDate().timeIntervalSince1970)
        switch message.push_msg_type {
        case 2004:
            DataManager.insertMessage(message)
            
        case 2012:
            XCGLogger.error("这里是邀约的回复处理")
        case 2231:
            let realm = try! Realm()

            let uid = message.appointment_id_
            var userPushMessage = realm.objects(UserPushMessage.self).filter("uid = \(uid)").first
            try! realm.write({
                if userPushMessage == nil {
                    userPushMessage = UserPushMessage()
                    userPushMessage!.uid = uid
                    userPushMessage!.msgList.append(message)
                    userPushMessage!.msg_time_ = message.msg_time_
                    realm.add(userPushMessage!)
                } else {
                    userPushMessage?.msgList.append(message)
                }
                if message.from_uid_ != CurrentUser.uid_ {
                    userPushMessage?.unread += 1
                }
                
            })
        default:
         
            break
        }
        

        
    }
    
    static func deletePushMessage(uid:Int) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let results = realm.objects(UserPushMessage.self).filter("uid = \(uid)")
        try! realm.write({ 
            realm.delete(results.first!)
        })
        
    }
    
    static func readMessage(uid: Int) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let objs = realm.objects(UserPushMessage.self).filter("uid = \(uid)")
        try! realm.write({
        
            if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
            }
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
    
    static func modfyStatusWithDictonary(dict:Dictionary<String, AnyObject>) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        try! realm.write {
            if let appointmentInfo = DataManager.getAppointmentRecordInfo(dict["order_id_"] as! Int) {
                appointmentInfo.status_ = dict["order_status_"] as! Int
                
            } else if let hodometerInfo = DataManager.getHodometerInfo(dict["order_id_"] as! Int) {
                
                hodometerInfo.status_ = dict["order_status_"] as! Int
                
            }
        }
        
    }
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
    
    static func insertOpenTicketWithHodometerInfo(info: HodometerInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let openInfo = realm.objects(OpenTicketInfo.self).filter("order_id_ = \(info.order_id_)").first
        try! realm.write({
            if openInfo == nil {
                let tempInfo = OpenTicketInfo()
                tempInfo.setInfoWithHodometer(info)
                realm.add(tempInfo)
            } else {
                openInfo?.setInfoWithHodometer(info)
            }
        })
    }
    
    static func insertOpenTicketWithConsumedInfo(info: CenturionCardConsumedInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let openInfo = realm.objects(OpenTicketInfo.self).filter("order_id_ = \(info.order_id_)").first
        try! realm.write({
            if openInfo == nil {
                let tempInfo = OpenTicketInfo()
                tempInfo.setInfoWithConsumedInfo(info)
                realm.add(tempInfo)
            } else {
                openInfo?.setInfoWithConsumedInfo(info)
            }
        })
    }
    
    static func insertInvoiceServiceInfo(info: InvoiceServiceInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let tempInfo = realm.objects(InvoiceServiceInfo.self).filter("service_id_ = \(info.service_id_)").first
        try! realm.write({
            if tempInfo == nil {
                realm.add(info)
            } else {
                tempInfo?.setInfo(info)
            }
        })
    }

    static func getOpenTicketsInfo() ->Results<OpenTicketInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        let infos = realm.objects(OpenTicketInfo.self).sorted("time", ascending: true)
        return infos
    }
    
    static func getHodometerHistory() ->Results<HodometerInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        let hodometerInfos = realm.objects(HodometerInfo.self).filter("status_ = \(HodometerStatus.Completed.rawValue)")
        return hodometerInfos
    }
    
    static func getCenturionCardConsumed() ->Results<CenturionCardConsumedInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        let realm = try! Realm()
        let infos = realm.objects(CenturionCardConsumedInfo.self).filter("order_status_ = 7")
        return infos
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
    
    static func insertCenturionCardVIPPriceInfo(info: CentuionCardPriceInfo){
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let price = realm.objects(CentuionCardPriceInfo.self).filter("blackcard_lv_ = \(info.blackcard_lv_)").first
        try! realm.write({ 
            if price == nil{
                realm.add(info)
            }else{
                price?.setInfo(info)
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
    
    //MARK: - DataManagerAPI
    static func insertData(model: Object) {
        guard DataManager.initialized != false else { return }
        
        let realm = try! Realm()
        if model.isKindOfClass(CenturionCardBaseInfosModel) {
            let type = CenturionCardBaseInfosModel.self
            try! realm.write({
                realm.delete(realm.objects(CenturionCardBaseInfoModel.self))
                realm.delete(realm.objects(type))
                realm.add(model)
            })
        } else if model.isKindOfClass(CenturionCardPriceInfosModel) {
            let type = CenturionCardPriceInfosModel.self
            try! realm.write({
                realm.delete(realm.objects(CenturionCardPriceInfoModel.self))
                realm.delete(realm.objects(type))
                realm.add(model)
            })
        } else if model.isKindOfClass(UserCenturionCardInfoModel) {
            let type = UserCenturionCardInfoModel.self
            try! realm.write({
                realm.delete(realm.objects(type))
                realm.add(model)
            })
        } else if  model.isKindOfClass(CityNameInfoModel) {
            let type = CityNameInfoModel.self
            try! realm.write({
                realm.delete(realm.objects(type))
                realm.add(model)
            })
        } else if model.isKindOfClass(InsuranceInfoModel) {
            let type = InsuranceInfoModel.self
            try! realm.write({
                realm.delete(realm.objects(type))
                realm.add(model)
            })
        }
        
    }
    
    static func removeData<T: Object>(type: T.Type, filter: String? = nil) {
        guard DataManager.initialized != false else { return }
        
        let realm = try! Realm()
        try! realm.write({
            if filter != nil {
                let objs = realm.objects(type)
                if objs.count > 0 {
                    realm.delete(objs)
                }
            } else {
                let objs = realm.objects(type).filter(filter!)
                if objs.count > 0 {
                    realm.delete(objs)
                }
            }
        })
    }
    
    static func insertData<T: Object>(type: T.Type, data: AnyObject) {
        guard DataManager.initialized != false else { return }
        
        let realm = DataManager.realm!
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

        case CityInfo.className():
            let obj = data as! CityInfo
            let info = realm.objects(CityInfo.self).filter("cityCode = \(obj.cityCode)").first
            try! realm.write({
                if info == nil {
                    realm.add(obj)
                } else {
                    info?.refreshInfo(obj)
                }
            })
        default:
            break
        }

    }
    
    static func getData<T: Object>(type: T.Type, filter: String? = nil) -> AnyObject? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        switch type.className() {
            
        case UserInfo.className():
            let objs = realm.objects(UserInfo.self)
            if filter == nil {
                return objs
            } else {
                return objs.filter(filter!)
            }
        case SkillInfo.className():
            let objs = realm.objects(SkillInfo.self)
            if filter == nil {
                return objs
            } else {
                return objs.filter(filter!)
            }
            
        case CityInfo.className():
            let objs = realm.objects(CityInfo.self)
            if filter == nil {
                return objs
            } else {
                return objs.filter(filter!)
            }
        case CentuionCardPriceInfo.className():
            let objs = realm.objects(CentuionCardPriceInfo.self)
            if filter == nil {
                return objs
            } else {
                return objs.filter(filter!).first
            }
        case CenturionCardBaseInfoModel.className():
            let objs = realm.objects(CenturionCardBaseInfoModel.self)
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
            break
        case CityInfo.className():

            break
        default:
            break
        }
        
        return false
    }
    
    static func updateData<T: Object>(type: T.Type, dict: [String: AnyObject]) -> Bool {
        guard DataManager.initialized != false else {return false}
        
        let realm = try! Realm()
        switch type.className() {
        case HodometerInfo.className():
            let oid = dict["order_id_"] as! Int
            let info = realm.objects(HodometerInfo.self).filter("order_id_ = \(oid)").first
            try! realm.write({
                if info != nil {
                    for (key, value) in dict {
                        info?.setValue(value, forKey: key)
                    }
                }
            })
        default:
            break
        }
        return true
    }

    static func clearData<T: Object>(type: T.Type) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        switch type.className() {
        case CenturionCardServiceInfo.className():
            try! realm.write({
                let objs = realm.objects(CenturionCardServiceInfo.self)
                if objs.count > 0 {
                    realm.delete(objs)
                }
            })
            break
        case CityInfo.className():
            
            break
        default:
            break
        }
        
    }
    
    // MARK: - InvoiceHistoryInfo
    /**
     开票记录
     - parameter info:
     */

    static func insertInvoiceHistotyInfo(info: InvoiceHistoryInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let historyInfo = realm.objects(InvoiceHistoryInfo.self).filter("invoice_id_ = \(info.invoice_id_)").first
        try! realm.write({
            if historyInfo == nil {
                realm.add(info)
            } else {
                historyInfo?.setInfo(info)
            }
        })
        
    }
    static func getInvoiceHistoryInfo(invoice_id_: Int) -> InvoiceHistoryInfo? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let histroyInfo = realm.objects(InvoiceHistoryInfo.self).filter("invoice_id_ = \(invoice_id_)").first
        return histroyInfo
    }
    
    static func getInvoiceHistoryInfos(lv: Int) -> Results<InvoiceHistoryInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let histroyInfo = realm.objects(InvoiceHistoryInfo.self)
        return histroyInfo
    }
    
    static func updateInvoiceHistoryInfo(info:InvoiceHistoryInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let historyInfo = realm.objects(InvoiceHistoryInfo.self).filter("invoice_id_ = \(info.invoice_id_)").first
        try! realm.write({
            if historyInfo == nil {
                let historyInfo = InvoiceHistoryInfo()
                historyInfo.setInfo(info)
                realm.add(historyInfo)
            } else {
                historyInfo?.refreshOtherInfo(info)
            }
            
        })
    }
    
    
    //MARK: - 预约记录
    
    static func insertAppointmentRecordInfo(info: AppointmentInfo) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let recordInfo = realm.objects(AppointmentInfo.self).filter("appointment_id_ = \(info.appointment_id_)").first
        try! realm.write({
            if recordInfo == nil {
                realm.add(info)
            } else {
                recordInfo?.setInfo(info)
            }
        })
        
    }
    
    static func getAppointmentRecordInfo(order_id_:Int) -> AppointmentInfo? {
    
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let appointmentRecordInfo = realm.objects(AppointmentInfo.self).filter("order_id_ = \(order_id_)")

        return appointmentRecordInfo.first
    
    }
    static func getAppointmentRecordInfos(lv: Int) -> Results<AppointmentInfo>? {
        if DataManager.initialized == false {
            return nil
        }
        
        let realm = try! Realm()
        let appointmentRecordInfo = realm.objects(AppointmentInfo.self)
        return appointmentRecordInfo
    }
    
  }
