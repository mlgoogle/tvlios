//
//  SockHead.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/11/9.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//


import Foundation

class SockHead: BMB2Object {
    
    var len:Int16 = Int16(SockHead.size)
    
    var zipEncryptType:Int8 = -1
    
    var type:Int8 = 1
    
    var signature:Int16 = 3
    
    var opcode:Int16 = -1
    
    var bodyLen:Int16 = 0
    
    var timestamp:UInt32 = UInt32(UInt64(Date().timeIntervalSince1970))
    
    var sessionID:Int64 = 0
    
    var reserved:Int32 = 0
    
}
