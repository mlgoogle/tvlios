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

    case noOrder = -1015
    case other = 0
}

class SocketManager: NSObject, GCDAsyncSocketDelegate {
    enum SockOpcode: Int16 {
        // 异常
        case appError = -1
        // 心跳包
        case heart = 1000
        // 请求登录
        case login = 1001
        // 登录返回
        case logined = 1002
        // 请求周边服务者
        case getServantInfo = 1003
        // 周边服务者信息返回
        case servantInfo = 1004
        // 请求服务者详情
        case getServantDetailInfo = 1005
        // 服务者详情返回
        case servantDetailInfo = 1006
        // 请求推荐服务者
        case getRecommendServants = 1007
        // 推荐服务者返回
        case recommendServants = 1008
        // 请求服务城市列表
        case getServiceCity = 1009
        // 服务城市列表返回
        case serviceCity = 1010
        // 请求修改密码
        case modifyPassword = 1011
        // 修改密码返回
        case modifyPasswordResult = 1012
        // 请求用户信息
        case getUserInfo = 1013
        // 用户信息返回
        case userInfoResult = 1014
        // 请求发送验证码
        case sendMessageVerify = 1019
        // 发送验证码返回
        case messageVerifyResult = 1020
        // 请求注册新用户
        case registerAccountRequest = 1021
        // 注册新用户返回
        case registerAccountReply = 1022
        // 请求修改个人信息
        case sendImproveData = 1023
        // 修改个人信息返回
        case improveDataResult = 1024
        // 请求行程信息
        case obtainTripRequest = 1025
        // 返回行程信息
        case obtainTripReply = 1026
        // 请求服务详情信息
        case serviceDetailRequest = 1027
        // 服务详情信息返回
        case serviceDetailReply = 1028
        // 请求开票
        case drawBillRequest = 1029
        // 开票返回
        case drawBillReply = 1030
        // 请求注册设备推送Token
        case putDeviceToken = 1031
        // 注册设备推送Token返回
        case deviceTokenResult = 1032
        // 请求开票记录
        case invoiceInfoRequest = 1033
        // 开票记录返回
        case invoiceInfoReply = 1034
        // 请求黑卡会员特权信息
        case centurionCardInfoRequest = 1035
        // 黑卡会员特权信息返回
        case centurionCardInfoReply = 1036
        // 请求当前用户黑卡信息
        case userCenturionCardInfoRequest = 1037
        // 当前用户黑卡信息返回
        case userCenturionCardInfoReply = 1038
        // 请求黑卡消费记录
        case centurionCardConsumedRequest = 1039
        // 黑卡消费记录返回
        case centurionCardConsumedReply = 1040
        // 请求平台技能标签
        case skillsInfoRequest = 1041
        // 平台技能标签返回
        case skillsInfoReply = 1042
        // 请求预约
        case appointmentRequest = 1043
        // 预约返回
        case appointmentReply = 1044
        // 请求开票详情
        case invoiceDetailRequest = 1045
        // 开票详情返回
        case invoiceDetailReply = 1046
        // 请求上传图片Token
        case uploadImageToken = 1047
        // 上传图片Token返回
        case uploadImageTokenReply = 1048
        // 请求微信支付订单
        case wxPlaceOrderRequest = 1049
        // 微信支付订单返回
        case wXplaceOrderReply = 1050
        // 请求微信支付状态
        case clientWXPayStatusRequest = 1051
        // 微信客户端支付状态返回
        case clientWXPayStatusReply = 1052
        // 微信服务端支付状态返回
        case serverWXPayStatusReply = 1054
        // 请求上传身份证认证
        case authenticateUserCard = 1055
        // 上传身份证认证返回
        case authenticateUserCardReply = 1056
        // 请求身份证认证进度
        case checkAuthenticateResult = 1057
        // 身份证认证进度返回
        case checkAuthenticateResultReply = 1058
        // 请求当前用户余额信息
        case checkUserCash = 1067
        // 当前用户余额信息返回
        case checkUserCashReply = 1068
        // 请求预约记录
        case appointmentRecordRequest = 1069
        // 预约记录返回
        case appointmentRecordReply = 1070
        //请求预约推荐服务者
        case appointmentRecommendRequest = 1079
        //预约推荐服务者返回
        case appointmentRecommendReply = 1080
        // 请求预约 、邀约详情
        case  appointmentDetailRequest = 1081
        // 预约详情、邀约返回
        case appointmentDetailReply = 1082
         // 请求邀请服务者
        case askInvitation = 2001
        // 邀请服务者返回
        case invitationResult = 2002
        // 请求发送聊天信息
        case sendChatMessage = 2003
        // 发送聊天信息返回
        case recvChatMessage = 2004
        // 请求聊天记录
        case getChatRecord = 2005
        // 聊天记录返回
        case chatRecordResult = 2006
        // 请求提交读取消息数量
        case feedbackMSGReadCnt = 2007
        // 提交读取消息数量返回
        case msgReadCntResult = 2008
        // 请求评价订单
        case evaluateTripRequest = 2009
        // 评价订单返回
        case evaluatetripReply = 2010
        //
        case answerInvitationRequest = 2011
        //
        case answerInvitationReply = 2012
        // 请求联系客服
        case serversManInfoRequest = 2013
        // 联系客服返回
        case serversManInfoReply = 2014
        // 请求评价详情
        case checkCommentDetail = 2015
        // 评价详情返回
        case checkCommentDetailReplay = 2016
        // 测试推送
        case testPushNotification = 2019
        case testPushNotificationReply = 2020
        
