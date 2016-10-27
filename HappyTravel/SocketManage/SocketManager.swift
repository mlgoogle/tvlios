//
//  SocketManager.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/11.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import XCGLogger
import SwiftyJSON

enum SockErrCode : Int {

    case NoOrder = -1015
}

class SocketManager: NSObject, GCDAsyncSocketDelegate {

    
    enum SockOpcode : Int {
        case AppError = -1
        case Heart = 1000
        case Login = 1001
        case Logined = 1002
        case GetServantInfo = 1003
        case ServantInfo = 1004
        case GetServantDetailInfo = 1005
        case ServantDetailInfo = 1006
        case GetRecommendServants = 1007
        case RecommendServants = 1008
        case GetServiceCity = 1009
        case ServiceCity = 1010
        case ModifyPassword = 1011
        case ModifyPasswordResult = 1012
        case GetUserInfo = 1013
        case UserInfoResult = 1014
        case SendMessageVerify = 1019
        case MessageVerifyResult = 1020
        case RegisterAccountRequest = 1021
        case RegisterAccountReply = 1022
        case SendImproveData = 1023
        case ImproveDataResult = 1024
        case ObtainTripRequest = 1025
        case ObtainTripReply = 1026
        case DrawBillRequest = 1029
        case DrawBillReply = 1030
        case PutDeviceToken = 1031
        case DeviceTokenResult = 1032
        case InvoiceInfoRequest = 1033
        case InvoiceInfoReply = 1034
        case CenturionCardInfoRequest = 1035
        case CenturionCardInfoReply = 1036
        case UserCenturionCardInfoRequest = 1037
        case UserCenturionCardInfoReply = 1038
        case CenturionCardConsumedRequest = 1039
        case CenturionCardConsumedReply = 1040
        case SkillsInfoRequest = 1041
        case SkillsInfoReply = 1042
        case AppointmentRequest = 1043
        case AppointmentReply = 1044
        
        
        case AskInvitation = 2001
        case InvitationResult = 2002
        case SendChatMessage = 2003
        case RecvChatMessage = 2004
        case GetChatRecord = 2005
        case ChatRecordResult = 2006
        case FeedbackMSGReadCnt = 2007
        case MSGReadCntResult = 2008
        case EvaluateTripRequest = 2009
        case EvaluatetripReply = 2010
        case AnswerInvitationRequest = 2011
        case AnswerInvitationReply = 2012
        
    }
    
    class var shareInstance : SocketManager {
        struct Static {
            static let instance:SocketManager = SocketManager()
        }
        return Static.instance
    }
    
    var socket:GCDAsyncSocket?
    
    var buffer:NSMutableData = NSMutableData()
 
    static var last_chat_id:Int = 0
    
    static var isLogout = false
    
