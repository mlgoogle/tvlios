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
import SVProgressHUD


enum SockErrCode : Int {

    case NoOrder = -1015
    case Other = 0
}

class SocketManager: NSObject, GCDAsyncSocketDelegate {
    enum SockOpcode: Int16 {
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
        case ServiceDetailRequest = 1027
        case ServiceDetailReply = 1028
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
        case InvoiceDetailRequest = 1045
        case InvoiceDetailReply = 1046
        case UploadImageToken = 1047
        case UploadImageTokenReply = 1048
        case WXPlaceOrderRequest = 1049
        case WXplaceOrderReply = 1050
        case ClientWXPayStatusRequest = 1051
        case ClientWXPayStatusReply = 1052
        case ServerWXPayStatusReply = 1054
        case AuthenticateUserCard = 1055
        case AuthenticateUserCardReply = 1056
        case CheckAuthenticateResult = 1057
        case CheckAuthenticateResultReply = 1058
        case CheckUserCash = 1067
        case CheckUserCashReply = 1068
        case AppointmentRecordRequest = 1069
        case AppointmentRecordReply = 1070
        
        
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
        case ServersManInfoRequest = 2013
        case ServersManInfoReply = 2014
        case CheckCommentDetail = 2015
        case CheckCommentDetailReplay = 2016

    }
    
    
    class var shareInstance : SocketManager {
        struct Static {
            static let instance:SocketManager = SocketManager()
        }
        return Static.instance
    }
    
    var socket:GCDAsyncSocket?
    
    var buffer:NSMutableData = NSMutableData()
    
