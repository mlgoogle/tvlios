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

class UserModel : Object {
    dynamic var uid_: Int = -1
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
    dynamic var nickname_: String?
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
