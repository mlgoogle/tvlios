//
//  FollowModels.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/3/1.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import RealmSwift


// 关注、取关、查看
class FollowModel: Object {
    
    dynamic var follow_from_ = CurrentUser.uid_
    
    dynamic var follow_to_ = 0
    
    dynamic var follow_type_ = 3 // 1：关注 2：取关 3：查询
}
// 关注、取关、查看请求结果
class FollowedModel: Object {
    
    dynamic var result_ = -1 // 0：成功/已关注 1：失败/未关注
}

// 关注列表
class FollowListRequestModel: UserBaseModel {
    
    dynamic var follow_type_ = 1 // 1：我关注的人
    
    dynamic var page_num_ = 0
    
    dynamic var page_count_ = 10
}
// 关注列表子集
class FollowListCellModel: UserBaseModel {
    
    dynamic var nickname_:String?
    
    dynamic var head_url_:String?
    
    dynamic var authenticate_ = 0
    
    dynamic var follow_count_ = 0
}
// 关注列表请求结果
class FollowListModel: Object {
    
    let follow_list_ = List<FollowListCellModel>()
}


// 关注数
class FollowCountRequestModel: UserBaseModel {
    
}
// 关注数请求结果
class FollowCountModel: Object {
    
    dynamic var follow_count_ = 0
}
