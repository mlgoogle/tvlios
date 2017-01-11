//
//  ChatMessageHelper.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/11.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
protocol ReceivedChatDelegate:NSObjectProtocol {
    
    func receivedChatMessgae(message:MessageModel)
    
}

protocol RefreshChatSessionListDelegate:NSObjectProtocol {
    
    func refreshChatSeesionList()
}
class ChatMessageHelper: NSObject {
    static let shared = ChatMessageHelper()
    weak var refreshDelegate:RefreshChatSessionListDelegate?
    weak var delegate:ReceivedChatDelegate?
    override init() {
        super.init()
        APIHelper.chatAPI().setReceiveMsgBlock { [weak self](message) in
            let messageModel = message as? MessageModel
            if messageModel != nil {
                var userModel = DataManager.getData(UserInfoModel.self)?.filter("uid_ = \(messageModel!.from_uid_)").first
                if userModel == nil {
                    let model = UserInfoIDStrRequestModel()
                    model.uid_str_ = String(messageModel!.from_uid_)
                    APIHelper.servantAPI().getUserInfoByString(model, complete: { (response) in
                        let userModels = response as? Array<UserInfoModel>
                        userModel = userModels?.first
                        guard userModels?.count > 0 else {return}
                        DataManager.insertData(userModels!.first!)
                        
                        }, error: { (error) in
                            
                    })
                    
                }
                if UIApplication.sharedApplication().applicationState == .Background {
                    
                    let body = "\((userModel?.nickname_ ?? "云巅代号 \(messageModel!.from_uid_) 的用户给您发来消息")): \(messageModel!.content_!)"
                    var userInfo:[NSObject: AnyObject] = [NSObject: AnyObject]()
                    userInfo["type"] = messageModel!.msg_type_
                    userInfo["data"] = messageModel?.toDictionary()
                    self?.localNotify(body, userInfo: userInfo)
                }
                self?.reveicedMessage(messageModel!)
            }
            
        }
        
    }
    
    
    func reveicedMessage(messageModel:MessageModel) {
        DataManager.insertData(messageModel)
        delegate?.receivedChatMessgae(messageModel)
        refreshDelegate?.refreshChatSeesionList()
    }
    
    func localNotify(body: String?, userInfo: [NSObject: AnyObject]?) {
        let localNotify = UILocalNotification()
        localNotify.fireDate = NSDate().dateByAddingTimeInterval(0.1)
        localNotify.timeZone = NSTimeZone.defaultTimeZone()
        localNotify.applicationIconBadgeNumber = DataManager.getUnreadMsgCnt(-1)
        localNotify.soundName = UILocalNotificationDefaultSoundName
        if #available(iOS 8.2, *) {
            localNotify.alertTitle = "优悦出行"
        } else {
            // Fallback on earlier versions
        }
        localNotify.alertBody = body!
        localNotify.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(localNotify)
        
    }
}
