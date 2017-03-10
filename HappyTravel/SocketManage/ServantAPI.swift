//
//  ServantAPI.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/9.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


class ServantAPI: SocketAPI {
    /**
     请求附近服务者信息
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func servantNearby(model: ServantNearbyModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ServantBaseInfo, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(UserInfoModel.classForCoder(), listKey: "guide_list_"))
            }, error: error)
    }

    /**
     请求服务者详情
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func servantDetail(model: UserBaseModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ServantDetailInfo, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(ServantDetailModel.classForCoder()))
            }, error: error)
    }
    /**
     根据uid字符串获取获取用户信息
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func getUserInfoByString(model:UserInfoIDStrRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .UserInfo, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(UserInfoModel.classForCoder(), listKey: "userinfo_list_"))
            }, error: error)
        
    }
    /**
     请求照片墙
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func requestPhotoWall(model:PhotoWallRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .PhotoWall, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(PhotoWallModel.classForCoder()))
            }, error: error)
    }
    
    /**
     助理获取动态数据列表
     
     - parameter model:
     
     - returns:
     */
    func requestDynamicList(model:ServantInfoModel,complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .DynamicList, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(ServantDynamicListModel.classForCoder()))
            
            }, error:error)
    }
    
}