//
//  CityInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/23.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class CityInfo: NSObject {
    
    var cityName:String?
    var cityCode:Int?
    var provinceName:String?
    var provinceCode:Int?
    
    func setInfo(info: Dictionary<String, AnyObject>?) {
        for (key, value) in info! {
            switch key {
            case "city_name_":
                cityName = value as? String
                break
            case "city_code_":
                cityCode = value as? Int
                break
            case "province_name_":
                provinceName = value as? String
                break
            case "province_code_":
                provinceCode = value as? Int
                break
            default:
                XCGLogger.warning("Exception:[\(key) : \(value)]")
                break
            }
        }
    }
    
}
