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
    
    //MARK: - PushMessage
    static func getUnreadMsgCnt(uid: Int) -> Int {
        if DataManager.initialized == false {
            return 0
        }
        let realm = try! Realm()
        if uid == -1 {
            var cnt = 0
            let objs = realm.objects(ChatSessionModel.self)
            for obj in objs {
                if obj.uid_ != CurrentUser.uid_ {
                    cnt += obj.unread_
                }
                
            }
            return cnt
        }
        return realm.objects(ChatSessionModel.self).filter("uid = \(uid)").count
    }
    
    static func readMessage(uid: Int) {
        if DataManager.initialized == false {
            return
        }
        let realm = try! Realm()
        let objs = realm.objects(ChatSessionModel.self).filter("uid_ = \(uid)")
        try! realm.write({
        
            if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
            }
            objs.setValue(0, forKey: "unread_")
        })
        
    }
    
    //MARK: - DataManagerAPI
    static func insertDatas(models: [Object]) {
        guard DataManager.initialized != false else { return }
        for model in models {
            DataManager.insertData(model)
        }
    }
    
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
        } else if model.isKindOfClass(CenturionCardRecordModel) {
            let type = CenturionCardRecordModel.self
            
            let info = model as! CenturionCardRecordModel

            let cardRecordModel = realm.objects(type).filter("order_id_ = \(info.order_id_)").first
            try! realm.write({
                if  cardRecordModel == nil {
                    realm.add(info)
                } else {
                    cardRecordModel?.refreshPropertiesWithModel(info)
                }
            })
        } else if model.isKindOfClass(AppointmentInfoModel) {
            let type = AppointmentInfoModel.self
            let info = model as! AppointmentInfoModel
            let appointmentModel = realm.objects(type).filter("appointment_id_ = \(info.appointment_id_)").first
            try! realm.write({
                if appointmentModel == nil {
                    realm.add(info)
                } else {
                    appointmentModel?.refreshPropertiesWithModel(info)
                }
            })
        } else if model.isKindOfClass(HodometerInfoModel) {
            let type = HodometerInfoModel.self
            let info = model as! HodometerInfoModel
            let hodoModel = realm.objects(type).filter("order_id_ = \(info.order_id_)").first
            try! realm.write({
                if hodoModel == nil {
                    realm.add(info)
                } else {
                    hodoModel?.refreshPropertiesWithModel(info)
                }
            })
        } else if model.isKindOfClass(SkillsModel) {
            let type = SkillsModel.self
            try! realm.write({
                realm.delete(realm.objects(SkillModel.self))
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
        } else if model.isKindOfClass(UserInfoModel) {
            let type = UserInfoModel.self
            let info = model as! UserInfoModel
            
            let userModel = realm.objects(type).filter("uid_ = \(info.uid_)").first
            
            try! realm.write({
                if userModel == nil {
                    realm.add(model)
                } else {
                    userModel?.refreshPropertiesWithModel(info)
                }
            })
        } else  if model.isKindOfClass(MessageModel) {
            let type = ChatSessionModel.self
            let info = model as! MessageModel
            var uid = -1
            if info.from_uid_ == CurrentUser.uid_ {
                uid = info.to_uid_
            } else if info.to_uid_ == CurrentUser.uid_ {
                uid = info.from_uid_
            }
            var chatSession = realm.objects(type).filter("uid_ = \(uid)").first
            
            try! realm.write({
                if chatSession == nil {
                    chatSession = ChatSessionModel()
                    chatSession?.uid_ = uid
                    chatSession?.msgList.append(info)
                    chatSession?.msg_time_ = info.msg_time_
                    realm.add(chatSession!)
                } else {
                    chatSession?.msgList.append(info)
                }
                if info.from_uid_ != CurrentUser.uid_ {
                    chatSession?.unread_ += 1
                }
            })
            
        }else if model.isKindOfClass(InvoiceHistoryModel) {
            let type = InvoiceHistoryModel.self
            try! realm.write({
                realm.delete(realm.objects(type))
                realm.add(model)
            })
        
        } else if model.isKindOfClass(InvoiceDetailModel) {
            let type = InvoiceDetailModel.self
            try! realm.write({
                realm.delete(realm.objects(type))
                realm.add(model)
            })
        } else if model.isKindOfClass(DrawBillBaseInfo) {
            let type = DrawBillBaseInfo.self
            try! realm.write({
                realm.delete(realm.objects(type))
                realm.add(model)
            })

        } else {
            try! realm.write({
                realm.add(model)
            })
        }
    
    }
    
    static func removeData<T: Object>(type: T.Type, filter: String? = nil) {
        guard DataManager.initialized != false else { return }
        
        let realm = try! Realm()
        try! realm.write({
            if filter == nil {
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
    

    static func getData<T: Object>(type: T.Type, filter: String? = nil) -> Results<T>? {
        guard DataManager.initialized != false else { return nil }
        
        let realm = try! Realm()
        if filter == nil {
            return realm.objects(type)
        } else {
            return realm.objects(type).filter(filter!)
        }
        
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

}
