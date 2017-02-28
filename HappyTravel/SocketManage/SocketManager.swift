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
        // 请求注册设备推送Token
        case PutDeviceToken = 1031
        // 注册设备推送Token返回
        case DeviceTokenResult = 1032
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
        // 请求当前用户余额信息
        case CheckUserCash = 1067
        // 当前用户余额信息返回
        case CheckUserCashReply = 1068
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
        //MARK: - 2000+
        
        // 请求评价订单
        case EvaluateTripRequest = 2009
        // 评价订单返回
        case EvaluatetripReply = 2010
        // 请求评价详情
        case CheckCommentDetail = 2015
        // 评价详情返回
        case CheckCommentDetailReplay = 2016
        //请求上传通讯录
        case UploadContactRequest = 1111
        //上传通讯录结果返回
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

                #if false  // true: 测试环境    false: 正式环境
                    let ip:String = "61.147.114.78"
                    let port:UInt16 = 10007
//                    let ip:String = "192.168.8.111"
//                    let port:UInt16 = 10001
                #else
                    let ip:String = "103.40.192.101"
                    let port:UInt16 = 10002
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
        
        if opcode != .Heart {
            XCGLogger.info("Send: \(opcode)")
        }
        return true
        
    }
    
    func sendData(packet: SocketDataPacket) {
        socket?.writeData(packet.pack()!, withTimeout: 5, tag: sockTag)
        sockTag += 1
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
        } else {
            XCGLogger.debug("心跳包异常")
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
                
                if SockOpcode.init(rawValue: head.opcode) != nil {
                    let packetData = buffer.subdataWithRange(NSMakeRange(0, packageLen))
                    onPacketData(packetData)
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
    
    func decodeBase64Str(base64Str:String) throws -> String{
        //解码
        let data = NSData(base64EncodedString: base64Str, options: NSDataBase64DecodingOptions(rawValue: 0))
        let base64Decoded = String(data: data!, encoding: NSUTF8StringEncoding)
        return base64Decoded!
    }
    
}

