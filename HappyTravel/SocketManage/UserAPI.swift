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
    
    func userCenturionCardInfo(model: UserBaseModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .UserCenturionCardInfoRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserCenturionCardInfoModel.classForCoder()))
            }, error: error)
    }
    
    func uploadContact(model: UploadContactModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .Login, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
            }, error: error)
    }
    //保险金额
    func insuranceInfo(model: InsuranceBaseInfo, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .InsuranceRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InsuranceInfoModel.classForCoder()))
            
            }, error: error)
    }
    //保险支付
    func insurancePay(model: InsurancePayBaseInfo, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .InsuranceRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InsuranceSuccessModel.classForCoder()))
            
            }, error: error)
    }

    
    func authStatus(complete: CompleteBlock?, error: ErrorBlock?) {
        let model = UserBaseModel()
        model.uid_ = CurrentUser.uid_
        let packet = SocketDataPacket(opcode: .CheckAuthenticateResult, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    
}
