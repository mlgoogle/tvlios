
//
//  ServiceCityModel.swift
//  HappyTravel
//
//  Created by 司留梦 on 17/1/4.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

/*
 cityName = 深圳市;
	cityCode = 440300;
	provinceName = 广东省;
	provinceCode = 440000;
 */

class CityNameBaseInfo: Object {
    
    dynamic var cityName:String?
    
    dynamic var cityCode:Int = 0
    
    dynamic var provinceName:String?
    
    dynamic var provinceCode:Int = 0
    
}

class CityNameInfoModel: Object {
    
    let service_city_ = List<CityNameBaseInfo>()
    
}