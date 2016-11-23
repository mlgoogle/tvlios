//
//  OrderInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/20.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

enum OrderStatus : Int {
    case waittingAccept = 0
    case reject = 1
    case accept = 2
    case waittingPay = 3
    case paid = 4
    case cancel = 5
    case onGoing = 6
    case completed = 7
    case invoiceMaking = 8
    case invoiceMaked = 9
}

class OrderInfo: Object {
    
    dynamic var oid_ = 0
    
    dynamic var order_status_ = 0
    
    dynamic var start_time_ = 0
    
    dynamic var service_name_:String?
    
    dynamic var service_price_ = 0
    
    dynamic var service_time_:String?
    
    dynamic var from_name_:String?
    
    dynamic var from_uid_ = 0
    
    dynamic var from_url_:String?
    
    dynamic var to_name_:String?
    
    dynamic var to_uid_ = 0
    
    dynamic var to_url_:String?
 
}

