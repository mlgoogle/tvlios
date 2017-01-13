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
import RealmSwift


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
        //请求预约推荐服务者
        case AppointmentRecommendRequest = 1079
        //预约推荐服务者返回
        case AppointmentRecommendReply = 1080
        // 请求预约 、邀约详情
        case AppointmentDetailRequest = 1081
        // 预约详情、邀约返回
        case AppointmentDetailReply = 1082
        // 黑卡VIP价格
        case CenturionVIPPriceRequest = 1083
        // 黑卡VIP价格
        case CenturionVIPPriceReply = 1084
        // 获取黑卡等级升级
        case GetUpCenturionCardOriderRequest = 1085
        // 获取黑卡等级下单
        case GetUpCenturionCardOriderReply = 1086
        // 请求验证密码正确性
        case PasswdVerifyRequest = 1087
        // 验证密码正确性返回
        case PasswdVerifyReply = 1088
        // 请求设置、修改支付密码
        case SetupPaymentCodeRequest = 1089
        // 设置、修改支付密码返回
        case SetupPaymentCodeReply = 1090
        // 请求照片墙
        case PhotoWallRequest = 1109
        // 照片墙返回
        case PhotoWallReply = 1110
        // 请求APP版本信息
        case VersionInfoRequest = 1115
        // APP版本信息返回
        case VersionInfoReply = 1116
        //保险金额请求
        case InsuranceRequest = 1117
        //保险金额返回
        case InsuranceReply = 1118
        //保险支付
        case InsurancePayRequest = 1119
        //保险支付返回
        case InsurancePayReply = 1120
        //请求身份证认证
        case IDVerifyRequest = 1121
        //身份证认证返回
        case IDVerifyReply = 1122
        //MARK: - 2000+
        
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
        // 收到服务者回复
        case AnswerInvitationReply = 2012
        // 请求联系客服
        case ServersManInfoRequest = 2013
        // 联系客服返回
        case ServersManInfoReply = 2014
        // 请求评价详情
        case CheckCommentDetail = 2015
        // 评价详情返回
        case CheckCommentDetailReplay = 2016
        // 测试推送
        case TestPushNotification = 2019
        case TestPushNotificationReply = 2020
        
        // 预约导游服务
        case AppointmentServantRequest = 2021
        // 预约导游服务返回
        case AppointmentServantReply = 2022
        // 请求邀约、预约付款
        case PayForInvitationRequest = 2017
        // 邀约、预约付款返回
        case PayForInvitationReply = 2018
        // 请求未读消息
        case UnreadMessageRequest = 2025
        // 未读消息返回
        case UnreadMessageReply = 2026
        
        case UploadContactRequest = 1111
        case UploadContactReply = 1112

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
    
    static var isFirstReConnect = true
    
    static var isLogout = false
    
    typealias recevieDataBlock = ([NSObject : AnyObject]) ->()
    
    static var completationsDic = [Int16: recevieDataBlock]()
    
    let tmpNewRequestType:[SockOpcode] = [.Logined,  // Done
                                          .ServiceCity,  // Done
                                          .InsuranceReply,
                                          .InsurancePayReply,
                                          .CenturionCardInfoReply,  // Suspend
                                          .CenturionVIPPriceReply,  // Suspend
                                          .UserCenturionCardInfoReply,  // Suspend
                                          .UploadContactReply,
                                          .ObtainTripReply,
                                          .AppointmentRecordReply,
                                          
                                          .CenturionCardConsumedReply,  // Suspend
                                          .AppointmentRecommendReply,
                                          .SkillsInfoReply,  // Done
                                          .ServantInfo,  // Done
                                          .CheckAuthenticateResultReply,
                                          .UserInfoResult,  // Done
                                          .CheckUserCashReply,
                                          .ModifyPasswordResult,
                                          .RegisterAccountReply,
                                          .ServantDetailInfo,  // Done
                                          
                                          .SendMessageVerify,
                                          .DrawBillReply,
                                          .InvoiceInfoReply,
                                          .InvoiceDetailReply,
                                          .AppointmentReply,
                                          .SendImproveData,
                                          .AppointmentDetailReply,
                                          .CheckCommentDetailReplay,
                                          .EvaluatetripReply,
                                          .MessageVerifyResult,
                                          .ImproveDataResult,
                                          .ServiceDetailReply,
                                          
                                          .DeviceTokenResult,
                                          .UploadImageTokenReply,
                                          .AuthenticateUserCardReply,
                                          .WXplaceOrderReply,
                                          .RecvChatMessage,
                                          .PasswdVerifyReply,
                                          .SetupPaymentCodeReply,
                                          .UnreadMessageReply,
                                          .InvitationResult,
                                          .MSGReadCntResult,
                                          .PayForInvitationReply,
                                          .PhotoWallReply,
                                          .InvitationResult,
                                          .AppointmentServantReply,
                                          .VersionInfoReply,
                                          .ServersManInfoReply,
                                          .ServersManInfoReply, //.RecommendServants,
                                          .GetUpCenturionCardOriderReply,
                                          .ClientWXPayStatusReply,
                                          .ServerWXPayStatusReply,
                                          .IDVerifyReply]
    
    var isConnected : Bool {
        return socket!.isConnected
    }
    
    override init() {
        super.init()
        
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: dispatch_get_main_queue())
        connectSock()
    }
    
    func connectSock() {
        do {
            if !socket!.isConnected {
                #if true  // true: 测试环境    false: 正式环境
                    let ip:String = "61.147.114.78"
                    let port:UInt16 = 10007
//                    let ip:String = "192.168.8.111"
//                    let port:UInt16 = 10001
                #else
                    let ip:String = "103.40.192.101"
                    let port:UInt16 = 10001
                #endif
                buffer = NSMutableData()
                try socket?.connectToHost(ip, onPort: port, withTimeout: 5)
            }
        } catch GCDAsyncSocketError.ClosedError {
            
        } catch GCDAsyncSocketError.ConnectTimeoutError {
            
        } catch {
            
        }
    }
    
    func disconnect() {
        socket?.delegate = nil
        socket?.disconnect()
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
        CurrentUser.login_ = false
        CurrentUser.auth_status_ = -1
//        UserCenturionCardInfo.name_ = nil
//        UserCenturionCardInfo.blackcard_id_ = 0
//        UserCenturionCardInfo.blackcard_lv_ = 0
        
        sock?.socket?.disconnect()
        SocketManager.shareInstance.buffer = NSMutableData()
        SocketManager.shareInstance.connectSock()
    }
    
    static func getError(dict: [String: AnyObject]) -> [Int: String]? {
        if let err = dict["error_"] as? Int {
            return [err: CommonDefine.errorMsgs[err] ?? "错误码: \(err)"]
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
            SocketManager.showDisConnectErrorInfo()
            sock!.connectSock()
            return true
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
        
        XCGLogger.info("Send: \(opcode)")
        return true
        
    }
    
    static func sendData(opcode: SockOpcode, data: AnyObject?, result: recevieDataBlock?) {
        SocketManager.sendData(opcode, data: data)
        if result != nil {
            completationsDic[opcode.rawValue+1] = result
        }
    }
    
    func sendData(packet: SocketDataPacket) {
        socket?.writeData(packet.pack()!, withTimeout: 5, tag: sockTag)
        sockTag += 1
    }
    
    func recvData(head: SockHead?, body:AnyObject?) ->Bool {
        if head == nil {
            return false
        }
        
        if let op = SocketManager.SockOpcode.init(rawValue: head!.opcode) {
            XCGLogger.info("Recv: \(op)")
        } else {
            XCGLogger.info("Recv opcode: \(head!.opcode)")
            return  true
        }
        
        var jsonBody:JSON?
        if body != nil && (body as! NSData).length > 0 {
            jsonBody = JSON.init(data: body as! NSData)
            guard jsonBody?.dictionaryObject != nil else {
                XCGLogger.warning("Recv: body length greater than zero, but jsonBody.dictinaryObject is nil.")
                return false
                }
            if let err = SocketManager.getError((jsonBody?.dictionaryObject)!) {
                if !sockErrorHandling(SockOpcode(rawValue: head!.opcode)!, err: err) {
                    return true
                }
            }
        }
        
        if jsonBody == nil {
            jsonBody = ["code" : 0]
        }
        
        switch SockOpcode(rawValue: head!.opcode)! {
        
        case .RecommendServants:
            recommonServantsReply(jsonBody)
            
        case .ModifyPasswordResult:
            modifyPasswordReply(head, jsonBody: jsonBody)
            
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
 
        case .AppointmentRecommendReply:
            appointmentRecommendReply(jsonBody)
            
        case .AppointmentDetailReply:
            appointmentDetailReply(jsonBody)
            
        case .PasswdVerifyReply:
            passwdVerifyReply(jsonBody)
            
        case .SetupPaymentCodeReply:
            setupPaymentCodeReply(jsonBody)
            
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
            answerInvitationReply(jsonBody)

        case .ServersManInfoReply:
            serversManInfoReply(jsonBody)
            
        case .CheckCommentDetailReplay:
            checkCommentDetailReplay(jsonBody)

        case .AppointmentServantReply:
            appointmentServantReply(jsonBody)

        case .PayForInvitationReply:
            payForInvitationReply(jsonBody)

        case .UnreadMessageReply:
            unreadMessageReply(jsonBody)
        
        case .InsuranceReply:
            sureInsuranceReply(jsonBody)
            
            
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
    
    func sockErrorHandling(opcode: SockOpcode, err: [Int: String]) -> Bool {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        switch opcode {
        case .PasswdVerifyReply:
            notificationCenter.postNotificationName(NotifyDefine.PasswdVerifyReplyError, object: nil, userInfo: ["err": err])
            return false
            
        case .SetupPaymentCodeReply:
            notificationCenter.postNotificationName(NotifyDefine.SetupPaymentCodeReplyError, object: nil, userInfo: ["err": err])
            return false
            
        default:
            break
        }
        XCGLogger.warning(err)
        return true
    }
    
    // MARK: - GCDAsyncSocketDelegate
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        XCGLogger.info("didConnectToHost:\(host)  \(port)")
        SocketManager.isFirstReConnect = true

        sock.performBlock({() -> Void in
            sock.enableBackgroundingOnSocket()
        })
        socket?.readDataWithTimeout(-1, tag: 0)
        
        if sockTag == 0 {
            performSelector(#selector(SocketManager.sendHeart), withObject: nil, afterDelay: 15)
        }
        
        if APIHelper.userAPI().autoLogin() {
            let loginModel = LoginModel()
            APIHelper.userAPI().login(loginModel, complete: { (response) in
                if let user = response as? UserInfoModel {
                    CurrentUser = user
                    CurrentUser.login_ = true
                    NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginSuccessed, object: nil, userInfo: nil)
                    return
                }
                XCGLogger.debug(response)
            }, error: { (err) in
                NSUserDefaults.standardUserDefaults().removeObjectForKey(CommonDefine.Passwd)
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginFailed, object: nil, userInfo: nil)
                XCGLogger.debug(err)
            })
        }
        SocketManager.isLogout = false

    }
    
    func sendHeart() {
        if (CurrentUser.uid_ > -1) && (socket?.isConnected)!{
            SocketManager.sendData(.Heart, data: ["uid_": CurrentUser.uid_])
        }
        performSelector(#selector(SocketManager.sendHeart), withObject: nil, afterDelay: 15)

    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        if err != nil {
            XCGLogger.warning("socketDidDisconnect:\(err!)")
        }
        if !SocketManager.isLogout && SocketManager.isFirstReConnect {
            SocketManager.isFirstReConnect = false
            SocketManager.showDisConnectErrorInfo()
        }
        self.performSelector(#selector(SocketManager.connectSock), withObject: nil, afterDelay: 5.0)

    }
    
    static func showDisConnectErrorInfo() {
        SVProgressHUD.showWainningMessage(WainningMessage: "正在重新连接", ForDuration: 1.5) {
        }
    }
    
    func onPacketData(data: NSData) {
        let packet: SocketDataPacket = SocketDataPacket(data: data)
        SocketRequestManage.shared.notifyResponsePacket(packet)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        buffer.appendData(data)
        let headLen = SockHead.size
        while buffer.length >= headLen {
            let head = SockHead(data: buffer)
            let packageLen = Int(head.len)
            if buffer.length >= packageLen {
                let bodyLen = Int(head.bodyLen)
                if bodyLen != packageLen - SockHead.size {
                    socket?.disconnect()
                    return
                }
                
                if tmpNewRequestType.contains(SockOpcode.init(rawValue: head.opcode)!) {
                    let packetData = buffer.subdataWithRange(NSMakeRange(0, packageLen))
                    onPacketData(packetData)
                } else {
                    let bodyData = buffer.subdataWithRange(NSMakeRange(headLen, bodyLen))
                    recvData(head, body: bodyData)
                }
                buffer.setData(buffer.subdataWithRange(NSMakeRange(packageLen, buffer.length - packageLen)))
            } else {
                break
            }
            
        }
        socket?.readDataWithTimeout(-1, tag: tag)
    
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
            localNotify.alertTitle = "优悦出行"
        } else {
            // Fallback on earlier versions
        }
        localNotify.alertBody = body!
        localNotify.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(localNotify)
        
    }
    
    func recommonServantsReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.RecommendServants, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
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
            if let tripList = jsonBody!.dictionaryObject!["trip_list_"] as? Array<Dictionary<String, AnyObject>> {
                var lastOrderID = 0
                for trip in tripList {
                    let hodotemerInfo = HodometerInfo(value: trip)
                    DataManager.insertHodometerInfo(hodotemerInfo)
                    lastOrderID = hodotemerInfo.order_id_
                }
                postNotification(NotifyDefine.ObtainTripReply, object: nil, userInfo: ["lastOrderID": lastOrderID])
            } else {
                postNotification(NotifyDefine.ObtainTripReply, object: nil, userInfo: ["lastOrderID": -1001])
            }
        }
    }
    
    func serviceDetailReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.ServiceDetailReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
    }
    
    func drawBillReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.DrawBillReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func appointmentReply(jsonBody: JSON?) {
        guard let appointment_id_ = jsonBody?.dictionaryObject!["appointment_id_"] else {return}
        postNotification(NotifyDefine.AppointmentReply , object: nil, userInfo: ["appointment_id_":appointment_id_])
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
            if let invoiceList = jsonBody?.dictionaryObject!["invoice_list_"] as? Array<Dictionary<String, AnyObject>> {
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
        if let data = jsonBody?.dictionaryObject {
//            if let reason = data["failed_reason_"] as? String {
//                if reason == "" {
                    if let reviewStatus = data["review_status_"] as? Int {
                        DataManager.currentUser?.authentication = reviewStatus
                    }
//                }
//            }
        }
        postNotification(NotifyDefine.CheckAuthenticateResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func checkUserCashReply(jsonBody: JSON?) {
        if let cash = jsonBody?.dictionaryObject!["user_cash_"] as? Int {
            DataManager.currentUser?.cash = cash
        }
        if let hasPasswd = jsonBody?.dictionaryObject!["has_passwd_"] as? Int {
            DataManager.currentUser?.has_passwd_ = hasPasswd
        }
        postNotification(NotifyDefine.CheckUserCashResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func appointmentRecordReply(jsonBody: JSON?) {
        var lastID = -9999
        if  let recordList = jsonBody?.dictionaryObject!["data_list_"] as? Array<Dictionary<String, AnyObject>> {
            for record in recordList {
                let recordInfo = AppointmentInfo(value: record)
                DataManager.insertAppointmentRecordInfo(recordInfo)
                lastID = recordInfo.appointment_id_
            }
        }
        postNotification(NotifyDefine.AppointmentRecordReply, object: nil, userInfo: ["lastID": lastID])
    }
    
    func appointmentRecommendReply(jsonBody:JSON?) {
        postNotification(NotifyDefine.AppointmentRecommendReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func appointmentDetailReply(jsonBody:JSON?) {
        postNotification(NotifyDefine.AppointmentDetailReply, object: nil, userInfo: ["data":(jsonBody?.dictionaryObject)!])
    }
    
    func passwdVerifyReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.PasswdVerifyReply, object: nil, userInfo: nil)
    }
    
    func setupPaymentCodeReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.SetupPaymentCodeReply, object: nil, userInfo: nil)
    }
    
    // Opcode => 2000+
    
    func invitationReply(jsonBody: JSON?) {
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
        //接收聊天信息
        if ((jsonBody?.dictionaryObject?.indexForKey("code")) != nil) {
            return
        }
        
        let msg = MessageModel(value: (jsonBody?.dictionaryObject)!)
        
        //base64解码
        DataManager.insertData(msg)
        let user = DataManager.getData(UserInfoModel.self)?.filter("uid_ = \(msg.from_uid_)").first
        if user == nil {
            let req = UserInfoIDStrRequestModel()
            req.uid_str_ = "\(msg.from_uid_)"
            APIHelper.servantAPI().getUserInfoByString(req, complete: { (response) in
                if let users = response as? [UserInfoModel] {
                    DataManager.insertData(users[0])
                }
            }, error: nil)
        }
        if UIApplication.sharedApplication().applicationState == .Background {

            let body = "\((user?.nickname_ ?? "云巅代号 \(msg.from_uid_) 的用户给您发来消息")): \(msg.content_!)"
            var userInfo:[NSObject: AnyObject] = [NSObject: AnyObject]()
            userInfo["type"] = msg.msg_type_
            userInfo["data"] = (jsonBody?.dictionaryObject)!
            localNotify(body, userInfo: userInfo)
        } else {
            postNotification(NotifyDefine.ChatMessgaeNotiy, object: nil, userInfo: ["data": msg])
        }
    }
    
    func chatRecordReply(jsonBody: JSON?) {
        
    }
    
    func evaluatetripReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.EvaluatetripReply, object: nil, userInfo: nil)
    }
    
    func answerInvitationReply(jsonBody:JSON?) {
        DataManager.modfyStatusWithDictonary((jsonBody?.dictionaryObject)!)
    }
    
    func serversManInfoReply(jsonBody: JSON?) {
        guard jsonBody != nil else { return }
        postNotification(NotifyDefine.ServersManInfoReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
    }
    
    func checkCommentDetailReplay(jsonBody: JSON?) {
        postNotification(NotifyDefine.CheckCommentDetailResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func appointmentServantReply(jsonBody:JSON?) {
        postNotification(NotifyDefine.AppointmentServantReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func payForInvitationReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.PayForInvitationReply, object: nil, userInfo: jsonBody?.dictionaryObject)
    }
    
    func unreadMessageReply(jsonBody: JSON?) {
        if let msgList = jsonBody?.dictionaryObject!["msg_list_"] as? Array<Dictionary<String, AnyObject>> {
            if msgList.count > 0 {
                var pMsg:MessageModel?
                
                for msg in msgList.reverse() {
                    let pushMsg = MessageModel(value: msg)
                    //base64解码
//                    pushMsg.content_ = try! decodeBase64Str(pushMsg.content_!)
//                    DataManager.insertMessage(pushMsg)
                    DataManager.insertData(pushMsg)
                    pMsg = pushMsg
                }
                let user = DataManager.getUserInfo(pMsg!.from_uid_)
                if user == nil {
                    let req = UserInfoIDStrRequestModel()
                    req.uid_str_ = "\(pMsg!.from_uid_)"
                    APIHelper.servantAPI().getUserInfoByString(req, complete: { (response) in
                        if let users = response as? [UserInfoModel] {
                            DataManager.insertData(users[0])
                        }
                    }, error: nil)
                }
                postNotification(NotifyDefine.ChatMessgaeNotiy, object: nil, userInfo: ["data": pMsg!])
            }
        }
    }
    
    func decodeBase64Str(base64Str:String) throws -> String{
        //解码
        let data = NSData(base64EncodedString: base64Str, options: NSDataBase64DecodingOptions(rawValue: 0))
        let base64Decoded = String(data: data!, encoding: NSUTF8StringEncoding)
        return base64Decoded!
    }
    
    func sureInsuranceReply(jsonBody: JSON?) {
        postNotification(NotifyDefine.SureInsuranceReply, object: nil, userInfo: jsonBody?.dictionaryObject)
    }
}



