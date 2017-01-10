//
//  ServantAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/9.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class ServantAPI: SocketAPI {
    
    func servantNearby(model: ServantNearbyModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .GetServantInfo, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(UserInfoModel.classForCoder(), listKey: "guide_list_"))
            }, error: error)
    }

    func servantDetail(model: UserBaseModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .GetServantDetailInfo, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(ServantDetailModel.classForCoder()))
            }, error: error)
    }
    
    func getUserInfoByString(model:UserInfoIDStrRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .GetUserInfo, model: model)
        startRequest(packet, complete: { (response) in
            
            complete?((response as? SocketJsonResponse)?.responseModels(UserInfoModel.classForCoder(), listKey: "userinfo_list_"))
            }, error: error)
        
    }
}