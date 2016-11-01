//
//  InvoiceHistoryInfo.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
class InvoiceHistoryInfo: Object {
    
    dynamic var invoice_id_     = 0
    dynamic var invoice_status_ = 0
    dynamic var invoice_time_   = 0
    dynamic var order_num_      = 0
    dynamic var first_time_     = 0
    dynamic var final_time_     = 0
    dynamic var invoice_type_   = 0
    dynamic var invoice_price_  = 0.0
    dynamic var total_price_    = 0.0
    
    dynamic var oid_str_:String?
    dynamic var title_:String?
    dynamic var user_name_:String?
    dynamic var user_mobile_:String?
    dynamic var area_:String?
    dynamic var addr_detail_:String?
    
       func setInfo(info: InvoiceHistoryInfo) {
        invoice_id_     = info.invoice_id_
        invoice_status_ = info.invoice_status_
        invoice_time_   = info.invoice_time_
        invoice_price_  = info.invoice_price_
        oid_str_        = info.oid_str_
        title_          = info.title_
        user_name_      = info.user_name_
        user_mobile_    = info.user_mobile_
        area_           = info.area_
        addr_detail_    = info.addr_detail_
        invoice_type_   = info.invoice_type_
        total_price_    = info.total_price_
        order_num_      = info.order_num_
        first_time_     = info.first_time_
        final_time_     = info.final_time_
    }
    func refreshOtherInfo(info:InvoiceHistoryInfo) {
   
        title_          = info.title_
        user_name_      = info.user_name_
        user_mobile_    = info.user_mobile_
        area_           = info.area_
        addr_detail_    = info.addr_detail_
        invoice_type_   = info.invoice_type_
        total_price_    = info.total_price_
        order_num_      = info.order_num_
        first_time_     = info.first_time_
        final_time_     = info.final_time_
        
    }
}

