//
//  ChatAPI.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/10.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation

class ChatAPI: SocketAPI {
    
    func chat(model:ChatModel, complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .SendChatMessage, model: model, type: .Chat)
        startRequest(packet, complete: { (response) in
            let responseMessage = (response as? SocketJsonResponse)?.responseModel(MessageModel.classForCoder())
            complete?(responseMessage)
            }, error: error)
    }
    
    
    func requestUnReadMessage(model:UnReadMessageRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .UnreadMessageRequest, model: model, type: .Chat)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(MessageModel.classForCoder(), listKey: "msg_list_"))
            }, error: error)
    }
    
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
        let packet = SocketDataPacket(opcode: .FeedbackMSGReadCnt, model: model, type: .Chat)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseJsonObject())
            }, error: error)
    }
}