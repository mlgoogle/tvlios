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
        case Login = 1001
        case Logined = 1002
        case GetServantInfo = 1003
        case ServantInfo = 1004
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
        do {
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
        case .Login:
            head.fields["opcode"] = 1001
            let dict:Dictionary<String, AnyObject> = ["phone_num_": "15157109258s",
                                                      "passwd_": "123456x",
                                                      "user_type_": 1]
            bodyJSON = JSON.init(dict)
            break
        case .GetServantInfo:
            head.fields["opcode"] = 1003
            let dict:Dictionary<String, AnyObject> = ["latitude_": 31.20805228400625,
                                                      "longitude_": 121.60019287100375,
                                                      "distance_": 20.1]
            bodyJSON = JSON.init(dict)
            break
        default:
            break
        }
        do {
            body = try bodyJSON!.rawData()
        } catch {
            
        }
        if opcode == SockOpcode.AppError {
            return false
        }
        
        head.fields["dataLen"] = body!.length
        head.fields["packageLen"] = SockHead.size + body!.length
        let package = head.makePackage()!.mutableCopy() as! NSMutableData
        package.appendData(body!)
        sock?.socket?.writeData(package, withTimeout: 5, tag: 1)
        
        return true
        
    }
    
    func recvData(head: SockHead?, body:AnyObject?) ->Bool {
        if head == nil {
            return false
        }
        XCGLogger.debug(String.init(data: body as! NSData, encoding: NSUTF8StringEncoding))
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
        default:
            break
        }
        
        return true
    }
    
    // MARK: - GCDAsyncSocketDelegate
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        XCGLogger.defaultInstance().debug("didConnectToHost:\(host)  \(port)")
        
        socket?.readDataWithTimeout(-1, tag: 0)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        XCGLogger.defaultInstance().debug("socketDidDisconnect:\(err)")
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
    
}


