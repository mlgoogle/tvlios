//
//  CityInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/23.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift

class CityInfo : Object {
    
    dynamic var cityName:String?
    
    dynamic var cityCode:Int = 0
    
    dynamic var provinceName:String?
    
    dynamic var provinceCode:Int = 0
    
    func setInfo(info: Dictionary<String, AnyObject>?) {
        for (key, value) in info! {
            switch key {
            case "city_name_":
                cityName = value as? String
                break
            case "city_code_":                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
                cityCode = (value as? Int)!
                break
            case "province_name_":
                provinceName = value as? String
                break
            case "province_code_":
                provinceCode = (value as? Int)!
                break
            default:
                XCGLogger.warning("Exception:[\(key) : \(value)]")
                break
            }
        }
    }
    func refreshInfo(info:CityInfo) {
        cityName = info.cityName
        cityCode = info.cityCode
        provinceCode = info.provinceCode
        provinceName = info.provinceName
    }

    
}
