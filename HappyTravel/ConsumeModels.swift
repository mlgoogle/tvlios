//
//  ConsumeModels.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

enum HodometerStatus : Int {
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

class HodometerListModel: Object {
    let trip_list_ = List<HodometerInfoModel>()
}

class HodometerInfoModel : Object {
    
    dynamic var service_type_ = 0
    
    dynamic var service_id_ = 0
    
    dynamic var order_price_ = 0
    
    dynamic var service_name_:String?
    
    dynamic var service_time_:String?
    
    dynamic var start_ = 0
    
    dynamic var end_ = 0
    
    dynamic var order_id_ = 0
    
    dynamic var status_ = 0
    
    dynamic var to_uid_ = 0
    
    dynamic var to_head_:String?
    
    dynamic var to_name_:String?
    
    dynamic var from_uid_ = 0
    
    dynamic var from_head_:String?
    
    dynamic var from_name_:String?
    
    dynamic var is_asked_ = 0
    
    dynamic var days_ = 0
    
    dynamic var order_addr:String?
    
}