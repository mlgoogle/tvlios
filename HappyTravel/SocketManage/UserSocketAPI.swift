//
//  UserSocketAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class UserSocketAPI {
    
    static var shared = UserSocketAPI()
    
    let requestManager = SocketRequestManage.shared
    
    static func autoLogin() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.Passwd) != nil
    }
    
    static func login(model: LoginModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let api = UserSocketAPI.shared
        let packet = SocketDataPacket(opcode: .Login, model: model)
        api.requestManager.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
            }, error: error)
    }
    static func uploadContact(model:UploadContactModel, complete: CompleteBlock?, error: ErrorBlock?){
        let api = UserSocketAPI.shared
        let packet = SocketDataPacket(opcode: .UploadContactRequest, model: model)
        api.requestManager.startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
            }, error: error)
    }
}
