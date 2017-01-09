//
//  ModelBase.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


extension Object {
    
    func toData() -> NSData? {
        let dict = toDictionary()
        let json = JSON.init(dict)
        return try! json.rawData()
    }
    
    func toDictionary() -> NSDictionary {
        let properties = objectSchema.properties.map { $0.name }
        let dictionary = dictionaryWithValuesForKeys(properties)
        
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeysWithDictionary(dictionary)
        
        for prop in objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name)
            }
            
        }
        return mutabledic
    }

    func refreshPropertiesWithModel(model:Object) {
        for pro in objectSchema.properties as [Property]!  {
            if model[pro.name] != nil {
                if let selfModelPro = self[pro.name] as? Object  {
                    guard model[pro.name] != nil else {continue}
                    selfModelPro.refreshPropertiesWithModel(model[pro.name] as! Object)
                } else if let modelPro = model[pro.name] as? ListBase {
                    self[pro.name]  =  modelPro
                }
            }
        }
    }
}
