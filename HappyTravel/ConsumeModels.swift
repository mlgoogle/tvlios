//
//  ConsumeModels.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
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
    case OnGoing = 6
    case Completed = 7
    case InvoiceMaking = 8
    case InvoiceMaked = 9
}
class OrderRequestBaseModel: Object {
    dynamic var uid_ = CurrentUser.uid_
    dynamic var count_ = 10
}


//邀约记录
class HodometerRequestModel: OrderRequestBaseModel {
    dynamic var order_id_ = 0
    
}


class HodometerListModel: Object {
    let trip_list_ = List<HodometerInfoModel>()
}

class HodometerInfoModel : Object {
    
    dynamic var service_type_ = 0
    
    dynamic var service_id_ = 0
    
    dynamic var order_price_ = 0
    
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
    
    dynamic var days_ = 0
    
    dynamic var order_addr:String?
    
}
//预约记录
class AppointmentRequestModel: OrderRequestBaseModel {
    dynamic var last_id_ = 0
}

class AppointmentListModel: Object {
    let data_list_ = List<AppointmentInfoModel>()
    
}
class AppointmentInfoModel: Object {
    
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
    //    dynamic var service_time_:String?
    dynamic var service_type_ = 0
    dynamic var status_ = 0
    dynamic var to_head_:String?
    dynamic var to_name_:String?
    dynamic var to_user_ = 0
    dynamic var order_price_ = 0
    dynamic var order_id_ = 0
    dynamic var service_end_ = 0
    dynamic var service_start_ = 0
    dynamic var recommend_uid_:String?
}


//黑卡记录
class CenturionCardRecordRequestModel: Object {
    dynamic var uid_ = CurrentUser.uid_
}
class CenturionCardRecordListModel: Object {
    let blackcard_consume_record_ = List<CenturionCardRecordModel>()
    
}
class CenturionCardRecordModel: Object {
    
    dynamic var order_id_ = 0
    
    dynamic var order_time_ = 0
    
    dynamic var privilege_name_:String?
    
    dynamic var privilege_pic_:String?
    
    dynamic var privilege_price_ = 0
    
    dynamic var privilege_lv_ = 0
    
    dynamic var order_status_ = 0
    dynamic var order_type_ = 0
}
//推荐服务者列表
class AppointmentRecommendRequestModel: Object {
    dynamic var uid_str_:String?
}

class AppointmentRecommendListModel: Object{
   let recommend_guide_ = List<ReServantListModel>()
}

//服务详情
class InvoiceServiceModel: ServiceModel {
    
    dynamic var order_time_ = 0
    
    dynamic var nick_name_:String?
    
    dynamic var service_time_:String?
    
    var serviceType:String {
        return service_type_ == 1 ? "高端游" : "商务游"
    }
    
    private let _orderInfo = LinkingObjects(fromType: ServiceDetailModel.self, property: "service_list_").first
    var orderInfo:ServiceDetailModel {
        return _orderInfo!
    }
    
}

class InvoiceCenturionCardConsumerModel: CenturionCardRecordModel {
    
    dynamic var service_time_:String?
    
    var serviceType:String {
        return "黑卡消费"
    }
    
    var nickname:String {
        let formatter = NSNumberFormatter.init()
        formatter.roundingMode = .RoundHalfDown
        formatter.numberStyle = .SpellOutStyle
        let lvNum = NSNumber.init(long: privilege_lv_)
        let lvStr = formatter.stringFromNumber(lvNum)
        return "\(lvStr!)星黑卡消费"
    }
    
    private let _orderInfo = LinkingObjects(fromType: ServiceDetailModel.self, property: "black_list_").first
    var orderInfo:ServiceDetailModel {
        return _orderInfo!
    }
}

class InvoiceCenturionCardModel: CenturionCardRecordModel {
    
    dynamic var service_time_:String?
    
    var serviceType:String {
        return "黑卡购买"
    }
    
    var nickname:String {
        let formatter = NSNumberFormatter.init()
        formatter.roundingMode = .RoundHalfDown
        formatter.numberStyle = .SpellOutStyle
        let lvNum = NSNumber.init(long: privilege_lv_)
        let lvStr = formatter.stringFromNumber(lvNum)
        return "\(lvStr!)星黑卡"
    }
    
    private let _orderInfo = LinkingObjects(fromType: ServiceDetailModel.self, property: "black_buy_list_").first
    var orderInfo:ServiceDetailModel {
        return _orderInfo!
    }
}

class ServiceDetailRequestModel: Object {
    
    dynamic var oid_str_:String?
}

class ServiceDetailModel: Object {
    
    dynamic var oid_str_:String?
    
    let service_list_ = List<InvoiceServiceModel>()
    
    let black_list_ = List<InvoiceCenturionCardConsumerModel>()
    
    let black_buy_list_ = List<InvoiceCenturionCardModel>()
}
