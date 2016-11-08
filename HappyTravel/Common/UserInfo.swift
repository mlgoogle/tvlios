//
//  UserInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/17.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift

class Tally: Object {
    
    dynamic var tally:String?
    dynamic var labelWidth:Float = 0.0
}

class PhotoUrl: Object {
    
    dynamic var photoUrl:String?
}

class ServiceInfo: Object {
    
    dynamic var service_id_:Int = 0
    
    dynamic var service_name_:String?
    
    dynamic var service_time_:String?
    
    dynamic var service_price_:Int = 0
}

class UserInfo: Object {

    enum UserType : Int {
        case CurrentUser
        case Servant
        case MeetLocation
        case Other
    }
    
    dynamic var login:Bool = false
    
    dynamic var nickname:String? = "未登录"
    
    dynamic var username:String?
    
    dynamic var cash:Int = 0
    
    dynamic var uid:Int = -1
    
    dynamic var level:Float = 0
    
    dynamic var headUrl:String?

    dynamic var address:String?
    
    dynamic var phoneNumber:String?
    
    dynamic var gpsLocationLat:Double = 0
    
    dynamic var gpsLocationLon:Double = 0
    
    dynamic var userType:Int = UserType.Servant.rawValue
    
    dynamic var businessLv:Float = 0
    
    dynamic var bigBGPhotoUrl:String?
    
    dynamic var certification:Bool = false
    
    dynamic var registerSstatus = 0
    
    dynamic var gender = 0
    
    dynamic var creditLv = 0
    
    dynamic var praiseLv = 0
    
    dynamic var cashLv = 0
    
    dynamic var centurionCardStartTime = 0
    
    dynamic var centurionCardEndTime = 0
    
    dynamic var centurionCardLv = 0
    
    dynamic var centurionCardValid = 0
    // 认证状态==> -1 : 未认证 | 0 : 认证中 | 1 : 认证成功 | 2 : 认证失败
    dynamic var authentication = -1
    
    let businessTags:List<Tally> = List<Tally>()
    
    let photoUrlList:List<PhotoUrl> = List<PhotoUrl>()
    
    let serviceList:List<ServiceInfo> = List<ServiceInfo>()
    
    let travalTags:List<Tally> = List<Tally>()
    

    func setInfo(type: UserType, info: Dictionary<String, AnyObject>?) {
        userType = type.rawValue

        if info == nil {
            return
        }
        for (key, value) in info! {
            switch key {
            case "address_":
                address = value as? String
                break
            case "head_url_":
                headUrl = value as? String
                break
            case "level_":
                level = value as! Float
                break
            case "nickname_", "nick_name_":
                nickname = value as? String
                break
            case "phone_num_":
                phoneNumber = value as? String
                break
            case "uid_":
                uid = value as! Int
                break
            case "latitude_":
                gpsLocationLat = (value as? CLLocationDegrees)!
                break
            case "longitude_":
                gpsLocationLon = (value as? CLLocationDegrees)!
                break
            case "login_":
                login = value as! Bool
                break
            case "business_lv_":
                businessLv = value as! Float
                break
            case "business_tag_":
                businessTags.removeAll()
                let tags = (value as! String).componentsSeparatedByString(",")
                for tag in tags {
                    let tally = Tally()
                    tally.tally = tag
                    let string:NSString = tag
                    let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
                    let rect = string.boundingRectWithSize(CGSizeMake(0, 20), options: options, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(12)], context: nil)
                    tally.labelWidth = Float(rect.size.width) + 24
                    businessTags.append(tally)
                }
                break
            case "heag_bg_url_":
                bigBGPhotoUrl = value as? String
                break
            case "is_certification_":
                certification = value as! Bool
                break
            case "photo_list_":
                let urls = (value as! String).componentsSeparatedByString(",")
                photoUrlList.removeAll()
                for url in urls {
                    let photoUrl = PhotoUrl()
                    photoUrl.photoUrl = url
                    photoUrlList.append(photoUrl)
                }
                break
            case "service":
                serviceList.removeAll()
                let services = (value as? Array<Dictionary<String, AnyObject>>)
                for service in services! {
                    let svc = ServiceInfo(value: service)
                    serviceList.append(svc)
                }
                break
            case "traval_tag_":
                travalTags.removeAll()
                let tags = (value as! String).componentsSeparatedByString(",")
                for tag in tags {
                    let tally = Tally()
                    tally.tally = tag
                    let string:NSString = tag
                    let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
                    let rect = string.boundingRectWithSize(CGSizeMake(0, 24), options: options, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(12)], context: nil)
                    tally.labelWidth = Float(rect.size.width) + 24
                    travalTags.append(tally)
                }
                break
            case "register_status_":
                registerSstatus = value as! Int
                break
            case "gender_":
                gender = value as! Int
                break
            case "credit_lv_":
                creditLv = value as! Int
                break
            case "praise_lv_":
                praiseLv = value as! Int
                break
            case "cash_lv_":
                cashLv = value as! Int
                break
            case "start_time_":
                centurionCardStartTime = (value as! NSNumber).longValue
                break
            case "end_time_":
                centurionCardEndTime = (value as! NSNumber).longValue
                break
            case "blackcard_lv_":
                centurionCardLv = value as! Int
                break
            case "result":
                centurionCardValid = value as! Int
                break
            case "authentication":
                authentication = value as! Int
                break
            default:
                XCGLogger.warning("Exception:[\(key) : \(value)]")
                break
            }
        }
    }
    
    func updateInfo(info: UserInfo) {
        login = info.login
        
        nickname = info.nickname
        
        username = info.username
        
        uid = info.uid
        
        level = info.level
        
        headUrl = info.headUrl
        
        address = info.address
        
        phoneNumber = info.phoneNumber
        
        gpsLocationLat = info.gpsLocationLat
        
        gpsLocationLon = info.gpsLocationLon
        
        userType = info.userType
        
        businessLv = info.businessLv
        
        bigBGPhotoUrl = info.bigBGPhotoUrl
        
        certification = info.certification
        
        registerSstatus = info.registerSstatus
        
        gender = info.gender
        
        creditLv = info.creditLv
        
        praiseLv = info.praiseLv
        
        cashLv = info.cashLv
        
        centurionCardStartTime = info.centurionCardStartTime
        
        centurionCardEndTime = info.centurionCardEndTime
        
        centurionCardLv = info.centurionCardLv
        
        centurionCardValid = info.centurionCardValid
        
        authentication = info.authentication
        
        businessTags.removeAll()
        for tag in info.businessTags {
            businessTags.append(tag)
        }
        
        photoUrlList.removeAll()
        for url in info.photoUrlList {
            photoUrlList.append(url)
        }
        
        serviceList.removeAll()
        for svc in info.serviceList {
            serviceList.append(svc)
        }
        
        travalTags.removeAll()
        for tag in info.travalTags {
            travalTags.append(tag)
        }
        
    }
    
}

