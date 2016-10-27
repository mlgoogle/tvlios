//
//  CenturionCardConsumedInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/21.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class CenturionCardConsumedInfo: Object {
    
    dynamic var order_id_ = 0
    
    dynamic var privilege_name_:String?
    
    dynamic var privilege_pic_:String?
    
    dynamic var privilege_price_ = 0
    
    dynamic var privilege_time_ = 0
    
    
    func setInfo(info: CenturionCardConsumedInfo) {
        order_id_ = info.order_id_
        
        privilege_name_ = info.privilege_name_
        
        privilege_pic_ = info.privilege_pic_
        
        privilege_price_ = info.privilege_price_
        
        privilege_time_ = info.privilege_time_
        
    }
    
}
