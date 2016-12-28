//
//  SockModel.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation


class Heart: SockHead {
    
    var body = ["uid_": DataManager.currentUser!.uid]
    
    override init() {
        super.init()
        
        opcode = SocketManager.SockOpcode.Heart.rawValue
    }
    
}
