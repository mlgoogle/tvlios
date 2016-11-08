//
//  SocketManagerExt.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/8.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit



extension SocketManager{
    private static var recevieDataKey = "recevieDataKey"
    typealias recevieDataBlock = @convention(block)([NSObject : AnyObject]?) ->()
    static var completation :recevieDataBlock? {
       
        set(completationObject){
            let setObject: AnyObject = unsafeBitCast(completationObject, AnyObject.self)
            objc_setAssociatedObject(self, &recevieDataKey, setObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get{
            let getBlock = objc_getAssociatedObject(self, &recevieDataKey)
            if getBlock == nil {
                return nil
            }
            let getObject = unsafeBitCast(getBlock, recevieDataBlock.self)
            return getObject

        }
    }
    
    static func sendData(opcode: SockOpcode, data: AnyObject?, result: recevieDataBlock?) {
        SocketManager.sendData(opcode, data: data)
        completation = result
    }
    
}