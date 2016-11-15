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
    dynamic var service_price_ = 0.00
    dynamic var order_time_    = 0
    
    dynamic var oid_str_: String?
    dynamic var service_type_ : String?
    dynamic var nick_name_:String?
    dynamic var service_name_:String?
    dynamic var service_time_:String?
    
    func setInfoWithCommenInvoice(info: NSDictionary) {
        oid_str_ = (info.valueForKey("oid_str_") as? String)!
        service_id_ = (info.valueForKey("service_id_")?.integerValue)!
        service_price_ = (info.valueForKey("service_price_")?.doubleValue)!/100
        order_time_ = (info.valueForKey("order_time_")?.integerValue)!
        service_type_ = info.valueForKey("service_type_")!.integerValue == 1 ? "高端游":"商务游"
        nick_name_ = info.valueForKey("nick_name_") as? String
        service_name_ = info.valueForKey("service_name_") as? String
        service_time_ =  info.valueForKey("service_time_") as? String
        
    }
    
    func setInfoWithBlackCardInvoice(info: NSDictionary) {
        oid_str_ = (info.valueForKey("oid_str_") as? String)!
        service_id_ = (info.valueForKey("order_id_")?.integerValue)!
        service_price_ = (info.valueForKey("privilege_price_")?.doubleValue)!/100
        order_time_ = (info.valueForKey("order_time_")?.integerValue)!
        service_type_ = "黑卡消费"
        
        let formatter = NSNumberFormatter.init()
        formatter.roundingMode = .RoundHalfDown
        formatter.numberStyle = .SpellOutStyle
        let lvNum = NSNumber.init(long: (info.valueForKey("privilege_lv_")?.integerValue)!)
        let lvStr = formatter.stringFromNumber(lvNum)
        nick_name_ = "\(lvStr!)星黑卡消费"
        
        service_name_ = info.valueForKey("privilege_name_") as? String
        service_time_ =  info.valueForKey("service_time_") as? String
    }
    
    func setInfo(info: InvoiceServiceInfo) {
        service_id_ = info.service_id_
        service_price_ = info.service_price_
        order_time_ = info.order_time_
        oid_str_ = info.oid_str_
        service_type_ = info.service_type_
        nick_name_ = info.nick_name_
        service_name_ = info.service_name_
        service_time_ = info.service_time_
        
    }
}