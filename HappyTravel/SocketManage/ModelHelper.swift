//
//  ModelBase.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import Realm.RLMSchema
import RealmSwift
import SwiftyJSON


class ModelHelper {
    
    class ValueProperty: NSObject {
        
        var name:String?
        
        var type:String?
    }
    
    static func getPropertyList(model: AnyObject) -> [[UInt32:UnsafeMutablePointer<objc_property_t>]] {
        var propertyList = [[UInt32:UnsafeMutablePointer<objc_property_t>]]()
        var cls = model.classForCoder
        while cls != Object.self && cls != Object.superclass() {
            var cnt:UInt32 = 0
            let memberList = class_copyPropertyList(cls, &cnt)
            propertyList.append([cnt: memberList])
            cls = cls.superclass()!
        }
        
        return propertyList
    }
    
    static func getValueProperty(property: objc_property_t) -> ValueProperty {
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
    
    static func modelToData(model: AnyObject) -> NSData? {
        let propertyList = ModelHelper.getPropertyList(model)
        var dict = [String: AnyObject]()
        for propertyInfo in propertyList.reverse() {
            let cnt = propertyInfo.keys.first!
            let propertys = propertyInfo[cnt]
            for i in 0..<cnt {
                let item = propertys![Int(i)]
                let valueProperty = ModelHelper.getValueProperty(item)
                if let value = model.valueForKey(valueProperty.name!) {
                    dict[valueProperty.name!] = value
                }
                
            }
        }
        let json = JSON.init(dict)
        return try! json.rawData()
    }
}
