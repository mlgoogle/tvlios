//
//  ConsumeSocketAPI.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD


class ConsumeSocketAPI: SocketAPI{
    //请求邀约记录
    func requestInviteOrderLsit(model:HodometerRequestModel, rspModel:AnyClass = HodometerInfoModel.classForCoder(), complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .ObtainTripRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(rspModel, listKey: "trip_list_"))
            }, error: error)
    }
    //请求预约记录
    func requestAppointmentList(model:AppointmentRequestModel, rspModel:AnyClass = AppointmentInfoModel.classForCoder(), complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .AppointmentRecordRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(rspModel, listKey: "data_list_"))
            }, error: error)
    }
    //请求黑卡消费记录
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
    /**
     请求预约推荐服务者列表
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func requestAppointmentRecommendList(model:AppointmentRecommendRequestModel,complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .AppointmentRecommendRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModels(UserInfoModel.classForCoder(), listKey: "recommend_guide_"))
            }, error: error)
    }
    
    /**
     请求预约详情
     */
    func requestOrderDetail(model:OrderDetailRequsetModel,complete: CompleteBlock?, error: ErrorBlock?) {
        
        let packet = SocketDataPacket(opcode: .AppointmentDetailRequest, model: model)
        startRequest(packet, complete: { (response) in
            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            complete?(jsonObject)
            
            }, error: error)
        
    }
    /**
     请求订单评论
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func requestComment(model:CommentDetaiRequsetModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .CheckCommentDetail, model: model ,type: .Chat)
        startRequest(packet, complete: { (response) in
            var model = (response as? SocketJsonResponse)?.responseModel(OrderCommentModel.classForCoder()) as? OrderCommentModel
            if model!.service_score_ == 0 && model!.user_score_ == 0 && model!.remarks_ == nil {
                model = nil
            }
            complete?(model)
            }, error: error)
    }
    /**
     评论订单
     
     - parameter model:
     - parameter complete:
     - parameter error:
     */
    func commentForOrder(model:CommentForOrderModel,complete: CompleteBlock?, error: ErrorBlock?) {
        let packet = SocketDataPacket(opcode: .EvaluateTripRequest, model: model,type: .Chat)
        startRequest(packet, complete: { (response) in
            
            let jsonObject = (response as? SocketJsonResponse)?.responseJsonObject()
            SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 0.5, completion: { () in
                complete?(jsonObject)
            })
            
            }, error: error)
        
    }
    /**
     开票所含服务
     
     - parameter model:
     - parameter complete:
     - parameter error:    
     */
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
    //请求预约行程
    func appointmentTrip(model: AppointmentTripBaseInfo, complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .AppointmentRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(AppointmentTripModel.classForCoder()))
            }, error: error)
    }

    //请求预约、邀约付款
    func payForInvitation(model: PayForInvitationRequestModel, complete: CompleteBlock?, error: ErrorBlock?){
        let packet = SocketDataPacket(opcode: .PayForInvitationRequest, model: model)
        startRequest(packet, complete: { (response) in
            complete?((response as? SocketJsonResponse)?.responseModel(PayForInvitationModel.classForCoder()))
            }, error: error)
    }

}