    override init() {
        super.init()
        
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: dispatch_get_main_queue())
        connectSock()
        
    }
    
    func connectSock() {
        buffer = NSMutableData()
        do {
            try socket?.connectToHost("61.147.114.78", onPort: 10001, withTimeout: 5)
        } catch GCDAsyncSocketError.ClosedError {
            
        } catch GCDAsyncSocketError.ConnectTimeoutError {
            
        } catch {
            
        }
    }
    
    static func logoutCurrentAccount() {
        let sock:SocketManager? = SocketManager.shareInstance
        if sock == nil {
            return
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CommonDefine.UserName)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CommonDefine.Passwd)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CommonDefine.UserType)
        SocketManager.isLogout = true
        DataManager.currentUser?.login = false
        sock?.socket?.disconnect()
    }
    
    static func getErrorCode(dict: [String: AnyObject]) -> SockErrCode? {
        if let err = dict["error_"] {
            return SockErrCode(rawValue: err as! Int)
        }
        return nil
    }
    
    static func sendData(opcode: SockOpcode, data: AnyObject?) ->Bool {
        let sock:SocketManager? = SocketManager.shareInstance
        if sock == nil {
            return false
        }
        let head = SockHead()
        head.fields["isZipEncrypt"] = -1
        head.fields["opcode"] = -1
        head.fields["type"] = 1
        head.fields["signature"] = 3
        head.fields["timestamp"] = Int(UInt64(NSDate().timeIntervalSince1970))
        head.fields["sessionID"] = 7
        head.fields["reserved"] = 8
        
        var bodyJSON:JSON?
        var body:NSData?
        switch opcode {
        case .Heart:
            if DataManager.currentUser!.uid == -1 {
                return false
            }
            head.fields["opcode"] = 1000
            let dict:Dictionary<String, AnyObject> = ["uid_": DataManager.currentUser!.uid]
            bodyJSON = JSON.init(dict)
            XCGLogger.debug("Heart")
            break
        case .Login:
            head.fields["opcode"] = 1001
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            XCGLogger.info(data as! Dictionary<String, AnyObject>)
            break
        case .GetServantInfo:
            head.fields["opcode"] = 1003
            let dict:Dictionary<String, AnyObject> = ["latitude_": DataManager.currentUser!.gpsLocationLat,
                                                      "longitude_": DataManager.currentUser!.gpsLocationLon,
                                                      "distance_": 20.1]
            bodyJSON = JSON.init(dict)
            break
        case .GetServantDetailInfo:
            head.fields["opcode"] = 1005
            let info = data as! UserInfo
            let dict:Dictionary<String, AnyObject> = ["uid_": info.uid]
            bodyJSON = JSON.init(dict)
            break
        case .GetRecommendServants:
            head.fields["opcode"] = 1007
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .GetServiceCity:
            head.fields["opcode"] = 1009
            break
        case .ModifyPassword:
            head.fields["opcode"] = 1011
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .GetUserInfo:
            head.fields["opcode"] = 1013
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .SendMessageVerify:
            head.fields["opcode"] = 1019
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .RegisterAccountRequest:
            head.fields["opcode"] = SockOpcode.RegisterAccountRequest.rawValue
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .SendImproveData:
            head.fields["opcode"] = 1023
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .ObtainTripRequest:
            head.fields["opcode"] = SockOpcode.ObtainTripRequest.rawValue
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .DrawBillRequest:
            head.fields["opcode"] = SockOpcode.DrawBillRequest.rawValue
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .InvoiceInfoRequest:
            head.fields["opcode"] = SockOpcode.DrawBillRequest.rawValue
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .PutDeviceToken:
            head.fields["opcode"] = 1031
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .CenturionCardInfoRequest:
            head.fields["opcode"] = SockOpcode.CenturionCardInfoRequest.rawValue
            break
        case .UserCenturionCardInfoRequest:
            head.fields["opcode"] = SockOpcode.UserCenturionCardInfoRequest.rawValue
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .CenturionCardConsumedRequest:
            head.fields["opcode"] = SockOpcode.CenturionCardConsumedRequest.rawValue
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .SkillsInfoRequest:
            head.fields["opcode"] = SockOpcode.SkillsInfoRequest.rawValue
            break
        case .AppointmentRequest:
            head.fields["opcode"] = SockOpcode.AppointmentRequest.rawValue
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
            
            
        case .AskInvitation:
            head.fields["opcode"] = 2001
            head.fields["type"] = 2
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .SendChatMessage:
            head.fields["opcode"] = 2003
            head.fields["type"] = 2
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .GetChatRecord:
            head.fields["opcode"] = 2005
            head.fields["type"] = 2
//            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            let dict = ["from_uid_": 1, "to_uid_": 2, "count_": 5, "last_chat_id_": SocketManager.last_chat_id]
            bodyJSON = JSON.init(dict)
            break
        case .FeedbackMSGReadCnt:
            head.fields["opcode"] = SockOpcode.FeedbackMSGReadCnt.rawValue
            head.fields["type"] = 2
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .EvaluateTripRequest:
            head.fields["opcode"] = SockOpcode.EvaluateTripRequest.rawValue
            head.fields["type"] = 2
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .AnswerInvitationRequest:
            head.fields["opcode"] = SockOpcode.AnswerInvitationRequest.rawValue
            head.fields["type"] = 2
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        default:
            break
        }
        do {
            body = try bodyJSON?.rawData()
        } catch {
            
        }
        if opcode == SockOpcode.AppError {
            return false
        }
        
        if body == nil {
            head.fields["dataLen"] = 0
            head.fields["packageLen"] = SockHead.size
        } else {
            head.fields["dataLen"] = body!.length
            head.fields["packageLen"] = SockHead.size + body!.length
        }
        let package = head.makePackage()!.mutableCopy() as! NSMutableData
        if body != nil {
            package.appendData(body!)
        }
        sock?.socket?.writeData(package, withTimeout: 5, tag: 1)
        
        return true
        
    }
    
    func recvData(head: SockHead?, body:AnyObject?) ->Bool {
        if head == nil {
            return false
        }
        let opcode = (head!.fields["opcode"]! as! NSNumber).integerValue
        switch SockOpcode(rawValue: opcode)! {
        case .Logined:
            let dict = JSON.init(data: body as! NSData)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginResult, object: nil, userInfo: ["data": dict.dictionaryObject!])
            XCGLogger.info(dict.dictionaryObject!)
            SocketManager.sendData(.GetChatRecord, data: nil)
            break
        case .ServantInfo:
            let dict = JSON.init(data: body as! NSData)
            if dict.count == 0 {
                return false
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ServantInfo, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ServantDetailInfo:
            let dict = JSON.init(data: body as! NSData)
            if dict.count == 0 {
                return false
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ServantDetailInfo, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .RecommendServants:
            let dict = JSON.init(data: body as! NSData)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.RecommendServants, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ServiceCity:
            let dict = JSON.init(data: body as! NSData)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ServiceCitys, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ModifyPasswordResult:
            if (head!.fields["type"] as! NSNumber).integerValue == 0 {
                XCGLogger.warning("Modify passwd failed")
            }
            break
        case .UserInfoResult:
            let dict = JSON.init(data: body as! NSData)
            for info in dict["userinfo_list"] {
                let user = UserInfo()
                user.setInfo(.Other, info: info.1.dictionaryObject!)
                DataManager.updateUserInfo(user)
            }
            break
        case .MessageVerifyResult:
            let dict = JSON.init(data: body as! NSData)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.VerifyCodeInfo, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .RegisterAccountReply:
            let dict = JSON.init(data: body as! NSData)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.RegisterAccountReply, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ImproveDataResult:
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ImproveDataSuccessed, object: nil, userInfo: nil)
            break
        case .ObtainTripReply:
            if (body as? NSData)?.length <= 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ObtainTripReply, object: nil, userInfo: ["lastOrderID": -1001])
                return true
            }
            let dict = JSON.init(data: body as! NSData)
            if let tripList = dict.dictionaryObject!["trip_list"] as? Array<Dictionary<String, AnyObject>> {
                var lastOrderID = 0
                for trip in tripList {
                    let hodotemerInfo = HodometerInfo(value: trip)
                    DataManager.insertHodometerInfo(hodotemerInfo)
                    lastOrderID = hodotemerInfo.order_id_
                }
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ObtainTripReply, object: nil, userInfo: ["lastOrderID": lastOrderID])
            }
            break
        case .DeviceTokenResult:
            
            break
        case .DrawBillReply:
            let json = JSON.init(data: body as! NSData)
            var dict = ["invoice_status_": HodometerStatus.InvoiceMaking.rawValue]
            let oidStr = json.dictionaryObject!["oid_str_"] as? String
            let oids = oidStr?.componentsSeparatedByString(",")
            for oid in oids! {
                if oid == "" {
                    continue
                }
                dict["order_id_"] = Int.init(oid)
                DataManager.updateData(HodometerInfo.self, data: dict)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.DrawBillReply, object: nil, userInfo: ["data": json.dictionaryObject!])
            break
        case .CenturionCardInfoReply:
            let dict = JSON.init(data: body as! NSData)
            if let privilegeList = dict.dictionaryObject!["privilege_list"] as? Array<Dictionary<String, AnyObject>> {
                for privilege in privilegeList {
                    let centurionCardServiceInfo = CenturionCardServiceInfo(value: privilege)
                    DataManager.insertCenturionCardServiceInfo(centurionCardServiceInfo)
                }
                
            }
            break
        case .UserCenturionCardInfoReply:
            let dict = JSON.init(data: body as! NSData)
            DataManager.currentUser?.setInfo(.CurrentUser, info: dict.dictionaryObject)
            break
        case .CenturionCardConsumedReply:
            let dict = JSON.init(data: body as! NSData)
            if let orderList = dict.dictionaryObject!["blackcard_consume_record"] as? Array<Dictionary<String, AnyObject>> {
                var lastOrderID = 0
                for order in orderList {
                    let info = CenturionCardConsumedInfo(value: order)
                    DataManager.insertCerturionCardConsumedInfo(info)
                    lastOrderID = info.order_id_
                }
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.CenturionCardConsumedReply, object: nil, userInfo: ["lastOrderID": lastOrderID])
            }
            break
        case .SkillsInfoReply:
            let dict = JSON.init(data: body as! NSData)
            if let skillList = dict.dictionaryObject!["skills_list"] as? Array<Dictionary<String, AnyObject>> {
                for skill in skillList {
                    let info = SkillInfo(value: skill)
                    DataManager.insertData(SkillInfo.self, data: info)
                    
                }

            }
            break
        case .AppointmentReply:
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.AppointmentReply , object: nil, userInfo: nil)
            break
            
            
            
        case .InvitationResult:
            let dict = JSON.init(data: body as! NSData)
            if let _ = SocketManager.getErrorCode(dict.dictionaryObject!) {
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.AskInvitationResult, object: nil, userInfo: dict.dictionaryObject)
                return true
            }
            let order = HodometerInfo(value: dict.dictionaryObject!)
            if order.is_asked_ == 1 {
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.AskInvitationResult, object: nil, userInfo: ["orderInfo": order])
                return true
            }
            DataManager.insertHodometerInfo(order)
            if UIApplication.sharedApplication().applicationState == .Background {
                let body = "系统消息: 您有新的行程消息!"
                var userInfo:[NSObject: AnyObject] = [NSObject: AnyObject]()
                userInfo["type"] = PushMessage.MessageType.System.rawValue
                userInfo["data"] = dict.dictionaryObject!
                localNotify(body, userInfo: userInfo)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.AskInvitationResult, object: nil, userInfo: ["orderInfo": order])
            }
            break
        case .RecvChatMessage:
            let dict = JSON.init(data: body as! NSData)
            let msg = PushMessage(value: dict.dictionaryObject!)
            DataManager.insertMessage(msg)
            
            if UIApplication.sharedApplication().applicationState == .Background {
                if let user = DataManager.getUserInfo(msg.from_uid_) {
                    let body = "\(user.nickname!): \(msg.content_!)"
                    var userInfo:[NSObject: AnyObject] = [NSObject: AnyObject]()
                    userInfo["type"] = PushMessage.MessageType.Chat.rawValue
                    userInfo["data"] = dict.dictionaryObject!
                    localNotify(body, userInfo: userInfo)
                }
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ChatMessgaeNotiy, object: nil, userInfo: ["data": msg])
            }
            break
        case .ChatRecordResult:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug("\(dict.dictionaryObject)")
            break
        case .MSGReadCntResult:
            
            break
        case .EvaluatetripReply:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug("\(dict.dictionaryObject)")
            break
        case .AnswerInvitationReply:
            
            break
        default:
            break
        }
        
        return true
    }
    
    func localNotify(body: String?, userInfo: [NSObject: AnyObject]?) {
        let localNotify = UILocalNotification()
        localNotify.fireDate = NSDate().dateByAddingTimeInterval(0.1)
        localNotify.timeZone = NSTimeZone.defaultTimeZone()
        localNotify.applicationIconBadgeNumber = DataManager.getUnreadMsgCnt(-1)
        localNotify.soundName = UILocalNotificationDefaultSoundName
        if #available(iOS 8.2, *) {
            localNotify.alertTitle = "V领队"
        } else {
            // Fallback on earlier versions
        }
        localNotify.alertBody = body!
        localNotify.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(localNotify)
        
    }
    
    // MARK: - GCDAsyncSocketDelegate
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        XCGLogger.info("didConnectToHost:\(host)  \(port)")
        SocketManager.isLogout = false
        
        sock.performBlock({() -> Void in
            sock.enableBackgroundingOnSocket()
        })
        socket?.readDataWithTimeout(-1, tag: 0)
        
        let username = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.UserName) as? String
        let passwd = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.Passwd) as? String
        var userType:Int?
        if let type = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.UserType) as? String {
            userType = Int.init(type)
        }
        
        if username != nil && passwd != nil && userType != nil {
            let dict = ["phone_num_": username!, "passwd_": passwd!, "user_type_": userType!]
            SocketManager.sendData(.Login, data: dict)
        }
        
