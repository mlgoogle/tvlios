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
            complete?((response as? SocketJsonResponse)?.responseModel(HodometerListModel.classForCoder()))
            }, error: error)
    }
    static func requestAppointmentList(model:AppointmentRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AppointmentRecordRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(AppointmentListModel.classForCoder()))
            }, error: error)
    }
    static func requsetCenturionCardRecordList(model:CenturionCardRecordRequestModel, complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AppointmentRecordRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(CenturionCardRecordListModel.classForCoder()))
            }, error: error)
    }
}