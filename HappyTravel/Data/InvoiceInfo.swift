//
//  InvoiceInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/26.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class InvoiceInfo: Object {
    
    dynamic var order_id_ = 0
    
    dynamic var title_:String?
    
    dynamic var taxpayer_num_:String?
    
    dynamic var company_addr_:String?
    
    dynamic var invoice_type_ = 0
    
    dynamic var user_name_:String?
    
    dynamic var user_mobile_:String?
    
    dynamic var area_:String?
    
    dynamic var addr_detail_:String?
    
    dynamic var remarks_:String?
    
}

