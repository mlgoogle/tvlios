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
        let packet = SocketDataPacket(opcode: .GetServantInfo, model: model)
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
        let packet = SocketDataPacket(opcode: .GetServantDetailInfo, model: model)
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
        let packet = SocketDataPacket(opcode: .GetUserInfo, model: model)
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
        let packet = SocketDataPacket(opcode: .PhotoWallRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(PhotoWallModel.classForCoder()))
            }, error: error)
    }
    /**
     邀约
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func invitaion(model: InvitationRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AskInvitation, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(HodometerInfoModel.classForCoder()))
            }, error: error)
        
    }
    /**
     预约
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func appointment(model:AppointmentServantRequestMdoel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AppointmentServantRequest, model: model)
        startRequest(packet, complete: { (response) in
            let jsonObject = (response as? SocketJsonResponse)?.responseModel(AppointmentServantReplyMdoel.classForCoder())
            complete?(jsonObject)
            }, error: error)
    }
    /**
     请求推荐服务者
     
     - parameter model:
     - parameter complete:
     - parameter error:    
     */
    func recommentServants(model: RecommentServantRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .GetRecommendServants, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(UserInfoModel.classForCoder(), listKey: "recommend_guide_"))
            }, error: error)
    }
}