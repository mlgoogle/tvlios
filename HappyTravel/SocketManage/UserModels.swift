//
//  UserModels.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift


class LoginModel: Object {
    
    dynamic var phone_num_:String? = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.UserName) as? String
    
    dynamic var passwd_:String? = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.Passwd) as? String
    
    dynamic var user_type_:Int = 1
    
}

class UserBaseModel : Object {
    dynamic var uid_: Int = -1
}

class UserModel: UserBaseModel {
    dynamic var head_url_: String?
}

var CurrentUser = UserInfoModel()
class UserInfoModel: UserModel {
    dynamic var address_: String?
    dynamic var cash_lv_: Int = 0
    dynamic var credit_lv_: Int = 0
    dynamic var gender_: Int = 0
    dynamic var has_recharged_: Int = 0
    dynamic var latitude_: Double = 0.0
    dynamic var longitude_: Double = 0.0
    dynamic var nickname_: String? = "未登录"
    dynamic var phone_num_: String?
    dynamic var praise_lv_: Int = 0
    dynamic var register_status_: Int = 0
    dynamic var user_cash_: Int = 0
    dynamic var auth_status_: Int = -1 //-1:未认证, 0:认证中, 1:认证通过, 2:认证失败
    dynamic var currentBankCardNumber_:String?
    dynamic var currentBanckCardName_:String?
    dynamic var has_passwd_: Int = -1 //-1:未设置提现密码 1:已设置提现密码
    dynamic var levle_:Float = 0.0
    
    dynamic var skills_:String?
    
    dynamic var login_:Bool = false
}



class UploadContactModel: Object {    
    dynamic var uid = 0
    var contacts_list:List<ContactModel> = List<ContactModel>()
}

class ContactModel: Object {
    dynamic var name:String?
    dynamic var phone_num:String?
}

class UserInfoIDStrRequestModel: Object {
    dynamic var uid_str_:String?
}

class ServantNearbyModel: Object {
    
    dynamic var latitude_:Double = 0
    
    dynamic var longitude_:Double = 0
    
    dynamic var distance_ = 10.1
}

//请求修改密码
class ModifyPwdBaseInfo: Object {
    //["uid_": CurrentUser.uid_, "old_passwd_": "\(oldPasswd!)", "new_passwd_": "\(newPasswd!)"]
    dynamic var uid_:Int64 = 0
    
    dynamic var old_passwd_:String?
    
    dynamic var new_passwd_:String?
    
}
//密码修改返回
class ModifyPwdModel: Object {
    //成功返回空，失败见错误码
}

//修改个人信息
class ModifyUserInfoModel: UserBaseModel {
    
    dynamic var nickname_:String?
    
    dynamic var gender_ = 0
    
    dynamic var head_url_:String?
    
    dynamic var address_:String?
    
    dynamic var longitude_:Float = 0.0
    
    dynamic var latitude_:Float = 0.0
}

//请求注册新用户
class RegisterAccountBaseInfo: Object {
//    dynamic var invitation_phone_num_:String?
    dynamic var phone_num_:String?
    dynamic var passwd_:String?
    dynamic var user_type_:Int = 1//1游客2服务者
    dynamic var timestamp_:Int64 = 0//服务器下发时间戳
    dynamic var verify_code_:Int = 0//验证码
    dynamic var token_:String?
    
    
}
//注册新用户返回
class RegisterAccountModel: Object {
    dynamic var result:Int = 0//0已注册1注册成功
    dynamic var uid_:Int64 = 0//注册成功才返回
}

//请求提交身份证照片
class AuthenticateUserCardBaseInfo: Object {
    dynamic var uid_:Int64 = 0
    dynamic var front_pic_:NSString?
    dynamic var back_pic_:NSString?
}
//提交照片返回信息
class AuthenticateUserCardModel: Object {
    
    dynamic var review_status_:Int = 0
}
//请求验证密码的正确性
class PasswdVerifyBaseInfo: Object {
    dynamic var uid_:Int64 = 0
    dynamic var passwd_:String?
    dynamic var passwd_type_:Int = 0//密码类型，1-支付密码 2-登录密码
}
//请求设置修改支付密码
class SetPayCodeBaseInfo: Object {
    dynamic var uid_:Int64 = 0
    dynamic var new_passwd_:String?
    dynamic var old_passwd_:String?
    dynamic var passwd_type_:Int = 0 //1-支付 2-登录
    dynamic var change_type_:Int = 0 //0-设置新密码 1-修改密码
}
