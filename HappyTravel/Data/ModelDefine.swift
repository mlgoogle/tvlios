//
//  ModelDefine.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/4.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class PhotoModel: Object {
    dynamic var photo_url_: String?
    dynamic var thumbnail_url_: String?
    dynamic var upload_time_: String?
    
}

class PhotoWallModel: Object {
    let photo_list_:List<PhotoModel> = List<PhotoModel>()

}

