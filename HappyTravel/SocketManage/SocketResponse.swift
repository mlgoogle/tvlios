//
//  SocketResponse.swift
//  viossvc
//
//  Created by yaowang on 2016/11/25.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import RealmSwift
import Realm.RLMSchema

class SocketResponse {
    private var body:SocketDataPacket?
    var statusCode:Int16? {
        get {
            return body?.opcode
        }
    }
    
    func responseData() -> NSData? {
        return body?.data
    }
    
    init(packet:SocketDataPacket) {
        body = packet
    }
}

class SocketJsonResponse: SocketResponse {
    
    func responseJsonObject() -> AnyObject? {
        if body?.data?.length == 0  {
            return nil
        }
        
        return try! NSJSONSerialization.JSONObjectWithData(body!.data!, options: NSJSONReadingOptions.MutableContainers)
    }
    
    func responseJson<T:NSObject>() -> T? {
        var object = responseJsonObject()
        if object != nil && T.isKindOfClass(Object) {
            object = responseModel(T.classForCoder())
        }
        return object as? T
    }
    
    func responseModel(modelClass: AnyClass) ->AnyObject? {
        if let object = responseJsonObject() {
            let cls = modelClass as! Object.Type
            return cls.init(value: object as! [String: AnyObject], schema: RLMSchema.partialSharedSchema())
        }
        return nil
    }
    
}

