//
//  SocketAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/6.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class SocketAPI {
    
    func startRequest(packet: SocketDataPacket, complete: CompleteBlock?, error: ErrorBlock?) {
        SocketRequestManage.shared.startRequest(packet, complete: complete, error: error)
    }
}
