//
//  ServantModels.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/9.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift


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
    
}

// 助理model，用于获取助理动态
class ServantInfoModel:Object {
    dynamic var uid_ = 0
    dynamic var view_uid_ = CurrentUser.uid_
    dynamic var page_num_ = 0
    dynamic var page_count_ = 15
}

class servantDynamicModel: Object {
    dynamic var dynamic_id_ = 0
    dynamic var dynamic_text_:String?
    dynamic var dynamic_url_:String?
    dynamic var dynamic_like_count_ = 0
    dynamic var is_liked_ = 0
    
}

class ServantDynamicListModel: Object {
    let dynamic_list_:List<servantDynamicModel> = List<servantDynamicModel>()
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
