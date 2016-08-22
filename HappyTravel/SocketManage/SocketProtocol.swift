//
//  SocketProtocol.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/11.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class SockHead : NSObject {
    static var size:Int {
        get {
            var len = 0
            for item in SockHead.fieldsAttr {
                let ft = item as NSDictionary
                let fieldName = ft.allKeys[0] as! String
                let type = ft.valueForKey(fieldName) as! String
                if type.rangeOfString("8") != nil {
                    len += sizeof(Int8)
                } else if type.rangeOfString("16") != nil {
                    len += sizeof(Int16)
                } else if type.rangeOfString("32") != nil {
                    len += sizeof(Int32)
                } else if type.rangeOfString("64") != nil {
                    len += sizeof(Int64)
                }
            }
            return len
        }
    }
    
    static let fieldsAttr:Array = [["packageLen": "Int16"],
                                   ["isZipEncrypt": "Int8"],
                                   ["type": "Int8"],
                                   ["signature": "Int16"],
                                   ["opcode": "Int16"],
                                   ["dataLen": "Int16"],
                                   ["timestamp": "UInt32"],
                                   ["sessionID": "Int64"],
                                   ["reserved": "Int32"]]
    var fields:Dictionary<String, AnyObject> = [:]
 
    init(data: NSData) {
        super.init()
        var srcData = data
        for item in SockHead.fieldsAttr {
            let ft = item as NSDictionary
            let fieldName = ft.allKeys[0] as! String
            let type = ft.valueForKey(fieldName) as! String
            srcData = setField(fieldName, typeStr: type, srcData: srcData)!
            XCGLogger.defaultInstance().debug("\(fieldName):\(fields[fieldName]!)")
        }
    }
    
    override init() {
        super.init()
        for item in SockHead.fieldsAttr {
            let ft = item as NSDictionary
            let fieldName = ft.allKeys[0] as! String
            let type = ft.valueForKey(fieldName) as! String
            setField(fieldName, typeStr: type, srcData: nil)
        }
    }
    
    func makePackage() -> NSData? {
        let data = NSMutableData()
        for item in SockHead.fieldsAttr {
            let ft = item as NSDictionary
            let fieldName = ft.allKeys[0] as! String
            let type = ft.valueForKey(fieldName) as! String
            let value = fields[fieldName] as! Int
            let tmp = NSNumber.init(long: value)
            switch type {
            case "Int8", "Int16", "Int32", "Int64", "UInt8", "UInt16", "UInt32", "UInt64":
                if type.rangeOfString("U") != nil {
                    if type.rangeOfString("8") != nil {
                        var realValue = tmp.charValue
                        data.appendBytes(&realValue, length: sizeof(Int8))
                    } else if type.rangeOfString("16") != nil {
                        var realValue = tmp.shortValue
                        data.appendBytes(&realValue, length: sizeof(Int16))
                    } else if type.rangeOfString("32") != nil {
                        var realValue = tmp.intValue
                        data.appendBytes(&realValue, length: sizeof(Int32))
                    } else if type.rangeOfString("64") != nil {
                        var realValue = tmp.longLongValue
                        data.appendBytes(&realValue, length: sizeof(Int64))
                    }
                    
                } else {
                    if type.rangeOfString("8") != nil {
                        var realValue = tmp.unsignedCharValue
                        data.appendBytes(&realValue, length: sizeof(UInt8))
                    } else if type.rangeOfString("16") != nil {
                        var realValue = tmp.unsignedShortValue
                        data.appendBytes(&realValue, length: sizeof(UInt16))
                    } else if type.rangeOfString("32") != nil {
                        var realValue = tmp.unsignedIntValue
                        data.appendBytes(&realValue, length: sizeof(UInt32))
                    } else if type.rangeOfString("64") != nil {
                        var realValue = tmp.unsignedLongLongValue
                        data.appendBytes(&realValue, length: sizeof(UInt64))
                    }
                    
                }
                break
            default:
                break
            }
        }
        return data
    }
    
    private func setField(fieldName: String, typeStr: String, srcData: NSData?) -> NSData? {
        var len = 0
        switch typeStr {
        case "Int8", "Int16", "Int32", "Int64", "UInt8", "UInt16", "UInt32", "UInt64":
            if srcData == nil || srcData!.length == 0 {
                fields[fieldName] = Int(0)
                return nil
            }
            var value = 0
            if typeStr.rangeOfString("U") != nil {
                if typeStr.rangeOfString("8") != nil {
                    len = sizeof(UInt8)
                    var valueBuf = UInt8(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                } else if typeStr.rangeOfString("16") != nil {
                    len = sizeof(UInt16)
                    var valueBuf = UInt16(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                } else if typeStr.rangeOfString("32") != nil {
                    len = sizeof(UInt32)
                    var valueBuf = UInt32(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                } else if typeStr.rangeOfString("64") != nil {
                    len = sizeof(UInt64)
                    var valueBuf = UInt64(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                }
            } else {
                if typeStr.rangeOfString("8") != nil {
                    len = sizeof(Int8)
                    var valueBuf = Int8(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                } else if typeStr.rangeOfString("16") != nil {
                    len = sizeof(Int16)
                    var valueBuf = Int16(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                } else if typeStr.rangeOfString("32") != nil {
                    len = sizeof(Int32)
                    var valueBuf = Int32(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                } else if typeStr.rangeOfString("64") != nil {
                    len = sizeof(Int64)
                    var valueBuf = Int64(0)
                    srcData!.getBytes(&valueBuf, length: len)
                    value = Int(valueBuf)
                }
            }
            fields[fieldName] = value
            break
            
        default:
            break
        }
        return srcData!.subdataWithRange(NSMakeRange(len, srcData!.length-len))
    }
}


