//
//  UserSocketAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD


class UserSocketAPI {
    
    static var shared = UserSocketAPI()
    
    let requestManager = SocketRequestManage.shared
    
    static func autoLogin() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.Passwd) != nil
    }
    
    static func login(model: LoginModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let api = UserSocketAPI.shared
        let packet = SocketDataPacket(opcode: .Login, model: model)
        SVProgressHUD.showProgressMessage(ProgressMessage: "登录中...")
        api.requestManager.startRequest(packet, complete: { (response) in
            SVProgressHUD.dismiss()
            complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
        }, error: { (err) in
            SVProgressHUD.showErrorMessage(ErrorMessage: err.localizedDescription, ForDuration: 1.5, completion: nil)
            error?(err)
        })
    }
    
    static func centurionCardBaseInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionCardInfoRequest)
        UserSocketAPI.shared.requestManager.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardBaseInfosModel.classForCoder()))
            }, error: error)
    }
    
    static func centurionCardPriceInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionVIPPriceRequest)
        UserSocketAPI.shared.requestManager.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardPriceInfosModel.classForCoder()))
            }, error: error)
    }
    
    static func userCenturionCardInfo(model: UserBaseModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .UserCenturionCardInfoRequest, model: model)
        UserSocketAPI.shared.requestManager.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserCenturionCardInfoModel.classForCoder()))
            }, error: error)
    }
}
