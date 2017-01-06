//
//  CommonAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/6.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class CommonAPI: SocketAPI {
    
    static func skills(complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .SkillsInfoRequest)
        startRequest(packet, complete: { (response) in
                complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
            }, error: error)
    }
    
}