    var sockTag = 0
 
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
            if !socket!.isConnected {
                try socket?.connectToHost("61.147.114.78", onPort: 10001, withTimeout: 5)
            }
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
        SocketManager.shareInstance.buffer = NSMutableData()
    }
    
    static func getErrorCode(dict: [String: AnyObject]) -> SockErrCode? {
        if let err = dict["error_"] {
            return SockErrCode(rawValue: err as! Int)
        }
        return nil
    }
    
    func postNotification(aName: String, object anObject: AnyObject?, userInfo aUserInfo: [NSObject : AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName(aName,
                                                                  object: anObject,
                                                                  userInfo: aUserInfo)
    }
    
    static func sendData(opcode: SockOpcode, data: AnyObject?) ->Bool {
        let sock:SocketManager? = SocketManager.shareInstance
        if sock == nil {
            return false
        }
        if !sock!.socket!.isConnected {
            sock!.connectSock()
        }
        let head = SockHead()
        head.opcode = opcode.rawValue
        head.type = Int8(opcode.rawValue / 1000)
        
        XCGLogger.debug(opcode)
        
        var bodyJSON:JSON?
        if data != nil {
             bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
        }
        var body:NSData?
        switch opcode {
        case .Heart:
            if DataManager.currentUser!.uid == -1 {
                return false
            }
            XCGLogger.debug("Heart")
        case .Login:
            XCGLogger.info(data as! Dictionary<String, AnyObject>)
        case .GetServantInfo:
            break
        case .GetServantDetailInfo:
            break
        case .GetRecommendServants:
            break
        case .GetServiceCity:
            break
        case .ModifyPassword:
            break
        case .GetUserInfo:
            break
        case .SendMessageVerify:
            break
        case .RegisterAccountRequest:
            break
        case .SendImproveData:
            break
            
        case .ServiceDetailRequest:
            break
        case .ObtainTripRequest:
            break
        case .DrawBillRequest:
            break
            
        case .InvoiceInfoRequest:
            break
        case .PutDeviceToken:
            break
        case .CenturionCardInfoRequest:
            break
        case .UserCenturionCardInfoRequest:
            break
        case .CenturionCardConsumedRequest:
            break
        case .SkillsInfoRequest:
            break
        case .AppointmentRequest:
            break
        case .InvoiceDetailRequest:
            break
        case .WXPlaceOrderRequest:
            break
        case .ClientWXPayStatusRequest:
            break
            
            
        case .AskInvitation:
            break
        case .SendChatMessage:
            break
        case .GetChatRecord:
            /*
            let dict = ["from_uid_": 1, "to_uid_": 2, "count_": 5, "last_chat_id_": SocketManager.last_chat_id]
            bodyJSON = JSON.init(dict)
             */
            break
        case .FeedbackMSGReadCnt:
            break
        case .EvaluateTripRequest:
            break
        case .AnswerInvitationRequest:
            break
        case .ServersManInfoRequest:
            break
        case .UploadImageToken:
            break
        case .AuthenticateUserCard:
            break
        case .CheckAuthenticateResult:
            break
        case .CheckUserCash:
            break
        case .AppointmentRecordRequest:
            break
            
        case .CheckCommentDetail:
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
        
        if body != nil {
            head.bodyLen = Int16(body!.length)
            head.len = Int16(SockHead.size + body!.length)
        }
        let package = head.pack()!.mutableCopy() as! NSMutableData
        if body != nil {
            package.appendData(body!)
        }
        
        sock?.socket?.writeData(package, withTimeout: 5, tag: sock!.sockTag)
        sock?.sockTag += 1
        
        return true
        
    }
    
    func recvData(head: SockHead?, body:AnyObject?) ->Bool {
        if head == nil {
            return false
        }
        var jsonBody:JSON?
        if body != nil && (body as! NSData).length > 0 {
            jsonBody = JSON.init(data: body as! NSData)
            if let err = SocketManager.getErrorCode((jsonBody?.dictionaryObject)!) {
                XCGLogger.warning(err)
            }
            
        }
        switch SockOpcode(rawValue: head!.opcode)! {
        case .Logined:
            logined(jsonBody)
        case .ServantInfo:
            servantInfoReply(jsonBody)
        case .ServantDetailInfo:
            servantDetailInfoReply(jsonBody)
        case .RecommendServants:
            recommonServantsReply(jsonBody)
        case .ServiceCity:
            servicesCityReply(jsonBody)
        case .ModifyPasswordResult:
            modifyPasswordReply(head, jsonBody: jsonBody)
        case .UserInfoResult:
            userInfoReply(jsonBody)
        case .MessageVerifyResult:
            messageVerifyReply(jsonBody)
        case .RegisterAccountReply:
            registerAccountReply(jsonBody)
        case .ImproveDataResult:
            improveDataReply(jsonBody)
        case .ObtainTripReply:
            obtainTripReply(jsonBody)
        case .ServiceDetailReply:
            serviceDetailReply(jsonBody)
        case .DeviceTokenResult:
            break
        case .DrawBillReply:
            drawBillReply(jsonBody)
        case .CenturionCardInfoReply:
            centurionCardInfoReply(jsonBody)
        case .UserCenturionCardInfoReply:
            userCenturionCardInfoReply(jsonBody)
        case .CenturionCardConsumedReply:
            centurionCardConsumedReply(jsonBody)
        case .SkillsInfoReply:
            skillsInfoReply(jsonBody)
        case .AppointmentReply:
            appointmentReply(jsonBody)
        case .InvoiceDetailReply:
            invoiceDetailReply(jsonBody)
        case .InvoiceInfoReply:
            invoiceInfoReply(jsonBody)
        case .UploadImageTokenReply:
            uploadImageTokenReply(jsonBody)
        case .WXplaceOrderReply:
            wxPlaceOrderReply(jsonBody)
        case .ClientWXPayStatusReply:
            clientWXPayStatusReply(jsonBody)
        case .ServerWXPayStatusReply:
            serverWXPayStatusReply(jsonBody)
        case .AuthenticateUserCardReply:
            authenticateUserCardReply(jsonBody)
        case .CheckAuthenticateResultReply:
            checkAuthenticateResultReply(jsonBody)
        case .CheckUserCashReply:
            checkUserCashReply(jsonBody)
        case .AppointmentRecordReply:
            appointmentRecordReply(jsonBody)
 
            
        // Opcode => 2000+
        
        case .InvitationResult:
            invitationReply(jsonBody)
        case .RecvChatMessage:
            chatMessageReply(jsonBody)
        case .ChatRecordResult:
            chatRecordReply(jsonBody)
        case .MSGReadCntResult:
            break
        case .EvaluatetripReply:
            evaluatetripReply(jsonBody)
        case .AnswerInvitationReply:
            break
        case .ServersManInfoReply:
            serversManInfoReply(jsonBody)
        case .CheckCommentDetailReplay:
            checkCommentDetailReplay(jsonBody)
        default:
            break
        }
        
        if SocketManager.completation != nil {
            var dict = JSON.init(data: body as! NSData)
            if dict.count == 0 {
                dict = ["code":"0"]
            }
            SocketManager.completation!(["data":dict.dictionaryObject!])
            SocketManager.completation = nil
        }
        
        return true
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
        if !SocketManager.isLogout {
//            connectSock()
//            performSelector(#selector(SocketManager.connectSock), withObject: nil, afterDelay: 1)
//            return
                SVProgressHUD.showWainningMessage(WainningMessage: "网络连接异常，正在尝试重新连接", ForDuration: 1.5) {
                    
                    self.performSelector(#selector(SocketManager.connectSock), withObject: nil, afterDelay: 3.5)
            }
        }
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        buffer.appendData(data)
        let headLen = SockHead.size
        while buffer.length >= headLen {
            let head = SockHead(data: buffer)
            let packageLen = Int(head.len)
            let bodyLen = Int(head.bodyLen)
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
    
    // MARK: -
    
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
    
    func logined(jsonBody: JSON?) {
        postNotification(NotifyDefine.LoginResult, object: nil, userInfo: ["data": (jsonBody!.dictionaryObject)!])
    }
    
    func servantInfoReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.ServantInfo, object: nil, userInfo: ["data": (jsonBody!.dictionaryObject)!])
    }
    
    func servantDetailInfoReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.ServantDetailInfo, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func recommonServantsReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.RecommendServants, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func servicesCityReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.ServiceCitys, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func modifyPasswordReply(head: SockHead?, jsonBody: JSON?) {
        if head!.type == Int8(0) {
            SVProgressHUD.showWainningMessage(WainningMessage: "初始密码有误", ForDuration: 1.5, completion: nil)
            XCGLogger.warning("Modify passwd failed")
        } else {
            SVProgressHUD.showSuccessMessage(SuccessMessage: "密码修改成功", ForDuration: 1.0, completion: nil)
            postNotification(NotifyDefine.ModifyPasswordSucceed, object: nil, userInfo: nil)
        }
    }
    
    func userInfoReply(jsonBody: JSON?) {
        for info in jsonBody!["userinfo_list"] {
            let user = UserInfo()
            user.setInfo(.Other, info: info.1.dictionaryObject!)
            DataManager.updateUserInfo(user)
        }
    }
    
    func messageVerifyReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.VerifyCodeInfo, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func registerAccountReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.RegisterAccountReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func improveDataReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.ImproveDataSuccessed, object: nil, userInfo: nil)
    }
    
    func obtainTripReply(jsonBody: JSON?) {
        if try! jsonBody?.rawData().length <= 0 {
            postNotification(NotifyDefine.ObtainTripReply, object: nil, userInfo: ["lastOrderID": -1001])
        } else {
            if let tripList = jsonBody!.dictionaryObject!["trip_list"] as? Array<Dictionary<String, AnyObject>> {
                var lastOrderID = 0
                for trip in tripList {
                    let hodotemerInfo = HodometerInfo(value: trip)
                    DataManager.insertHodometerInfo(hodotemerInfo)
                    lastOrderID = hodotemerInfo.order_id_
                }
                postNotification(NotifyDefine.ObtainTripReply, object: nil, userInfo: ["lastOrderID": lastOrderID])
            }
        }
    }
    
    func serviceDetailReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.ServiceDetailReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
    }
    
    func drawBillReply(jsonBody: JSON?) {
        var dict = ["invoice_status_": HodometerStatus.InvoiceMaking.rawValue]
        let oidStr = jsonBody?.dictionaryObject!["oid_str_"] as? String
        let oids = oidStr?.componentsSeparatedByString(",")
        for oid in oids! {
            if oid == "" {
                continue
            }
            dict["order_id_"] = Int.init(oid)
            DataManager.updateData(HodometerInfo.self, data: dict)
        }
        postNotification(NotifyDefine.DrawBillReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func centurionCardInfoReply(jsonBody: JSON?) {
        if let privilegeList = jsonBody?.dictionaryObject!["privilege_list"] as? Array<Dictionary<String, AnyObject>> {
            for privilege in privilegeList {
                let centurionCardServiceInfo = CenturionCardServiceInfo(value: privilege)
                DataManager.insertCenturionCardServiceInfo(centurionCardServiceInfo)
            }
        }
    }
    
    func userCenturionCardInfoReply(jsonBody: JSON?) {
        DataManager.currentUser?.setInfo(.CurrentUser, info: (jsonBody?.dictionaryObject)!)
    }
    
    func centurionCardConsumedReply(jsonBody: JSON?) {
        if jsonBody == nil {
            postNotification(NotifyDefine.CenturionCardConsumedReply, object: nil, userInfo: ["lastOrderID": -1001])
        } else {
            if let orderList = jsonBody?.dictionaryObject!["blackcard_consume_record"] as? Array<Dictionary<String, AnyObject>> {
                var lastOrderID = 0
                for order in orderList {
                    let info = CenturionCardConsumedInfo(value: order)
                    DataManager.insertCerturionCardConsumedInfo(info)
                    lastOrderID = info.order_id_
                }
                postNotification(NotifyDefine.CenturionCardConsumedReply, object: nil, userInfo: ["lastOrderID": lastOrderID])
            }
        }
    }
    
    func skillsInfoReply(jsonBody: JSON?) {
        if let skillList = jsonBody?.dictionaryObject!["skills_list"] as? Array<Dictionary<String, AnyObject>> {
            for skill in skillList {
                let info = SkillInfo(value: skill)
                let string:NSString = info.skill_name_!
                let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
                let rect = string.boundingRectWithSize(CGSizeMake(0, 24), options: options, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17)], context: nil)
                info.labelWidth = Float(rect.size.width) + 30
                DataManager.insertData(SkillInfo.self, data: info)
            }
        }
    }
    
    func appointmentReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.AppointmentReply , object: nil, userInfo: nil)
    }
    
    func invoiceDetailReply(jsonBody: JSON?) {
        if jsonBody?.dictionaryObject != nil {
            postNotification(NotifyDefine.InvoiceDetailReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
        }
    }
    
    func invoiceInfoReply(jsonBody: JSON?) {
        if try! jsonBody?.rawData().length <= 0 {
            postNotification(NotifyDefine.InvoiceInfoReply, object: nil, userInfo: ["lastOrderID": -1001])
        } else {
            if let invoiceList = jsonBody?.dictionaryObject!["invoice_list"] as? Array<Dictionary<String, AnyObject>> {
                var lastOrderID = 0
                for invoice in invoiceList {
                    let historyInfo = InvoiceHistoryInfo(value: invoice)
                    DataManager.insertInvoiceHistotyInfo(historyInfo)
                    lastOrderID = historyInfo.invoice_id_
                }
                postNotification(NotifyDefine.InvoiceInfoReply, object: nil, userInfo: ["lastOrderID": lastOrderID])
            } else {
                postNotification(NotifyDefine.InvoiceInfoReply, object: nil, userInfo: ["lastOrderID": -1001])
            }
        }
    }
    
    func uploadImageTokenReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.UpLoadImageToken, object: nil, userInfo: ["data":(jsonBody?.dictionaryObject)!])
    }
    
    func wxPlaceOrderReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.WXplaceOrderReply, object: nil, userInfo: (jsonBody?.dictionaryObject)!)
    }
    
    func clientWXPayStatusReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.WXPayStatusReply, object: nil, userInfo: (jsonBody?.dictionaryObject)!)
    }
    
    func serverWXPayStatusReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.WXPayStatusReply, object: nil, userInfo: (jsonBody?.dictionaryObject)!)
    }
    
    func authenticateUserCardReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.AuthenticateUserCard, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func checkAuthenticateResultReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.CheckAuthenticateResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func checkUserCashReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.CheckUserCashResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func appointmentRecordReply(jsonBody: JSON?) {
        var lastID = -9999
        if  let recordList = jsonBody?.dictionaryObject!["data_list"] as? Array<Dictionary<String, AnyObject>> {
            for record in recordList {
                let recordInfo = AppointmentInfo(value: record)
                DataManager.insertAppointmentRecordInfo(recordInfo)
                lastID = recordInfo.appointment_id_
            }
        }
        postNotification(NotifyDefine.AppointmentRecordReply, object: nil, userInfo: ["lastID": lastID])
    }
    
    // Opcode => 2000+
    
    func invitationReply(jsonBody: JSON?) {
        /*
         if let _ = SocketManager.getErrorCode(dict.dictionaryObject!) {
         NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.AskInvitationResult, object: nil, userInfo: dict.dictionaryObject)
         return true
         }
         */
        let order = HodometerInfo(value: (jsonBody?.dictionaryObject)!)
        if order.is_asked_ == 1 {
            postNotification(NotifyDefine.AskInvitationResult, object: nil, userInfo: ["orderInfo": order])
        } else {
            DataManager.insertHodometerInfo(order)
            if UIApplication.sharedApplication().applicationState == .Background {
                let body = "系统消息: 您有新的行程消息!"
                var userInfo:[NSObject: AnyObject] = [NSObject: AnyObject]()
                userInfo["type"] = PushMessage.MessageType.System.rawValue
                userInfo["data"] = (jsonBody?.dictionaryObject)!
                localNotify(body, userInfo: userInfo)
            } else {
                postNotification(NotifyDefine.AskInvitationResult, object: nil, userInfo: ["orderInfo": order])
            }
        }
    }
    
    func chatMessageReply(jsonBody: JSON?) {
        let msg = PushMessage(value: (jsonBody?.dictionaryObject)!)
        DataManager.insertMessage(msg)
        if UIApplication.sharedApplication().applicationState == .Background {
            if let user = DataManager.getUserInfo(msg.from_uid_) {
                let body = "\(user.nickname!): \(msg.content_!)"
                var userInfo:[NSObject: AnyObject] = [NSObject: AnyObject]()
                userInfo["type"] = PushMessage.MessageType.Chat.rawValue
                userInfo["data"] = (jsonBody?.dictionaryObject)!
                localNotify(body, userInfo: userInfo)
            }
        } else {
            postNotification(NotifyDefine.ChatMessgaeNotiy, object: nil, userInfo: ["data": msg])
        }
    }
    
    func chatRecordReply(jsonBody: JSON?) {
        
    }
    
    func evaluatetripReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.EvaluatetripReply, object: nil, userInfo: nil)
    }
    
    func serversManInfoReply(jsonBody: JSON?) {
        guard jsonBody != nil else { return }
        postNotification(NotifyDefine.ServersManInfoReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
    }
    
    func checkCommentDetailReplay(jsonBody: JSON?) {
        postNotification(NotifyDefine.CheckCommentDetailResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
}

