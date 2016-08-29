//
//  UserInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/17.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class UserInfo: NSObject {
    
    class var currentUser : UserInfo {
        struct Static {
            static let instance:UserInfo = UserInfo()
        }
        return Static.instance
    }
    
    class var userList : NSMutableDictionary {
        struct Static {
            static let instance:NSMutableDictionary = [:]
        }
        return Static.instance
    }
    
    enum UserType {
        case CurrentUser
        case Servant
        case MeetLocation
        case Other
    }
    
    var login:Bool = false
    
    var nickname:String?
    
    var username:String?
    
    var uid:Int?
    
    var level:Float?
    
    var headUrl:String?

    var address:String?
    
    var phoneNumber:String?
    
    var gpsLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    var userType:UserType = .Servant
    
    var businessLv:Float = 0
    
    var businessTags:Array<String>?
    
    var bigBGPhotoUrl:String?
    
    var certification:Bool?
    
    var photoUrlList:Array<String>?
    
    var serviceList:Array<Dictionary<String, AnyObject>>?
    
    var travalTags:Array<String>?
    
    
    override init() {
        super.init()
        if !login {
            nickname = "未登录"
            level = 0
            userType = .Servant
        }
    }
    
    func setInfo(type: UserType, info: Dictionary<String, AnyObject>?) {
        userType = type
        for (key, value) in info! {
            switch key {
            case "address_":
                address = value as? String
                break
            case "head_url_":
                headUrl = value as? String
                break
            case "level_":
                level = value as? Float
                break
            case "nickname_", "nick_name_":
                nickname = value as? String
                break
            case "phone_num_":
                phoneNumber = value as? String
                break
            case "uid_":
                uid = value as? Int
                break
            case "latitude_":
                gpsLocation.latitude = (value as? CLLocationDegrees)!
                break
            case "longitude_":
                gpsLocation.longitude = (value as? CLLocationDegrees)!
                break
            case "login_":
                login = value as! Bool
                break
            case "business_lv_":
                businessLv = value as! Float
                break
            case "business_tag_":
                businessTags = (value as! String).componentsSeparatedByString(",")
                break
            case "heag_bg_url_":
                bigBGPhotoUrl = value as? String
                break
            case "is_certification_":
                certification = value as? Bool
                break
            case "photo_list_":
                photoUrlList = (value as! String).componentsSeparatedByString(",")
                break
            case "service":
                serviceList = value as? Array<Dictionary<String, AnyObject>>
                break
            case "traval_tag_":
                travalTags = (value as! String).componentsSeparatedByString(",")
                break
            default:
                XCGLogger.debug("Exception:[\(key) : \(value)]")
                break
            }
        }
    }
    
}
