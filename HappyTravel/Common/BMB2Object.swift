//
//  BMB2Object.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/11/10.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class BMB2Object : NSObject {
    /// Binary Memory Block <=> Object
    
    static var size:Int {
        get {
            var tmpSize = 0
            var cnt:UInt32 = 0
            let memberList = class_copyPropertyList(self.classForCoder(), &cnt)
            for i in 0..<cnt {
                let item = memberList?[Int(i)]
                var cnt2:UInt32 = 0
                let prList = property_copyAttributeList(item, &cnt2)
                
                var type = ""
                for j in 0..<cnt2 {
                    let property = prList?[Int(j)]
                    let propertyName = String(cString: (property?.name)!)
                    if propertyName == "T" {
                        type = String(cString: (property?.value)!)
                    }
                }
                tmpSize += getMemSizeWith(type)
                
            }
            return tmpSize
        }
    }
    
    static func getMemSizeWith(_ type: String) -> Int {
        switch type {
        case "c", "C":
            return MemoryLayout<Int8>.size
        case "s", "S":
            return MemoryLayout<Int16>.size
        case "i", "I":
            return MemoryLayout<Int32>.size
        case "q", "Q":
            return MemoryLayout<Int64>.size
        default:
            return 0
        }
    }
    
    override init() {
        super.init()
    }
    
    init(data: Data) {
        super.init()
        
        unpack(data)
    }
    
    func unpack(_ data: Data) {
        var tmpData = data
        var cnt:UInt32 = 0
        let memberList = class_copyPropertyList(self.classForCoder, &cnt)
        for i in 0..<cnt {
            let item = memberList?[Int(i)]
            var cnt2:UInt32 = 0
            let prList = property_copyAttributeList(item, &cnt2)
            
            var type = ""
            var valueName = ""
            for j in 0..<cnt2 {
                let property = prList?[Int(j)]
                let propertyName = String(cString: (property?.name)!)
                if propertyName == "T" {
                    type = String(cString: (property?.value)!)
                } else if propertyName == "V" {
                    valueName = String(cString: (property?.value)!)
                }
                
            }
            let size = BMB2Object.getMemSizeWith(type)
            switch type {
            case "c":
                var buf = Int8(0)
                (tmpData as NSData).getBytes(&buf, length: size)
                setValue(buf.hashValue, forKey: valueName)
            case "s":
                var buf = Int16(0)
                (tmpData as NSData).getBytes(&buf, length: size)
                setValue(buf.hashValue, forKey: valueName)
            case "S":
                var buf = UInt16(0)
                (tmpData as NSData).getBytes(&buf, length: size)
                setValue(buf.hashValue, forKey: valueName)
            case "i":
                var buf = Int32(0)
                (tmpData as NSData).getBytes(&buf, length: size)
                setValue(buf.hashValue, forKey: valueName)
            case "I":
                var buf = UInt32(0)
                (tmpData as NSData).getBytes(&buf, length: size)
                setValue(buf.hashValue, forKey: valueName)
            case "q":
                var buf = Int64(0)
                (tmpData as NSData).getBytes(&buf, length: size)
                setValue(buf.hashValue, forKey: valueName)
            case "Q":
                var buf = UInt64(0)
                (tmpData as NSData).getBytes(&buf, length: size)
                setValue(buf.hashValue, forKey: valueName)
            default:
                break
            }
            tmpData = tmpData.subdata(in: NSMakeRange(size, tmpData.count-size))
        }
        
    }
    
    func pack() -> Data? {
        var cnt:UInt32 = 0
        let data = NSMutableData()
        let memberList = class_copyPropertyList(self.classForCoder, &cnt)
        for i in 0..<cnt {
            let item = memberList?[Int(i)]
            var cnt2:UInt32 = 0
            let prList = property_copyAttributeList(item, &cnt2)
            
            var type = ""
            var valueName = ""
            for j in 0..<cnt2 {
                let property = prList?[Int(j)]
                let propertyName = String(cString: (property?.name)!)
                if propertyName == "T" {
                    type = String(cString: (property?.value)!)
                } else if propertyName == "V" {
                    valueName = String(cString: (property?.value)!)
                }
            }
            
            let value = self.value(forKey: valueName) as? NSNumber
            let size = BMB2Object.getMemSizeWith(type)
            
            switch type {
            case "c":
                var buf = value?.int8Value
                data.append(&buf, length: size)
            case "C":
                var buf = value?.uint8Value
                data.append(&buf, length: size)
            case "s":
                var buf = value?.int16Value
                data.append(&buf, length: size)
            case "S":
                var buf = value?.uint16Value
                data.append(&buf, length: size)
            case "i":
                var buf = value?.int32Value
                data.append(&buf, length: size)
            case "I":
                var buf = value?.uint32Value
                data.append(&buf, length: size)
            case "q":
                var buf = value?.int64Value
                data.append(&buf, length: size)
            case "Q":
                var buf = value?.uint64Value
                data.append(&buf, length: size)
            default:
                break
            }
            
        }
        
        return data.length > 0 ? data : nil
    }
    
}
