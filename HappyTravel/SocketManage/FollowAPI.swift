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
            complete?((response as? SocketJsonResponse)?.responseModel(FollowListModel.classForCoder()))
            }, error: error)
    }
}
