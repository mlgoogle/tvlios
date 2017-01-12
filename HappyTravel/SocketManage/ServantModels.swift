//
//  ServantModels.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/9.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift


class ServiceModel: Object {
    
    dynamic var service_id_ = -1
    
    dynamic var service_name_:String?
    
    dynamic var service_price_ = 0
    
    dynamic var service_type_ = 0
    
    dynamic var service_start_ = 0
    
    dynamic var service_end_ = 0
}

class ServantDetailModel: Object {
 
    dynamic var uid_ = -1
    
    dynamic var is_certification_ = 0
    
    dynamic var heag_bg_url_:String?
    
    dynamic var traval_tag_:String?
    
    var tags:[String] {
        if let arrTags = traval_tag_?.componentsSeparatedByString(",") {
            return arrTags
        }
        
        return []
    }
    
    let service_list_ = List<ServiceModel>()
}

//照片墙
class PhotoWallRequestModel: Object {
    dynamic var uid_ = 0
    dynamic var size_ = 0
    dynamic var num_ = 0
}

class PhotoModel: Object {
    dynamic var photo_url_: String?
    dynamic var thumbnail_url_: String?
    dynamic var upload_time_: String?
    
}

class PhotoWallModel: Object {
    let photo_list_:List<PhotoModel> = List<PhotoModel>()
    
}

// 发起邀约
class InvitationRequestModel: Object {

    dynamic var from_uid_ = CurrentUser.uid_
    
    dynamic var to_uid_ = -1000
    
    dynamic var service_id_ = -1000
    
    dynamic var day_count_ = 1
}

// 推荐服务者
class RecommentServantRequestModel: Object {
    
    dynamic var city_code_ = 0
    
    dynamic var recommend_type_ = 1
}
