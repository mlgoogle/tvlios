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
    
    class ValueProperty: NSObject {
        
        var name:String?
        
        var type:String?
    }
    
    static var size:Int {
        get {
            var tmpSize = 0
            var cnt:UInt32 = 0
            let memberList = class_copyPropertyList(self.classForCoder(), &cnt)
            for i in 0..<cnt {
                let item = memberList[Int(i)]
                var cnt2:UInt32 = 0
                let prList = property_copyAttributeList(item, &cnt2)
                
                var type = ""
                for j in 0..<cnt2 {
                    let property = prList[Int(j)]
                    let propertyName = String.fromCString(property.name)
                    if propertyName == "T" {
                        type = String.fromCString(property.value)!
                    }
                }
                tmpSize += getMemSizeWith(type)
                
            }
            return tmpSize
        }
    }
    
    static func getMemSizeWith(type: String) -> Int {
        switch type {
        case "c", "C":
            return sizeof(Int8)
        case "s", "S":
            return sizeof(Int16)
        case "i", "I":
            return sizeof(Int32)
        case "q", "Q":
            return sizeof(Int64)
        default:
            return 0
        }
    }
    
    override init() {
        super.init()
    }
    
    init(data: NSData) {
        super.init()
        
        unpack(data)
    }
    
    func getPropertyList() -> [[UInt32:UnsafeMutablePointer<objc_property_t>]] {
        var propertyList = [[UInt32:UnsafeMutablePointer<objc_property_t>]]()
        var cls = self.classForCoder
        while cls != BMB2Object.self && cls != BMB2Object.superclass() {
            var cnt:UInt32 = 0
            let memberList = class_copyPropertyList(cls, &cnt)
            propertyList.append([cnt: memberList])
            cls = cls.superclass()!
        }
        
        return propertyList
    }
    
    func getValueProperty(property: objc_property_t) -> ValueProperty {
        var cnt2:UInt32 = 0
        let prList = property_copyAttributeList(property, &cnt2)
        
        let valueProperty = ValueProperty()
        for j in 0..<cnt2 {
            let property = prList[Int(j)]
            let propertyName = String.fromCString(property.name)
            if propertyName == "T" {
                valueProperty.type = String.fromCString(property.value)!
            } else if propertyName == "V" {
                valueProperty.name = String.fromCString(property.value)!
            }
            
        }
        
        return valueProperty
    }
    
    func unpack(data: NSData) {
        var tmpData = data
        let propertyList = getPropertyList()
        
        for propertyInfo in propertyList.reverse() {
            let cnt = propertyInfo.keys.first!
            let propertys = propertyInfo[cnt]
            for i in 0..<cnt {
                let item = propertys![Int(i)]
                let valueProperty = getValueProperty(item)
                
                let size = BMB2Object.getMemSizeWith(valueProperty.type!)
                switch valueProperty.type! {
                case "c":
                    var buf = Int8(0)
                    tmpData.getBytes(&buf, length: size)
                    setValue(buf.hashValue, forKey: valueProperty.name!)
                case "s":
                    var buf = Int16(0)
                    tmpData.getBytes(&buf, length: size)
                    setValue(buf.hashValue, forKey: valueProperty.name!)
                case "S":
                    var buf = UInt16(0)
                    tmpData.getBytes(&buf, length: size)
                    setValue(buf.hashValue, forKey: valueProperty.name!)
                case "i":
                    var buf = Int32(0)
                    tmpData.getBytes(&buf, length: size)
                    setValue(buf.hashValue, forKey: valueProperty.name!)
                case "I":
                    var buf = UInt32(0)
                    tmpData.getBytes(&buf, length: size)
                    setValue(buf.hashValue, forKey: valueProperty.name!)
                case "q":
                    var buf = Int64(0)
                    tmpData.getBytes(&buf, length: size)
                    setValue(buf.hashValue, forKey: valueProperty.name!)
                case "Q":
                    var buf = UInt64(0)
                    tmpData.getBytes(&buf, length: size)
                    setValue(buf.hashValue, forKey: valueProperty.name!)
                case "@\"NSData\"":
                    setValue(tmpData, forKey: valueProperty.name!)
                default:
                    break
                }
                tmpData = tmpData.subdataWithRange(NSMakeRange(size, tmpData.length-size))
            }
        }
    }
    
    func pack() -> NSData? {
        let propertyList = getPropertyList()
        let data = NSMutableData()
        for propertyInfo in propertyList.reverse() {
            let cnt = propertyInfo.keys.first!
            let propertys = propertyInfo[cnt]
            for i in 0..<cnt {
                let item = propertys![Int(i)]
                let valueProperty = getValueProperty(item)
                
                let value = valueForKey(valueProperty.name!) as? NSNumber
                let size = BMB2Object.getMemSizeWith(valueProperty.type!)
                
                switch valueProperty.type! {
                case "c":
                    var buf = value?.charValue
                    data.appendBytes(&buf, length: size)
                case "C":
                    var buf = value?.unsignedCharValue
                    data.appendBytes(&buf, length: size)
                case "s":
                    var buf = value?.shortValue
                    data.appendBytes(&buf, length: size)
                case "S":
                    var buf = value?.unsignedShortValue
                    data.appendBytes(&buf, length: size)
                case "i":
                    var buf = value?.intValue
                    data.appendBytes(&buf, length: size)
                case "I":
                    var buf = value?.unsignedIntValue
                    data.appendBytes(&buf, length: size)
                case "q":
                    var buf = value?.longLongValue
                    data.appendBytes(&buf, length: size)
                case "Q":
                    var buf = value?.unsignedLongLongValue
                    data.appendBytes(&buf, length: size)
                case "@\"NSData\"":
                    if let v = valueForKey(valueProperty.name!) as? NSData {
                        data.appendData(v)
                    }
                default:
                    break
                }

            }
        }
        
        return data.length > 0 ? data : nil
    }
}
