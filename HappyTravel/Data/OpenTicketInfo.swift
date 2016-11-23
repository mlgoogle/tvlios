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
    func setInfoWithHodometer(_ info: HodometerInfo) {
        order_id_ = info.order_id_
        name = info.to_name_
        content = info.service_name_
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        time = info.start_
        price = "\(Double(info.order_price_) / 100) 元"
        type = info.service_type_ == 0 ? "商务游" : "高端游"
        
    }
    
    func setInfoWithConsumedInfo(_ info: CenturionCardConsumedInfo) {
        order_id_ = info.order_id_
        let formatter = NumberFormatter.init()
        formatter.roundingMode = .halfDown
        formatter.numberStyle = .spellOut
        let lvNum = NSNumber.init(value: info.privilege_lv_ as Int)
        let lvStr = formatter.string(from: lvNum)
        name = "\(lvStr!)星黑卡消费"
        
        content = info.privilege_name_
        
        type = "黑卡消费"
        
        price = "\(Double(info.privilege_price_) / 100) 元"
        
        time = info.order_time_
        
    }
}
