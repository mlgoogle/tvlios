//
//  UserInfoManager.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/30.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class UserInfoManager : NSObject {
    
    class var manager : UserInfoManager {
        struct Static {
            static let instance:UserInfoManager = UserInfoManager()
        }
        return Static.instance
    }
    
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
    
}
