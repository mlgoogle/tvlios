
//
//  ServiceCityModel.swift
//  HappyTravel
//
//  Created by 司留梦 on 17/1/4.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift


class CityNameBaseInfo: Object {
    
    dynamic var city_name_:String?
    
    dynamic var city_code_:Int = 0
    
    dynamic var province_name_:String?
    
    dynamic var province_code_:Int = 0
    
}

class CityNameInfoModel: Object {
    
    let service_city_ = List<CityNameBaseInfo>()
    
}