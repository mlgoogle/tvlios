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
        let packet = SocketDataPacket(opcode: .InsuranceRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InsuranceSuccessModel.classForCoder()))
            
            }, error: error)
    }


}