        //预约导游服务
        case appointmentServantRequest = 2021
        //预约导游服务返回
        case appointmentServantReply = 2022
        // 请求邀约、预约付款
        case payForInvitationRequest = 2017
        // 邀约、雨夜付款返回
        case payForInvitationReply = 2018

        // 获取黑卡等级升级
        case getUpCenturionCardOriderRequest = 1085
        // 获取黑卡等级下单
        case getUpCenturionCardOriderReply = 1086
        // 黑卡VIP价格
        case centurionVIPPriceRequest = 1083
        // 黑卡VIP价格
        case centurionVIPPriceReply = 1084

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
    
    typealias recevieDataBlock = ([AnyHashable: Any]) ->()
    
    static var completationsDic = [Int16: recevieDataBlock]()
    
    override init() {
        super.init()
        
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        connectSock()

    }
    
    func connectSock() {
        buffer = NSMutableData()
        do {
            if !socket!.isConnected {
                try socket?.connect(toHost: "61.147.114.78", onPort: 10001, withTimeout: 5)
            }
        } catch GCDAsyncSocketError.closedError {
            
        } catch GCDAsyncSocketError.connectTimeoutError {
            
        } catch {
            
        }
    }
    
    static func logoutCurrentAccount() {
        let sock:SocketManager? = SocketManager.shareInstance
        if sock == nil {
            return
        }
        UserDefaults.standard.removeObject(forKey: CommonDefine.UserName)
        UserDefaults.standard.removeObject(forKey: CommonDefine.Passwd)
        UserDefaults.standard.removeObject(forKey: CommonDefine.UserType)
        SocketManager.isLogout = true
        DataManager.currentUser?.login = false
        sock?.socket?.disconnect()
        SocketManager.shareInstance.buffer = NSMutableData()
        SocketManager.shareInstance.connectSock()
    }
    
    static func getErrorCode(_ dict: [String: Any]) -> SockErrCode? {
        if let err = dict["error_"] {
            return SockErrCode(rawValue: err as! Int)
        }
        return nil
    }
    
