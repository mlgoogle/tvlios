//
//  AppointmentInfo.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/8.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import RealmSwift

class AppointmentInfo: Object {

    
    dynamic var appointment_id_	= 0
    dynamic var user_id_ = 0
    dynamic var city_code_ = 0
    dynamic var start_time_ = 0
    dynamic var end_time_ = 0
    dynamic var is_other_ = 0
    dynamic var other_gender_ = 0
    dynamic var other_name_:String?
    dynamic var other_phone_:String?
    dynamic var service_id_ = 0
    dynamic var service_name_:String?
    dynamic var service_price_ = 0
    dynamic var service_time_:String?
    dynamic var service_type_ = 0
    dynamic var status_ = 0
    dynamic var to_head_:String?
    dynamic var to_name_:String?
    dynamic var to_user_ = 0
    dynamic var order_price_ = 0
    dynamic var order_id_ = 0
    func setInfo(info:AppointmentInfo) {
        
        appointment_id_ = info.appointment_id_
        user_id_ = info.user_id_
        city_code_ = info.city_code_
        start_time_  = info.start_time_
        end_time_ = info.end_time_
        is_other_ = info.is_other_
        
    }
    
}
