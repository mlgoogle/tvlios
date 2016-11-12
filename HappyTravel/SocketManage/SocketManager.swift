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
        // 异常
        case AppError = -1
        // 心跳包
        case Heart = 1000
        // 请求登录
        case Login = 1001
        // 登录返回
        case Logined = 1002
        // 请求周边服务者
        case GetServantInfo = 1003
        // 周边服务者信息返回
        case ServantInfo = 1004
        // 请求服务者详情
        case GetServantDetailInfo = 1005
        // 服务者详情返回
        case ServantDetailInfo = 1006
        // 请求推荐服务者
        case GetRecommendServants = 1007
        // 推荐服务者返回
        case RecommendServants = 1008
        // 请求服务城市列表
        case GetServiceCity = 1009
        // 服务城市列表返回
        case ServiceCity = 1010
        // 请求修改密码
        case ModifyPassword = 1011
        // 修改密码返回
        case ModifyPasswordResult = 1012
        // 请求用户信息
        case GetUserInfo = 1013
        // 用户信息返回
        case UserInfoResult = 1014
        // 请求发送验证码
        case SendMessageVerify = 1019
        // 发送验证码返回
        case MessageVerifyResult = 1020
        // 请求注册新用户
        case RegisterAccountRequest = 1021
        // 注册新用户返回
        case RegisterAccountReply = 1022
        // 请求修改个人信息
        case SendImproveData = 1023
        // 修改个人信息返回
        case ImproveDataResult = 1024
        // 请求行程信息
        case ObtainTripRequest = 1025
        // 返回行程信息
        case ObtainTripReply = 1026
        // 请求服务详情信息
        case ServiceDetailRequest = 1027
        // 服务详情信息返回
        case ServiceDetailReply = 1028
        // 请求开票
        case DrawBillRequest = 1029
        // 开票返回
        case DrawBillReply = 1030
        // 请求注册设备推送Token
        case PutDeviceToken = 1031
        // 注册设备推送Token返回
        case DeviceTokenResult = 1032
        // 请求开票记录
        case InvoiceInfoRequest = 1033
        // 开票记录返回
        case InvoiceInfoReply = 1034
        // 请求黑卡会员特权信息
        case CenturionCardInfoRequest = 1035
        // 黑卡会员特权信息返回
        case CenturionCardInfoReply = 1036
        // 请求当前用户黑卡信息
        case UserCenturionCardInfoRequest = 1037
        // 当前用户黑卡信息返回
        case UserCenturionCardInfoReply = 1038
        // 请求黑卡消费记录
        case CenturionCardConsumedRequest = 1039
        // 黑卡消费记录返回
        case CenturionCardConsumedReply = 1040
        // 请求平台技能标签
        case SkillsInfoRequest = 1041
        // 平台技能标签返回
        case SkillsInfoReply = 1042
        // 请求预约
        case AppointmentRequest = 1043
        // 预约返回
        case AppointmentReply = 1044
        // 请求开票详情
        case InvoiceDetailRequest = 1045
        // 开票详情返回
        case InvoiceDetailReply = 1046
        // 请求上传图片Token
        case UploadImageToken = 1047
        // 上传图片Token返回
        case UploadImageTokenReply = 1048
        // 请求微信支付订单
        case WXPlaceOrderRequest = 1049
        // 微信支付订单返回
        case WXplaceOrderReply = 1050
        // 请求微信支付状态
        case ClientWXPayStatusRequest = 1051
        // 微信客户端支付状态返回
        case ClientWXPayStatusReply = 1052
        // 微信服务端支付状态返回
        case ServerWXPayStatusReply = 1054
        // 请求上传身份证认证
        case AuthenticateUserCard = 1055
        // 上传身份证认证返回
        case AuthenticateUserCardReply = 1056
        // 请求身份证认证进度
        case CheckAuthenticateResult = 1057
        // 身份证认证进度返回
        case CheckAuthenticateResultReply = 1058
        // 请求当前用户余额信息
        case CheckUserCash = 1067
        // 当前用户余额信息返回
        case CheckUserCashReply = 1068
        // 请求预约记录
        case AppointmentRecordRequest = 1069
        // 预约记录返回
        case AppointmentRecordReply = 1070

        
        // 请求邀请服务者
        case AskInvitation = 2001
        // 邀请服务者返回
        case InvitationResult = 2002
        // 请求发送聊天信息
        case SendChatMessage = 2003
        // 发送聊天信息返回
        case RecvChatMessage = 2004
        // 请求聊天记录
        case GetChatRecord = 2005
        // 聊天记录返回
        case ChatRecordResult = 2006
        // 请求提交读取消息数量
        case FeedbackMSGReadCnt = 2007
        // 提交读取消息数量返回
        case MSGReadCntResult = 2008
        // 请求评价订单
        case EvaluateTripRequest = 2009
        // 评价订单返回
        case EvaluatetripReply = 2010
        //
        case AnswerInvitationRequest = 2011
        //
        case AnswerInvitationReply = 2012
        // 请求联系客服
        case ServersManInfoRequest = 2013
        // 联系客服返回
        case ServersManInfoReply = 2014
        // 请求评价详情
        case CheckCommentDetail = 2015
        // 评价详情返回
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
    
    typealias recevieDataBlock = ([NSObject : AnyObject]) ->()
    
    static var completationsDic = [Int16: recevieDataBlock]()
    
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
        
        var bodyJSON:JSON?
        if data != nil {
             bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
        }
        var body:NSData?
        body = try! bodyJSON?.rawData()
        
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
        
        XCGLogger.debug(opcode)
        return true
        
    }
    
    static func sendData(opcode: SockOpcode, data: AnyObject?, result: recevieDataBlock?) {
        SocketManager.sendData(opcode, data: data)
        if result != nil {
            completationsDic[opcode.rawValue+1] = result
        }
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
        
        if jsonBody == nil {
            jsonBody = ["code" : 0]
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
        
        let blockKey = head!.opcode
        if SocketManager.completationsDic[blockKey] != nil {
            let completation = SocketManager.completationsDic[blockKey]
            completation!(["data": jsonBody!.dictionaryObject!])
            SocketManager.completationsDic.removeValueForKey(blockKey)
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
                let rect = string.boundingRectWithSize(CGSizeMake(0, 24), options: options, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(AtapteWidthValue(12))], context: nil)
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

