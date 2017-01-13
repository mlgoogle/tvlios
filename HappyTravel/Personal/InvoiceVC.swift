//
//  InvoiceVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
import MJRefresh
import XCGLogger
import SVProgressHUD

class InvoiceVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var segmentSC:UISegmentedControl?
    var table:UITableView?
    var messageInfo:Array<UserInfo>? = []
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    var orderID = 0
    var lastID = 0
    var selectedOrderList = List<TicketModel>()
    var totalInfos:Results<TicketModel>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = NSHomeDirectory()
        XCGLogger.debug(path)
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "按行程开票"
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectedOrderList.removeAll()
        registerNotify()
        
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(obtainTripReply(_:)), name: NotifyDefine.ObtainTripReply, object: nil)
        
    }
    
    func obtainTripReply(notification: NSNotification) {
//        if header.state == MJRefreshState.Refreshing {
//            header.endRefreshing()
//        }
//        if footer.state == MJRefreshState.Refreshing {
//            footer.endRefreshing()
//        }
//        
//        hotometers = DataManager.getHodometerHistory()
//        for info in hotometers! {
//            DataManager.insertOpenTicketWithHodometerInfo(info)
//        }
//        totalInfos = DataManager.getOpenTicketsInfo()
//        table?.reloadData()
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(InvoiceCell.self, forCellReuseIdentifier: "InvoiceCell")
        view.addSubview(table!)
        
        let commitBtn = UIButton()
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), forState: .Normal)
        commitBtn.setTitle("提交", forState: .Normal)
        commitBtn.addTarget(self, action: #selector(commitAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
        }
        
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(commitBtn.snp_top)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        table?.mj_header = header
//        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
//        table?.mj_footer = footer
    }
    
    func headerRefresh() {
        DataManager.removeData(InvoiceHodometerInfoModel.self)
        DataManager.removeData(InvoiceAppointmentInfoModel.self)
        DataManager.removeData(TicketModel.self)
        getHodometerInfos()
    }
    
    func getHodometerInfos() {
        let req = HodometerRequestModel()
        req.order_id_ = orderID == 0 ? 0 : orderID
        APIHelper.consumeAPI().requestInviteOrderLsit(req, rspModel: InvoiceHodometerInfoModel.classForCoder(), complete: { [weak self](response) in
            if let models = response as? [InvoiceHodometerInfoModel] {
                for model in models {
                    DataManager.insertData(model)
                    if model.status_ == OrderStatus.Completed.rawValue {
                        let ticket = TicketModel()
                        ticket.hodometer_ = model
                        ticket.order_id_ = model.order_id_
                        DataManager.insertData(ticket)
                    }
                }
                self!.orderID = models.last!.order_id_
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.1)), dispatch_get_main_queue(), { () in
                    self!.getHodometerInfos()
                })
            } else {
                self?.orderID = 0
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.1)), dispatch_get_main_queue(), { () in
                    self?.getAppointmentInfos()
                })
            }
        }) { [weak self](error) in
            self?.orderID = 0
        }
    }
    
    func getAppointmentInfos() {
        let req = AppointmentRequestModel()
        req.last_id_ = lastID == 0 ? 0 : lastID
        APIHelper.consumeAPI().requestAppointmentList(req, rspModel: InvoiceAppointmentInfoModel.classForCoder(), complete: { [weak self](response) in
            if let models = response as? [InvoiceAppointmentInfoModel] {
                for model in models {
                    DataManager.insertData(model)
                    if model.status_ == OrderStatus.Completed.rawValue {
                        let ticket = TicketModel()
                        ticket.appointment_ = model
                        ticket.order_id_ = model.appointment_id_
                        DataManager.insertData(ticket)
                    }
                }
                self!.lastID = models.last!.appointment_id_
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.1)), dispatch_get_main_queue(), { () in
                    self!.getAppointmentInfos()
                })
            } else {
                self!.lastID = 0
                self!.noMoreData()
            }
        }) { [weak self](error) in
            self!.lastID = 0
            self!.noMoreData()
        }
    }
    
    func noMoreData() {
        totalInfos = DataManager.getData(TicketModel.self)
        endRefresh()
        footer.state = .NoMoreData
        footer.setTitle("没有更多信息", forState: .NoMoreData)
    }
    
    func footerRefresh() {
//        SocketManager.sendData(.ObtainTripRequest, data: ["uid_": CurrentUser.uid_,
//            "order_id_": orderID,
//            "count_": 10])
//        SocketManager.sendData(.CenturionCardConsumedRequest, data: ["uid_": CurrentUser.uid_])
    }
    
    
    func handleCenturionCardRequest(isRefresh:Bool) {
//        footer.state = .NoMoreData
//        footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
        APIHelper.consumeAPI().requsetCenturionCardRecordList(CenturionCardRecordRequestModel(), complete: { (response) in
            self.endRefresh()
        }) { (error) in
            
        }
    }
    func handleInviteOrderRequest(isRefresh:Bool) {
        let model = HodometerRequestModel()
        model.order_id_ = isRefresh ? 0 : orderID
        APIHelper.consumeAPI().requestInviteOrderLsit(model, complete: { (response) in
            self.orderID = response as! Int
            self.endRefresh()
        }) { (error) in
        }
    }
    
    func endRefresh() {
        if header.state == .Refreshing {
            header.endRefreshing()
        }
        if footer.state == .Refreshing {
            footer.endRefreshing()
        }
        table?.reloadData()
    }
    func commitAction(sender: UIButton) {
//        let realm = try! Realm()
//        selectedOrderList = realm.objects(OpenTicketInfo.self).filter("selected = true")
        if selectedOrderList.count == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "尚未选择开票行程", ForDuration: 1.5, completion: nil)
            return
        }
        let invoiceDetailVC = InvoiceDetailVC()
        invoiceDetailVC.selectedOrderList = selectedOrderList
        navigationController?.pushViewController(invoiceDetailVC, animated: true)
    }
    
    // MARK: - UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalInfos?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InvoiceCell", forIndexPath: indexPath) as! InvoiceCell
        let info = totalInfos![indexPath.row]
        info.selected = selectedOrderList.contains(info)
        cell.update(info)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let info = totalInfos![indexPath.row]
        if selectedOrderList.contains(info) {
            selectedOrderList.removeAtIndex(selectedOrderList.indexOf(info)!)
        } else {
            selectedOrderList.append(info)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
    }
    
}
