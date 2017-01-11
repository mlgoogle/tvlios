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
    
    
    func setReceiveMsgBlock(complete:CompleteBlock) {
        SocketRequestManage.shared.receiveChatMsgBlock = { (response) in
            let jsonResponse = response as! SocketJsonResponse
            let model = jsonResponse.responseModel(MessageModel.classForCoder())
            if  model != nil {
                complete(model)
            }
        }
    }
    
}