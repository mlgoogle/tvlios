//
//  ConsumeSocketAPI.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation

class ConsumeSocketAPI: SocketAPI{

    func requestInviteOrderLsit(model:HodometerRequestModel, rspModel:AnyClass = HodometerInfoModel.classForCoder(), complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ObtainTripRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(rspModel, listKey: "trip_list_"))
            }, error: error)
    }
    
    func requestAppointmentList(model:AppointmentRequestModel, rspModel:AnyClass = AppointmentInfoModel.classForCoder(), complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AppointmentRecordRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(rspModel, listKey: "data_list_"))
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
            complete?((response as? SocketJsonResponse)?.responseModels(UserInfoModel.classForCoder(), listKey: "recommend_guide_"))
            }, error: error)
    }
    
    func requestOrderDetail(model:OrderDetailRequsetModel,complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .AppointmentDetailRequest, model: model)
        startRequest(packet, complete: { (response) in
            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            complete?(jsonObject)
            
            }, error: error)
        
    }
    
    func requestComment(model:CommentDetaiRequsetModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CheckCommentDetail, model: model)
        startRequest(packet, complete: { (response) in
            let model = (response as? SocketJsonResponse)?.responseModel(OrderCommentModel.classForCoder())
            complete?(model)
            }, error: error)
    }
    
    func commentForOrder(model:CommentForOrderModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .EvaluateTripRequest, model: model)
        startRequest(packet, complete: { (response) in
            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            complete?(jsonObject)
            }, error: error)
        
    }
    
    func serviceDetail(model: ServiceDetailRequestModel, complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .ServiceDetailRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(ServiceDetailModel.classForCoder()))
            }, error: error)
    }
    //请求开票
    func drawBillInfo(model: DrawBillBaseInfo, complete: CompleteBlock?, error:ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .DrawBillRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(DrawBillModel.classForCoder()))
            }, error: error)
    }
    //请求开票历史记录
    func InvoiceHistoryInfo(model: InvoiceBaseInfo, complete: CompleteBlock?, error:ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .InvoiceInfoRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InvoiceHistoryModel.classForCoder()))
            }, error: error)
    }
    //请求发票详情
    func invoiceDetail(model: InvoiceDetailBaseInfo, complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .InvoiceDetailRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(InvoiceDetailModel.classForCoder()))
            }, error: error)
    }

}