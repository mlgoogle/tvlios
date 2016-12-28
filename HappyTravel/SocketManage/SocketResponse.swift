//
//  SocketResponse.swift
//  viossvc
//
//  Created by yaowang on 2016/11/25.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit

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
        body = packet;
    }
}

class SocketJsonResponse: SocketResponse {
    
    func responseJsonObject() -> AnyObject? {
        if body?.data?.length == 0  {
            return nil
        }
        
        return try! NSJSONSerialization.JSONObjectWithData(body!.data!, options: NSJSONReadingOptions.MutableContainers)
    }
    
    func responseJson<T:NSObject>() ->T? {
        var object = responseJsonObject()
        if object != nil && T.isKindOfClass(SockHead) {
            object = responseModel(T.classForCoder())
        }
        return object as? T
    }
    
    func responseModel(modelClass: AnyClass) ->AnyObject?{
        let object = responseJsonObject()
        if object != nil  {
//            return try! OEZJsonModelAdapter.modelOfClass(modelClass, fromJSONDictionary: object as! [NSObject : AnyObject])
        }
        return nil
    }
    
    func responseModels(modelClass: AnyClass) ->[AnyObject]? {
        let array:[AnyObject]? = responseJsonObject() as? [AnyObject]
        if array != nil {
//            return try! OEZJsonModelAdapter.modelsOfClass(modelClass, fromJSONArray: array)
        }
        return nil;
    }
    
    func responseResult() -> Int? {
        let dict = responseJsonObject() as? [String:AnyObject]
        if dict != nil && dict!["result_"] != nil {
            return dict!["result_"] as? Int;
        }
        return nil;
    }
    
}

