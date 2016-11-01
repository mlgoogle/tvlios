//
//  InvoiceServiceInfo.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class InvoiceServiceInfo: Object {
    
    dynamic var service_id_    = 0
    dynamic var uid_           = 0
    dynamic var service_price_ = 0.0
    dynamic var service_type_  = 0
    dynamic var order_time_    = 0
    
    
    dynamic var nick_name_:String?
    dynamic var service_name_:String?
    dynamic var service_time_:String?
}