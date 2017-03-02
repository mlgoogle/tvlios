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
        config.schemaVersion = 3
        config.migrationBlock = {migration, oldSchemaVersion in
            if oldSchemaVersion < 3 {
                migration.enumerate(UserInfoModel.className()) { oldObject, newObject in
                    newObject!["recommend_uid_"] = 0.0
                    newObject!["follow_count_"] = 0
                }
            }
        }
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
        DataManager.initialized = true
        DataManager.realm = try! Realm()
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
        if model.isKindOfClass(SkillsModel) {
            let type = SkillsModel.self
            try! realm.write({
                realm.delete(realm.objects(SkillModel.self))
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
        } else if model.isKindOfClass(ServantDetailModel) {
            let type = ServantDetailModel.self
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

    static func getData<T: Object>(type: T.Type, filter: String? = nil) -> Results<T>? {
        guard DataManager.initialized != false else { return nil }
        
        let realm = try! Realm()
        if filter == nil {
            return realm.objects(type)
        } else {
            return realm.objects(type).filter(filter!)
        }
        
    }
    
}
