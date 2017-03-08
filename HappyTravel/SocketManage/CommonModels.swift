//
//  CommonModels.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/6.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift


class SkillModel: Object {
    
    dynamic var skill_id_:Int = 0
    
    dynamic var skill_name_:String?
    
    dynamic var skill_type_ = 0
    
    var labelWidth:Float {
        let string:NSString = skill_name_!
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        let rect = string.boundingRectWithSize(CGSizeMake(0, 24),
                                               options: options,
                                               attributes: [NSFontAttributeName : UIFont.systemFontOfSize(AtapteWidthValue(12))],
                                               context: nil)
        let labelWidth = Float(rect.size.width) + 30
        return labelWidth
    }
}

class SkillsModel: Object {
    
    let skills_list_ = List<SkillModel>()
}

// 发送验证码
class VerifyCodeRequestModel: Object {
    
    dynamic var verify_type_ = 0
    
    dynamic var phone_num_:String?
}
class VerifyInfoModel: Object {
    
    dynamic var timestamp_ = 0
    
    dynamic var token_:String?
}

// 注册设备
class RegDeviceRequestModel: UserBaseModel {
    
    dynamic var device_token_:String?
}

// 照片上传
class UploadPhotoModel: Object {
    
    dynamic var img_token_:String?
    
    dynamic var valid_time_ = 0
}

// 请求支付
class WXPlaceOrderRequestModel: UserBaseModel {
    
    dynamic var title_ = "优悦-余额充值"
    
    dynamic var price_ = 0
}

class WXPlcaeOrderModel: Object {
    
    dynamic var recharge_id_:String?
    
    dynamic var prepayid:String?
    
    dynamic var partnerid:String?
    
    dynamic var appid:String?
    
    dynamic var noncestr:String?
    
    dynamic var package:String?
    
    dynamic var sign:String?
    
    dynamic var timestamp:String?
}
//检查版本号
class CheckVersionRequestModel: Object {
    dynamic var app_type_ = 0
}
class ClientWXPayStatusRequestModel: UserBaseModel {
    
    dynamic var recharge_id_ = 0
    
    dynamic var pay_result_ = 1
}

class ClienWXPayStatusModel: Object {
    
    dynamic var return_code_ = -1
    
    dynamic var user_cash_ = -1
}

//判断余额是否足够
class PayOrderStatusModel: Object{
    dynamic var result_ = -1
    dynamic var order_id_ = 0
}

//获取微信联系方式
class GetRelationStatusModel: Object{
    dynamic var result_ = -1
    dynamic var wx_url_: String?
    dynamic var wx_num_: String?
    dynamic var service_price_ = 0
}
//订单消息列表子集
class OrderListCellModel: UserModel{
    dynamic var order_id_ = 0
    dynamic var to_uid_ = 0
    dynamic var to_uid_nickename_:String?
    dynamic var order_time_: String?
    dynamic var is_evaluate_ = -1
    dynamic var to_uid_url_: String?
}
//订单消息列表请求结果
class OrderListModel: Object{
    let order_msg_list_ = List<OrderListCellModel>()
}



