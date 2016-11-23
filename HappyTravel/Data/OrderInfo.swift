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
    case WaittingAccept = 0
    case Reject = 1
    case Accept = 2
    case WaittingPay = 3
    case Paid = 4
    case Cancel = 5
    case OnGoing = 6
    case Completed = 7
    case InvoiceMaking = 8
    case InvoiceMaked = 9
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

