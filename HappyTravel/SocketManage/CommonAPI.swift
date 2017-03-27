//
//  CommonAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/6.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class CommonAPI: SocketAPI {

    // 获取验证码
    func verifyCode(model: VerifyCodeRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .MessageVerify, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(VerifyInfoModel.classForCoder()))
            }, error: error)
    }
    
    // 注册设备
    func regDevice(model: RegDeviceRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .RegisterDevice, model: model)
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
        let packet = SocketDataPacket(opcode: .WXPlaceOrder, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(WXPlcaeOrderModel.classForCoder()))
            }, error: error)
    }
    
    //检查版本号
    func checkVersion(model:CheckVersionRequestModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .VersionInfo, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    // 请求微信支付状态
    func WXPayStatus(model: ClientWXPayStatusRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ClientWXPayStatusRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(ClienWXPayStatusModel.classForCoder()))
            }, error: error)
    }
}
