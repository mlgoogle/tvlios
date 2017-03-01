//
//  UserSocketAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD


class UserAPI: SocketAPI {
    
    func autoLogin() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.Passwd) != nil
    }
    /**
     登录
     */
    func login(model: LoginModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .Login, model: model)
        SVProgressHUD.showProgressMessage(ProgressMessage: "登录中...")
        startRequest(packet, complete: { (response) in
            SVProgressHUD.dismiss()
            complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
        }, error: { (err) in
            SVProgressHUD.showErrorMessage(ErrorMessage: err.localizedDescription, ForDuration: 1.5, completion: nil)
            error?(err)
        })
    }
    
    /**
     上传用户通讯录
     */
    func uploadContact(model: UploadContactModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .UploadContact, model: model)
        startRequest(packet, complete: { (response) in
            
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }

    /**
     获取用户余额
     
     - parameter complete:
     - parameter error:
     */
    func cash(complete: CompleteBlock?, error: ErrorBlock?) {
        let model = UserBaseModel()
        model.uid_ = CurrentUser.uid_
        let packet = SocketDataPacket(opcode: .UserCash, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    //请求修改密码
    func modifyPwd(model: ModifyPwdBaseInfo, complete: CompleteBlock?, error:ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ModifyPassword, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    //注册新用户
    func registerAccount(model: RegisterAccountBaseInfo, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .Register, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(RegisterAccountModel.classForCoder()))
        }, error: error)
    }
    /**
     修改用户信息
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func modifyUserInfo(model: ModifyUserInfoModel, complete: CompleteBlock?, error:ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ModifyPersonalInfo, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    
    //请求验证密码的正确性
    func passwdVerify(model: PasswdVerifyBaseInfo, complete: CompleteBlock?, error:ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .PasswdVerify, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    //请求修改设置支付密码
    func setupPaymentCode(model: SetPayCodeBaseInfo, complete: CompleteBlock?, error:ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .SetupPaymentCode, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }

}
