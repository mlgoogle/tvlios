//
//  SocketAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/6.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class SocketAPI {
    
    private static var shared = UserSocketAPI()
    
    private let requestManager = SocketRequestManage.shared
    
    static func startRequest(packet: SocketDataPacket, complete: CompleteBlock?, error: ErrorBlock?) {
        SocketAPI.shared.requestManager.startRequest(packet, complete: complete, error: error)
    }
}
