//
//  CommonAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/6.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class CommonAPI: SocketAPI {
    
    func skills(complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .SkillsInfoRequest)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(SkillsModel.classForCoder()))
            }, error: error)
    }
    
    func centurionCardBaseInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionCardInfoRequest)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardBaseInfosModel.classForCoder()))
            }, error: error)
    }
    
    func centurionCardPriceInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionVIPPriceRequest)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardPriceInfosModel.classForCoder()))
            }, error: error)
    }
    //城市选择
    func cityNameInfo(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .GetServiceCity)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CityNameInfoModel.classForCoder()))
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
        let packet = SocketDataPacket(opcode: .InsurancePayRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InsuranceSuccessModel.classForCoder()))
            }, error: error)
    }

    // 获取验证码
    func verifyCode(model: VerifyCodeRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .SendMessageVerify, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(VerifyInfoModel.classForCoder()))
            }, error: error)
    }
    
    // 注册设备
    func regDevice(model: RegDeviceRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .PutDeviceToken, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    
    // 请求图片上传token
    func uploadPhotoToken(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .UploadImageToken)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UploadPhotoModel.classForCoder()))
            }, error: error)
    }
    
    // 请求微信支付
    func WXPlaceOrder(model: WXPlaceOrderRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .WXPlaceOrderRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(WXPlcaeOrderModel.classForCoder()))
            }, error: error)
    }
    
    // 请求微信支付状态
    func WXPayStatus(model: ClientWXPayStatusRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ClientWXPayStatusRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(ClienWXPayStatusModel.classForCoder()))
            }, error: error)
    }
    
    // 提交身份证信息
    func IDVerify(model: IDverifyRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .IDVerifyRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?(nil)
            }, error: error)
    }
}
