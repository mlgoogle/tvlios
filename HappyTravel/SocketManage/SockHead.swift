//
//  SockHead.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/11/9.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//


/*
 "signature": "Int16"],
 ["opcode": "Int16"],
 ["dataLen": "Int16"],
 ["timestamp": "UInt32"],
 ["sessionID": "Int64"],
 ["reserved": "Int32"
 */
import Foundation

class Head: NSObject {
    
    var len:Int16 = 0
    
    var zipEncryptType:Int8 = 0
    
    var type:Int8 = 0
    
    var signature:Int16 = 0
    
    var opcode:Int16 = 0
    
    var bodyLen:Int16 = 0
    
    var timestamp:UInt32 = 0
    
    var sessionID:Int64 = 0
    
    var reserved:Int32 = 0
    
}

func getSockHead(data: NSData) -> Head? {
    
    
    return nil
}
