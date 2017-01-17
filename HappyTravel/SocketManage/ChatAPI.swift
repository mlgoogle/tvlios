//
//  ChatAPI.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/10.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation

class ChatAPI: SocketAPI {
    
    
    /**
     发送聊天消息
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func chat(model:ChatModel, complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .SendChatMessage, model: model, type: .Chat)
        startRequest(packet, complete: { (response) in
            let responseMessage = (response as? SocketJsonResponse)?.responseModel(MessageModel.classForCoder())
            complete?(responseMessage)
            }, error: error)
    }
    
    /**
     请求离线消息
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func requestUnReadMessage(model:UnReadMessageRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .UnreadMessageRequest, model: model, type: .Chat)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(MessageModel.classForCoder(), listKey: "msg_list_"))
            }, error: error)
    }
    /**
     设置聊天消息接受block
     
     - parameter complete: 
     */
    func setReceiveMsgBlock(complete:CompleteBlock) {
        SocketRequestManage.shared.receiveChatMsgBlock = { (response) in
            let jsonResponse = response as! SocketJsonResponse
            let model = jsonResponse.responseModel(MessageModel.classForCoder())
            if  model != nil {
                complete(model)
            }
        }
    }
    
    //返回读取消息数
    func feedbackReadCount(model: ReadCountRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .FeedbackMSGReadCnt, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
    
    //联系客服
    func callOfficalSeravnt(complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .FeedbackMSGReadCnt)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(UserInfoModel.classForCoder()))
            }, error: error)
    }
}
