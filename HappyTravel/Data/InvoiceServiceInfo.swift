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
    
    func setInfoWithCommenInvoice(_ info: NSDictionary) {
        oid_str_ = (info.value(forKey: "oid_str_") as? String)!
        service_id_ = ((info.value(forKey: "service_id_") as AnyObject).intValue)!
        service_price_ = ((info.value(forKey: "service_price_") as AnyObject).doubleValue)!/100
        order_time_ = ((info.value(forKey: "order_time_") as AnyObject).intValue)!
        service_type_ = (info.value(forKey: "service_type_")! as AnyObject).intValue == 1 ? "高端游":"商务游"
        nick_name_ = info.value(forKey: "nick_name_") as? String
        service_name_ = info.value(forKey: "service_name_") as? String
        service_time_ =  info.value(forKey: "service_time_") as? String
        
    }
    
    func setInfoWithBlackCardInvoice(_ info: NSDictionary) {
        oid_str_ = (info.value(forKey: "oid_str_") as? String)!
        service_id_ = ((info.value(forKey: "order_id_") as AnyObject).intValue)!
        service_price_ = ((info.value(forKey: "privilege_price_") as AnyObject).doubleValue)!/100
        order_time_ = ((info.value(forKey: "order_time_") as AnyObject).intValue)!
        service_type_ = "黑卡消费"
        
        let formatter = NumberFormatter.init()
        formatter.roundingMode = .halfDown
        formatter.numberStyle = .spellOut
        let lvNum = NSNumber.init(value: ((info.value(forKey: "privilege_lv_") as AnyObject).intValue)! as Int)
        let lvStr = formatter.string(from: lvNum)
        nick_name_ = "\(lvStr!)星黑卡消费"
        
        service_name_ = info.value(forKey: "privilege_name_") as? String
        service_time_ =  info.value(forKey: "service_time_") as? String
    }
    
    func setInfo(_ info: InvoiceServiceInfo) {
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
