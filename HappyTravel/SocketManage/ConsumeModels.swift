//
//  ConsumeModels.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift


class CommentDetaiRequsetModel: Object {
    dynamic var order_id_ = 0
}

class OrderCommentModel: Object {
    dynamic var order_id_ = 0
    dynamic var service_score_ = 0
    dynamic var user_score_ = 0
    dynamic var remarks_:String?
}
class CommentForOrderModel: OrderCommentModel {
    dynamic var from_uid_ = 0
    dynamic var to_uid_ = 0
}

class PayOrderRequestModel: Object {
    dynamic var from_uid_ = 0
    dynamic var to_uid_ = 0
    dynamic var service_prince_ = 0
    dynamic var wx_id_: String?
}
class GetRelationRequestModel: Object {
    dynamic var order_id_ = 0
    dynamic var uid_form_ = 0
    dynamic var uid_to_ = 0
}
class OrderListRequestModel: Object {
    dynamic var uid_ = 0
    dynamic var uid_type_ = 0
    dynamic var page_num_ = 0
    dynamic var page_count_ = 10
}
//个人简介
class PersonIntroRequestModel: Object{
    dynamic var uid_ = 0
    dynamic var introduce_: String?
    dynamic var type_ = 2
}

//邀约、预约付款
class PayForInvitationRequestModel: UserBaseModel {
    
    dynamic var order_id_ = -1000
    
    dynamic var passwd_:String?
}

class PayForInvitationModel: UserBaseModel {
    
    dynamic var order_id_ = -1000
    
    dynamic var result_ = -1
    
    dynamic var user_cash_ = 0
    
    dynamic var order_status_ = -1
}
