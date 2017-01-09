//
//  UserSocketAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD


class UserSocketAPI: SocketAPI {
    
    static func autoLogin() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.Passwd) != nil
    }
    
    static func login(model: LoginModel, complete: CompleteBlock?, error: ErrorBlock?) {
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
    
    static func centurionCardBaseInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionCardInfoRequest)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardBaseInfosModel.classForCoder()))
            }, error: error)
    }
    
    static func centurionCardPriceInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionVIPPriceRequest)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardPriceInfosModel.classForCoder()))
            }, error: error)
    }
    
    static func userCenturionCardInfo(model: UserBaseModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .UserCenturionCardInfoRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserCenturionCardInfoModel.classForCoder()))
            }, error: error)
    }
    
    static func uploadContact(model: UploadContactModel, complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .Login, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
            }, error: error)
    }
    //城市选择
    static func cityNameInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .GetServiceCity)
        SocketAPI.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CityNameInfoModel.classForCoder()))
            }, error: error)
    }
    //保险金额
    static func insuranceInfo(model: InsuranceBaseInfo, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .InsuranceRequest, model: model)
        SocketAPI.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InsuranceInfoModel.classForCoder()))
            
            }, error: error)
    }
    //保险支付
    static func insurancePay(model: InsurancePayBaseInfo, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .InsuranceRequest, model: model)
        SocketAPI.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InsuranceSuccessModel.classForCoder()))
            
            }, error: error)
    }

    
}
