//
//  ConsumeSocketAPI.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation

class ConsumeSocketAPI: SocketAPI{

     func requestInviteOrderLsit(model:HodometerRequestModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ObtainTripRequest, model: model)
        startRequest(packet, complete: { (response) in
            var lastid = 0

            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            if let tripList = jsonObject!["trip_list_"] as? Array<Dictionary<String, AnyObject>> {
                for trip in tripList {
                    let model = HodometerInfoModel(value: trip)
                    lastid = model.order_id_
                    DataManager.insertData(model)
                }
                 complete?(lastid)
            }
            }, error: error)
    }
     func requestAppointmentList(model:AppointmentRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AppointmentRecordRequest, model: model)
        startRequest(packet, complete: { (response) in
            var lastid = 0

            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            if let data_list_ =  jsonObject!["data_list_"] as? Array<Dictionary<String, AnyObject>> {

                for record in data_list_ {
                    let model = AppointmentInfoModel(value: record)
                    lastid = model.appointment_id_
                    DataManager.insertData(model)
                }
                complete?(lastid)
            }
            }, error: error)
    }
     func requsetCenturionCardRecordList(model:CenturionCardRecordRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionCardConsumedRequest, model: model)
        startRequest(packet, complete: { (response) in
            var lastid = 0
            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            if let data_list_ =  jsonObject!["blackcard_consume_record_"] as? Array<Dictionary<String, AnyObject>> {
                for record in data_list_ {
                    let model = CenturionCardRecordModel(value: record)
                    lastid = model.order_id_
                    DataManager.insertData(model)
                }
                complete?(lastid)
            }
            }, error: error)
    }
    
     func requestAppointmentRecommendList(model:AppointmentRecommendRequestModel,complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .AppointmentRecommendRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(AppointmentRecommendListModel.classForCoder()))
            }, error: error)
    }
}