//
//  ConsumeSocketAPI.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation

class ConsumeSocketAPI: SocketAPI{

    static func requestInviteOrderLsit(model:HodometerRequestModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ObtainTripRequest, model: model)
        startRequest(packet, complete: { (response) in
            
            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()

            if let tripList = jsonObject!["trip_list_"] as? Array<Dictionary<String, AnyObject>> {
                for trip in tripList {
                    let model = HodometerInfoModel(value: trip)
                    DataManager.insertData(model)
                }
                 complete?(true)
            }
            }, error: error)
    }
    static func requestAppointmentList(model:AppointmentRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AppointmentRecordRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(AppointmentListModel.classForCoder()))
            }, error: error)
    }
    static func requsetCenturionCardRecordList(model:CenturionCardRecordRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CenturionCardConsumedRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardRecordListModel.classForCoder()))
            }, error: error)
    }
    
    static func requestAppointmentRecommendList(model:AppointmentRecommendRequestModel,complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .AppointmentRecommendRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(AppointmentRecommendListModel.classForCoder()))
            }, error: error)
    }
}