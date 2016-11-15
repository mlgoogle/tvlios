//
//  OpenTicketInfo.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/14.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import RealmSwift

class OpenTicketInfo: Object {
    dynamic var order_id_ = 0
    dynamic var name: String?
    dynamic var time: Int = 0
    dynamic var content: String?
    dynamic var price: String?
    dynamic var type: String?
    dynamic var selected: Bool = false
    func setInfoWithHodometer(info: HodometerInfo) {
        order_id_ = info.order_id_
        name = info.to_name_
        content = info.service_name_
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        time = info.start_
        price = "\(info.service_price_) 元"
        type = info.service_type_ == 0 ? "商务游" : "高端游"
        
    }
    
    func setInfoWithConsumedInfo(info: CenturionCardConsumedInfo) {
        order_id_ = info.order_id_
        let formatter = NSNumberFormatter.init()
        formatter.roundingMode = .RoundHalfDown
        formatter.numberStyle = .SpellOutStyle
        let lvNum = NSNumber.init(long: info.privilege_lv_)
        let lvStr = formatter.stringFromNumber(lvNum)
        name = "\(lvStr!)星黑卡消费"
        
        content = info.privilege_name_
        
        type = "黑卡消费"
        
        price = "\(info.privilege_price_) 元"
        
        time = info.order_time_
        
    }
}