    func postNotification(_ aName: String, object anObject: AnyObject?, userInfo aUserInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: aName),
                                                                  object: anObject,
                                                                  userInfo: aUserInfo)
    }
    
    static func sendData(_ opcode: SockOpcode, data: Any?) ->Bool {
        let sock:SocketManager? = SocketManager.shareInstance
        if sock == nil {
            return false
        }
        if !sock!.socket!.isConnected {
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
        var body:Data?
        body = try! bodyJSON?.rawData()
        
        if body != nil {
            head.bodyLen = Int16(body!.count)
            head.len = Int16(SockHead.size + body!.count)
        }
        let package = (head.pack()! as NSData).mutableCopy() as! NSMutableData
        if body != nil {
            package.append(body!)
        }
        
        sock?.socket?.write(package as Data, withTimeout: 5, tag: sock!.sockTag)
        sock?.sockTag += 1
        
        XCGLogger.info("Send: \(opcode)")
        return true
        
    }
    
    static func sendData(_ opcode: SockOpcode, data: Any?, result: recevieDataBlock?) {
        _ = SocketManager.sendData(opcode, data: data)
        if result != nil {
            completationsDic[opcode.rawValue+1] = result
        }
    }
    
    func recvData(_ head: SockHead?, body:AnyObject?) ->Bool {
        if head == nil {
            return false
        }
        XCGLogger.info("Recv: \(SockOpcode.init(rawValue: head!.opcode)!)")
        
        var jsonBody:JSON?
        if body != nil && (body as! Data).count > 0 {
            jsonBody = JSON.init(data: (body as! NSData) as Data)
            guard jsonBody?.dictionaryObject != nil else {
                XCGLogger.warning("Recv: body length greater than zero, but jsonBody.dictinaryObject is nil.")
                return false
                }
            if let err = SocketManager.getErrorCode((jsonBody?.dictionaryObject)!) {
                XCGLogger.warning(err)
            }
        }
        
        if jsonBody == nil {
            jsonBody = ["code" : 0]
        }
        
        switch SockOpcode(rawValue: head!.opcode)! {
            
        case .testPushNotificationReply:

            break
        case .logined:
            logined(jsonBody)
        case .servantInfo:
            servantInfoReply(jsonBody)
        case .servantDetailInfo:
            servantDetailInfoReply(jsonBody)
        case .recommendServants:
            recommonServantsReply(jsonBody)
        case .serviceCity:
            servicesCityReply(jsonBody)
        case .modifyPasswordResult:
            modifyPasswordReply(head, jsonBody: jsonBody)
        case .userInfoResult:
            userInfoReply(jsonBody)
        case .messageVerifyResult:
            messageVerifyReply(jsonBody)
        case .registerAccountReply:
            registerAccountReply(jsonBody)
        case .improveDataResult:
            improveDataReply(jsonBody)
        case .obtainTripReply:
            obtainTripReply(jsonBody)
        case .serviceDetailReply:
            serviceDetailReply(jsonBody)
        case .deviceTokenResult:
            break
        case .drawBillReply:
            drawBillReply(jsonBody)
        case .centurionCardInfoReply:
            centurionCardInfoReply(jsonBody)
        case .userCenturionCardInfoReply:
            userCenturionCardInfoReply(jsonBody)
        case .centurionCardConsumedReply:
            centurionCardConsumedReply(jsonBody)
        case .skillsInfoReply:
            skillsInfoReply(jsonBody)
        case .appointmentReply:
            appointmentReply(jsonBody)
        case .invoiceDetailReply:
            invoiceDetailReply(jsonBody)
        case .invoiceInfoReply:
            invoiceInfoReply(jsonBody)
        case .uploadImageTokenReply:
            uploadImageTokenReply(jsonBody)
        case .wXplaceOrderReply:
            wxPlaceOrderReply(jsonBody)
        case .clientWXPayStatusReply:
            clientWXPayStatusReply(jsonBody)
        case .serverWXPayStatusReply:
            serverWXPayStatusReply(jsonBody)
        case .authenticateUserCardReply:
            authenticateUserCardReply(jsonBody)
        case .checkAuthenticateResultReply:
            checkAuthenticateResultReply(jsonBody)
        case .checkUserCashReply:
            checkUserCashReply(jsonBody)
        case .appointmentRecordReply:
            appointmentRecordReply(jsonBody)
 
        case .appointmentRecommendReply:
            
            appointmentRecommendReply(jsonBody)
            
        case .appointmentDetailReply:
            
            appointmentDetailReply(jsonBody)
            break
        // Opcode => 2000+
        
        case .invitationResult:
            invitationReply(jsonBody)
        case .recvChatMessage:
            chatMessageReply(jsonBody)
        case .chatRecordResult:
            chatRecordReply(jsonBody)
        case .msgReadCntResult:
            break
        case .evaluatetripReply:
            evaluatetripReply(jsonBody)
        case .answerInvitationReply:
            break
        case .serversManInfoReply:
            serversManInfoReply(jsonBody)
            break
        case .checkCommentDetailReplay:
            checkCommentDetailReplay(jsonBody)
            break
        case .appointmentServantReply:
            appointmentServantReply(jsonBody)
            break
        case .payForInvitationReply:
            payForInvitationReply(jsonBody)
            break
        case .centurionVIPPriceReply:
            saveTheCenturionCardVIPPrice(jsonBody)
            break
        default:
            break
        }
        
        let blockKey = head!.opcode
        if SocketManager.completationsDic[blockKey] != nil {
            let completation = SocketManager.completationsDic[blockKey]
            completation!(["data": jsonBody!.dictionaryObject!])
            SocketManager.completationsDic.removeValue(forKey: blockKey)
        }
        
        
        return true
    }
    
    // MARK: - GCDAsyncSocketDelegate
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        XCGLogger.info("didConnectToHost:\(host)  \(port)")
        
        sock.perform({() -> Void in
            sock.enableBackgroundingOnSocket()
        })
        socket?.readData(withTimeout: -1, tag: 0)
        
        let username = UserDefaults.standard.object(forKey: CommonDefine.UserName) as? String
        let passwd = UserDefaults.standard.object(forKey: CommonDefine.Passwd) as? String
        var userType:Int?
        if let type = UserDefaults.standard.object(forKey: CommonDefine.UserType) as? String {
            userType = Int.init(type)
        }
        
        if username != nil && passwd != nil && userType != nil && SocketManager.isLogout == false {
            let dict = ["phone_num_": username!, "passwd_": passwd!, "user_type_": userType!] as [String : Any]
            _ = SocketManager.sendData(.login, data: dict as AnyObject?)
        }
        SocketManager.isLogout = false
        
//        performSelector(#selector(SocketManager.sendHeart), withObject: nil, afterDelay: 10)
    }
    
    func sendHeart() {
        _ = SocketManager.sendData(.heart, data: nil)
        perform(#selector(SocketManager.sendHeart), with: nil, afterDelay: 10)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        XCGLogger.warning("socketDidDisconnect:\(err)")
        if !SocketManager.isLogout {
//            connectSock()
//            performSelector(#selector(SocketManager.connectSock), withObject: nil, afterDelay: 1)
//            return
                SVProgressHUD.showWainningMessage(WainningMessage: "网络连接异常，正在尝试重新连接", ForDuration: 1.5) {
                    
                    self.perform(#selector(SocketManager.connectSock), with: nil, afterDelay: 3.5)
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        buffer.append(data)
        let headLen = SockHead.size
        while buffer.length >= headLen {
            let head = SockHead(data: buffer as Data)
            let packageLen = Int(head.len)
            if buffer.length >= packageLen {
                let bodyLen = Int(head.bodyLen)
                let bodyData = buffer.subdata(with: NSMakeRange(headLen, bodyLen))
                buffer.setData(buffer.subdata(with: NSMakeRange(packageLen, buffer.length - packageLen)))
                _ = recvData(head, body: bodyData as AnyObject?)
            } else {
                break
            }
            
        }
        socket?.readData(withTimeout: -1, tag: tag)
    
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 0
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 0
    }
    
    deinit {
        socket?.disconnect()
    }
    
    // MARK: -
    
    func localNotify(_ body: String?, userInfo: [AnyHashable: Any]?) {
        let localNotify = UILocalNotification()
        localNotify.fireDate = Date().addingTimeInterval(0.1)
        localNotify.timeZone = TimeZone.current
        localNotify.applicationIconBadgeNumber = DataManager.getUnreadMsgCnt(-1)
        localNotify.soundName = UILocalNotificationDefaultSoundName
        if #available(iOS 8.2, *) {
            localNotify.alertTitle = "V领队"
        } else {
            // Fallback on earlier versions
        }
        localNotify.alertBody = body!
        localNotify.userInfo = userInfo
        UIApplication.shared.scheduleLocalNotification(localNotify)
        
    }
    
    func logined(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.LoginResult, object: nil, userInfo: ["data": (jsonBody!.dictionaryObject)!])
    }
    
    func servantInfoReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.ServantInfo, object: nil, userInfo: ["data": (jsonBody!.dictionaryObject)!])
    }
    
    func servantDetailInfoReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.ServantDetailInfo, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func recommonServantsReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.RecommendServants, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func servicesCityReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.ServiceCitys, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func modifyPasswordReply(_ head: SockHead?, jsonBody: JSON?) {
        if head!.type == Int8(0) {
            SVProgressHUD.showWainningMessage(WainningMessage: "初始密码有误", ForDuration: 1.5, completion: nil)
            XCGLogger.warning("Modify passwd failed")
        } else {
            SVProgressHUD.showSuccessMessage(SuccessMessage: "密码修改成功", ForDuration: 1.0, completion: nil)
            postNotification(NotifyDefine.ModifyPasswordSucceed, object: nil, userInfo: nil)
        }
    }
    
    func userInfoReply(_ jsonBody: JSON?) {
        for info in jsonBody!["userinfo_list_"] {
            let user = UserInfo()
            user.setInfo(.other, info: info.1.dictionaryObject! as Dictionary<String, AnyObject>?)
            DataManager.updateUserInfo(user)
        }
        postNotification(NotifyDefine.UserBaseInfoReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])

    }
    
    func messageVerifyReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.VerifyCodeInfo, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func registerAccountReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.RegisterAccountReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func improveDataReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.ImproveDataSuccessed, object: nil, userInfo: nil)
    }
    
    func obtainTripReply(_ jsonBody: JSON?) {
        if try! (jsonBody?.rawData().count)! <= 0 {
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
    
    func serviceDetailReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.ServiceDetailReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
    }
    
    func drawBillReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.DrawBillReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func centurionCardInfoReply(_ jsonBody: JSON?) {
        if let privilegeList = jsonBody?.dictionaryObject!["privilege_list_"] as? Array<Dictionary<String, AnyObject>> {
            for privilege in privilegeList {
                let centurionCardServiceInfo = CenturionCardServiceInfo(value: privilege)
                DataManager.insertCenturionCardServiceInfo(centurionCardServiceInfo)
            }
        }
    }
    
    func userCenturionCardInfoReply(_ jsonBody: JSON?) {
        DataManager.currentUser?.setInfo(.currentUser, info: (jsonBody?.dictionaryObject)! as Dictionary<String, AnyObject>?)
    }
    
    func centurionCardConsumedReply(_ jsonBody: JSON?) {
        if jsonBody == nil {
            postNotification(NotifyDefine.CenturionCardConsumedReply, object: nil, userInfo: ["lastOrderID": -1001])
        } else {
            if let orderList = jsonBody?.dictionaryObject!["blackcard_consume_record_"] as? Array<Dictionary<String, AnyObject>> {
                var lastOrderID = 0
                for order in orderList {
                    let info = CenturionCardConsumedInfo(value: order)
                    DataManager.insertCerturionCardConsumedInfo(info)
                    lastOrderID = info.order_id_
                }
                postNotification(NotifyDefine.CenturionCardConsumedReply, object: nil, userInfo: ["lastOrderID": lastOrderID])
            } else {
                postNotification(NotifyDefine.CenturionCardConsumedReply, object: nil, userInfo: ["lastOrderID": -1001])

            }
        }
    }
    
    func skillsInfoReply(_ jsonBody: JSON?) {
        if let skillList = jsonBody?.dictionaryObject!["skills_list_"] as? Array<Dictionary<String, AnyObject>> {
            for skill in skillList {
               
                let info = SkillInfo(value: skill)
                let string:NSString = info.skill_name_! as NSString
                let options:NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
                let rect = string.boundingRect(with:  CGSize(width: 0, height: 24), options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: AtapteWidthValue(12))], context: nil)
                info.labelWidth = Float(rect.size.width) + 30
                DataManager.insertData(SkillInfo.self, data: info)
            }
        }
    }
    
    func appointmentReply(_ jsonBody: JSON?) {
        guard let appointment_id_ = jsonBody?.dictionaryObject!["appointment_id_"] else {return}
        postNotification(NotifyDefine.AppointmentReply , object: nil, userInfo: ["appointment_id_":appointment_id_])
    }
    
    func invoiceDetailReply(_ jsonBody: JSON?) {
        if jsonBody?.dictionaryObject != nil {
            postNotification(NotifyDefine.InvoiceDetailReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
        }
    }
    
    func invoiceInfoReply(_ jsonBody: JSON?) {
        if try! (jsonBody?.rawData().count)! <= 0 {
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
    
    func uploadImageTokenReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.UpLoadImageToken, object: nil, userInfo: ["data":(jsonBody?.dictionaryObject)!])
    }
    
    func wxPlaceOrderReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.WXplaceOrderReply, object: nil, userInfo: (jsonBody?.dictionaryObject)!)
    }
    
    func clientWXPayStatusReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.WXPayStatusReply, object: nil, userInfo: (jsonBody?.dictionaryObject)!)
    }
    
    func serverWXPayStatusReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.WXPayStatusReply, object: nil, userInfo: (jsonBody?.dictionaryObject)!)
    }
    
    func authenticateUserCardReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.AuthenticateUserCard, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func checkAuthenticateResultReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.CheckAuthenticateResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func checkUserCashReply(_ jsonBody: JSON?) {
        if let cash = jsonBody?.dictionaryObject!["user_cash_"] as? Int {
            DataManager.currentUser!.cash = cash
        }
        postNotification(NotifyDefine.CheckUserCashResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func appointmentRecordReply(_ jsonBody: JSON?) {
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
    func appointmentRecommendReply(_ jsonBody:JSON?) {
        postNotification(NotifyDefine.AppointmentRecommendReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    func appointmentDetailReply(_ jsonBody:JSON?) {
        postNotification(NotifyDefine.AppointmentDetailReply, object: nil, userInfo: ["data":(jsonBody?.dictionaryObject)!])
    }
    
    // Opcode => 2000+
    
    func invitationReply(_ jsonBody: JSON?) {
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
            if UIApplication.shared.applicationState == .background {
                let body = "系统消息: 您有新的行程消息!"
                var userInfo:[AnyHashable: Any] = [AnyHashable: Any]()
                userInfo["type"] = PushMessage.MessageType.system.rawValue
                userInfo["data"] = (jsonBody?.dictionaryObject)!
                localNotify(body, userInfo: userInfo)
            } else {
                postNotification(NotifyDefine.AskInvitationResult, object: nil, userInfo: ["orderInfo": order])
            }
        }
    }
    
    func chatMessageReply(_ jsonBody: JSON?) {
        let msg = PushMessage(value: (jsonBody?.dictionaryObject)!)
        DataManager.insertMessage(msg)
        if UIApplication.shared.applicationState == .background {
            if let user = DataManager.getUserInfo(msg.from_uid_) {
                let body = "\(user.nickname!): \(msg.content_!)"
                var userInfo:[AnyHashable: Any] = [AnyHashable: Any]()
                userInfo["type"] = PushMessage.MessageType.chat.rawValue
                userInfo["data"] = (jsonBody?.dictionaryObject)!
                localNotify(body, userInfo: userInfo)
            }
        } else {
            postNotification(NotifyDefine.ChatMessgaeNotiy, object: nil, userInfo: ["data": msg])
        }
    }
    
    func chatRecordReply(_ jsonBody: JSON?) {
        
    }
    
    func evaluatetripReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.EvaluatetripReply, object: nil, userInfo: nil)
    }
    
    func serversManInfoReply(_ jsonBody: JSON?) {
        guard jsonBody != nil else { return }
        postNotification(NotifyDefine.ServersManInfoReply, object: nil, userInfo: ["data" : (jsonBody?.dictionaryObject)!])
    }
    
    func checkCommentDetailReplay(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.CheckCommentDetailResult, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    func appointmentServantReply(_ jsonBody:JSON?) {
       
     postNotification(NotifyDefine.AppointmentServantReply, object: nil, userInfo: ["data": (jsonBody?.dictionaryObject)!])
    }
    
    func payForInvitationReply(_ jsonBody: JSON?) {
        postNotification(NotifyDefine.PayForInvitationReply, object: nil, userInfo: jsonBody?.dictionaryObject)
    }
    
    func saveTheCenturionCardVIPPrice(_ jsonBody:JSON?) {
        if let dataList = jsonBody?.dictionaryObject!["data_list_"] as? Array<Dictionary<String, AnyObject>>{
            for data in dataList {
                let price = CentuionCardPriceInfo(value: data)
                DataManager.insertCenturionCardVIPPriceInfo(price)
            }
        }
    }
}

