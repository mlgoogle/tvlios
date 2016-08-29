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
        
        case AskInvitation = 2001
        case InvitationResult = 2002
        case SendChatMessage = 2003
        case RecvChatMessage = 2004
        
    }
    
    class var shareInstance : SocketManager {
        struct Static {
            static let instance:SocketManager = SocketManager()
        }
        return Static.instance
    }
    
    var socket:GCDAsyncSocket?
    
    var buffer:NSMutableData = NSMutableData()
 
    override init() {
        super.init()
        
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: dispatch_get_main_queue())
        connectSock()
        
    }
    
    func connectSock() {
        buffer = NSMutableData()
        do {
            //            try socket?.connectToHost("116.226.227.85", onPort: 10001, withTimeout: 5)
            try socket?.connectToHost("192.168.2.67", onPort: 10001, withTimeout: 5)
        } catch GCDAsyncSocketError.ClosedError {
            
        } catch GCDAsyncSocketError.ConnectTimeoutError {
            
        } catch {
            
        }
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
            if UserInfo.currentUser.uid == nil {
                return false
            }
            head.fields["opcode"] = 1000
            let dict:Dictionary<String, AnyObject> = ["uid_": UserInfo.currentUser.uid!]
            bodyJSON = JSON.init(dict)
            XCGLogger.debug("Heart")
            break
        case .Login:
            head.fields["opcode"] = 1001
            bodyJSON = JSON.init(data as! Dictionary<String, AnyObject>)
            break
        case .GetServantInfo:
            head.fields["opcode"] = 1003
            let dict:Dictionary<String, AnyObject> = ["latitude_": UserInfo.currentUser.gpsLocation.latitude,
                                                      "longitude_": UserInfo.currentUser.gpsLocation.longitude,
                                                      "distance_": 20.1]
            bodyJSON = JSON.init(dict)
            break
        case .GetServantDetailInfo:
            head.fields["opcode"] = 1005
            let info = data as! UserInfo
            let dict:Dictionary<String, AnyObject> = ["uid_": info.uid!]
            bodyJSON = JSON.init(dict)
            break
        case .GetRecommendServants:
            head.fields["opcode"] = 1007
            let dict:Dictionary<String, AnyObject> = ["city_code_": data as! Int]
            bodyJSON = JSON.init(dict)
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
//        XCGLogger.debug(String.init(data: body as! NSData, encoding: NSUTF8StringEncoding))
        let opcode = (head!.fields["opcode"]! as! NSNumber).integerValue
        switch SockOpcode(rawValue: opcode)! {
        case .Logined:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug(dict.rawString())
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginResult, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ServantInfo:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug(dict.rawString())
            if dict.count == 0 {
                return false
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ServantInfo, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ServantDetailInfo:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug(dict.rawString())
            if dict.count == 0 {
                return false
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ServantDetailInfo, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .RecommendServants:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug("\(dict)")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.RecommendServants, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ServiceCity:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug("\(dict)")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ServiceCitys, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        case .ModifyPasswordResult:
            if (head!.fields["type"] as! NSNumber).integerValue == 0 {
                XCGLogger.debug("Modify passwd failed")
            }
            break
        case .UserInfoResult:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug("\(dict)")
            let user = UserInfo()
            user.setInfo(.Other, info: dict.dictionaryObject)
            UserInfo.userList.setValue(user, forKey: "\(user.uid!)")
            break
        case .InvitationResult:
            
            break
        case .RecvChatMessage:
            let dict = JSON.init(data: body as! NSData)
            XCGLogger.debug("\(dict)")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.ChatMessgaeNotiy, object: nil, userInfo: ["data": dict.dictionaryObject!])
            break
        default:
            break
        }
        
        return true
    }
    
    // MARK: - GCDAsyncSocketDelegate
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        XCGLogger.defaultInstance().debug("didConnectToHost:\(host)  \(port)")
        
        socket?.readDataWithTimeout(-1, tag: 0)
        
//        performSelector(#selector(SocketManager.sendHeart), withObject: nil, afterDelay: 10)
    }
    
    func sendHeart() {
        SocketManager.sendData(.Heart, data: nil)
        performSelector(#selector(SocketManager.sendHeart), withObject: nil, afterDelay: 10)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        XCGLogger.defaultInstance().debug("socketDidDisconnect:\(err)")
        
        performSelector(#selector(SocketManager.connectSock), withObject: nil, afterDelay: 15)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        XCGLogger.defaultInstance().debug("didReadData:\(data)")
        buffer.appendData(data)
        let headLen = SockHead.size
        while buffer.length >= headLen {
            let head = SockHead(data: buffer)
            let packageLen = Int(head.fields["packageLen"]! as! NSNumber)
            let bodyLen = Int(head.fields["dataLen"]! as! NSNumber)
            let bodyData = buffer.subdataWithRange(NSMakeRange(headLen, bodyLen))
            let body = String.init(data: bodyData, encoding: NSUTF8StringEncoding)
            XCGLogger.debug(body)
            buffer.setData(buffer.subdataWithRange(NSMakeRange(packageLen, buffer.length - packageLen)))
            recvData(head, body: bodyData)
            
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


