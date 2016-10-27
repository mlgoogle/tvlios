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
    dynamic var invoice_price_  = 0.0
    
    dynamic var oid_str_:String?
    
       func setInfo(info: InvoiceHistoryInfo) {
        
        invoice_id_     = info.invoice_id_
        invoice_status_ = info.invoice_status_
        invoice_time_   = info.invoice_time_
        invoice_price_  = info.invoice_price_
        oid_str_        = info.oid_str_
        
        
    }
}

