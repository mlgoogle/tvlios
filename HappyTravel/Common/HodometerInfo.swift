//
//  HodometerInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
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
}

class HodometerInfo : Object {
    
    dynamic var service_type_ = 0
    
    dynamic var service_id_ = 0
    
    dynamic var service_price_ = 0
    
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
    
    func setInfo(info: HodometerInfo) {
        service_type_ = info.service_type_
        
        service_id_ = info.service_id_
        
        service_price_ = info.service_price_
        
        service_name_ = info.service_name_
        
        service_time_ = info.service_time_
        
        start_ = info.start_
        
        end_ = info.end_
        
        order_id_ = info.order_id_
        
        status_ = info.status_
        
        to_uid_ = info.to_uid_
        
        to_head_ = info.to_head_
        
        to_name_ = info.to_name_
        
        from_uid_ = info.from_uid_
        
        from_head_ = info.from_head_
        
        from_name_ = info.from_name_
        
        is_asked_ = info.is_asked_
    }
    
}