//        performSelector(#selector(SocketManager.sendHeart), withObject: nil, afterDelay: 10)
    }
    
    func sendHeart() {
        SocketManager.sendData(.Heart, data: nil)
        performSelector(#selector(SocketManager.sendHeart), withObject: nil, afterDelay: 10)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        XCGLogger.warning("socketDidDisconnect:\(err)")
        if SocketManager.isLogout {
            connectSock()
            return
        }
        performSelector(#selector(SocketManager.connectSock), withObject: nil, afterDelay: 15)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        buffer.appendData(data)
        let headLen = SockHead.size
        while buffer.length >= headLen {
            let head = SockHead(data: buffer)
            let packageLen = Int(head.fields["packageLen"]! as! NSNumber)
            let bodyLen = Int(head.fields["dataLen"]! as! NSNumber)
            if buffer.length >= packageLen {
                let bodyData = buffer.subdataWithRange(NSMakeRange(headLen, bodyLen))
                buffer.setData(buffer.subdataWithRange(NSMakeRange(packageLen, buffer.length - packageLen)))
                recvData(head, body: bodyData)
            } else {
                break
            }
            
        }
        socket?.readDataWithTimeout(-1, tag: 0)
    
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0
    }
    
    deinit {
        socket?.disconnect()
    }
    
}


