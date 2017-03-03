//
//  ConsumeSocketAPI.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD


class ConsumeSocketAPI: SocketAPI{
    
    /**
     请求订单评论
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func requestComment(model:CommentDetaiRequsetModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CommentDetail, model: model ,type: .Chat)
        startRequest(packet, complete: { (response) in
            var model = (response as? SocketJsonResponse)?.responseModel(OrderCommentModel.classForCoder()) as? OrderCommentModel
            if model!.service_score_ == 0 && model!.user_score_ == 0 && model!.remarks_ == nil {
                model = nil
            }
            complete?(model)
            }, error: error)
    }
    /**
     评论订单
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func commentForOrder(model:CommentForOrderModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .EvaluateTrip, model: model,type: .Chat)
        startRequest(packet, complete: { (response) in
            
            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            complete?(jsonObject)
            
            }, error: error)
        
    }
    
    //支付微信号显示的信息费用
    func payOrder(model: PayOrderModel,complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .payOrder, model: model, type: .Chat)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(PayOrderStatusModel.classForCoder()))
            }, error: error)

    }
    
    //支付成功后获取微信联系方式
    func getRelation(model: getRelationModel,complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .getRelation, model: model, type: .User)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(getRelationStatusModel.classForCoder()))
            }, error: error)
        
        
    }
    
    
}