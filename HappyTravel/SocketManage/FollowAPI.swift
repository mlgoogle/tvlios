//
//  FollowAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/3/1.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class FollowAPI: SocketAPI {
    
    func followStatus(model: FollowModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .FollowStatus, model: model)
        startRequest(packet, complete: { (response) in
            
            complete?((response as? SocketJsonResponse)?.responseModel(FollowedModel.classForCoder()))
            
            }, error: error)
    }
    
    func followList(model: FollowListRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .FollowList, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(FollowListCellModel.classForCoder(), listKey: "follow_list_"))
            }, error: error)
    }
    
    func followCount(model: FollowCountRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .FollowCount, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(FollowCountModel.classForCoder()))
            }, error: error)
    }
}
