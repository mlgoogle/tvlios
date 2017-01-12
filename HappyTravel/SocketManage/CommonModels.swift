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

//城市信息
class CityNameBaseInfo: Object {
    
    dynamic var city_name_:String?
    
    dynamic var city_code_:Int = 0
    
    dynamic var province_name_:String?
    
    dynamic var province_code_:Int = 0
    
}

class CityNameInfoModel: Object {
    
    let service_city_ = List<CityNameBaseInfo>()
    
}

//保险金额请求
class InsuranceBaseInfo: Object {
    
    dynamic var insurance_type_:Int64 = 0
    
    dynamic var order_price_:Int64 = 0
}
//保险金额返回
class InsuranceInfoModel: Object {
    
    dynamic var insurance_price_:Int64 = 0
    
}
//保险支付请求
class InsurancePayBaseInfo: Object {
    
    dynamic var insurance_price:Int64 = 0
    
    dynamic var insurance_username_:String?
}
class InsuranceSuccessModel: Object {
    
    dynamic var is_success_:Int64 = 0
    
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

//身份证信息
class IDverifyRequestModel: UserBaseModel {
    
    dynamic var id_card_num_:String?
    
    dynamic var id_card_name:String?
}
