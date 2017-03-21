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


enum SockOpcode: Int16 {
    // 异常
    case AppError = -1
    // 心跳包
    case Heart = 1000
    // 请求登录
    case Login = 1001
    // 请求周边服务者
    case ServantBaseInfo = 1003
    // 请求服务者详情
    case ServantDetailInfo = 1005
    // 请求修改密码
    case ModifyPassword = 1011
    // 请求用户信息
    case UserInfo = 1013
    // 请求发送验证码
    case MessageVerify = 1019
    // 请求注册新用户
    case Register = 1021
    // 请求修改个人信息
    case ModifyPersonalInfo = 1023
    // 请求注册设备推送Token
    case RegisterDevice = 1031
    // 请求上传图片Token
    case UploadImageToken = 1047
    // 请求微信支付订单
    case WXPlaceOrder = 1049
    // 请求微信支付状态
    case ClientWXPayStatusRequest = 1051
    // 微信客户端支付状态返回
    case ClientWXPayStatusReply = 1052
    // 微信服务端支付状态返回
    case ServerWXPayStatusReply = 1054
    // 请求当前用户余额信息
    case UserCash = 1067
    // 请求验证密码正确性
    case PasswdVerify = 1087
    // 请求设置、修改支付密码
    case SetupPaymentCode = 1089
    // 请求照片墙
    case PhotoWall = 1109
    // 请求上传通讯录
    case UploadContact = 1111
    // 请求APP版本信息
    case VersionInfo = 1115
    // 关注状态
    case FollowStatus = 1125
    // 关注列表
    case FollowList = 1127
    // 关注数
    case FollowCount = 1129
    // 动态点赞
    case ThumbUp = 1137
    // 动态列表
    case DynamicList = 1139
    
    //MARK: - 2000+
    // 请求评价订单
    case EvaluateTrip = 2009
    // 请求评价详情
    case CommentDetail = 2015
    //支付微信号显示的信息费用
    case PayOrder = 2027
    //获取微信联系方式
    case GetRelation = 1133
    //订单消息列表
    case OrderList = 1141
    
    
}

class SocketManager: NSObject, GCDAsyncSocketDelegate {
    
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
        performSelector(#selector(sendHeart), withObject: nil, afterDelay: 15)
    }
    
    func connectSock() {
        do {
            if !socket!.isConnected {

                #if true  // true: 测试环境    false: 正式环境
                    let ip:String = "61.147.114.78"
                    let port:UInt16 = 10011
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
    
    // MARK: - GCDAsyncSocketDelegate
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        XCGLogger.info("didConnectToHost:\(host)  \(port)")
        SocketManager.isFirstReConnect = true

        sock.performBlock({() -> Void in
            sock.enableBackgroundingOnSocket()
        })
        socket?.readDataWithTimeout(-1, tag: 0)
        
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
        performSelector(#selector(sendHeart), withObject: nil, afterDelay: 15)

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
                
                let packetData = buffer.subdataWithRange(NSMakeRange(0, packageLen))
                onPacketData(packetData)
                
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

