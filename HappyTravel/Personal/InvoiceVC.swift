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
    
    var orderID = 0
    var hotometers:Results<HodometerInfo>?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    var selectedOrderList:Dictionary<Int, HodometerInfo> = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "按行程开票"
        
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.obtainTripReply(_:)), name: NotifyDefine.ObtainTripReply, object: nil)
    }
    
    func obtainTripReply(notification: NSNotification) {
        if header.state == MJRefreshState.Refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.Refreshing {
            footer.endRefreshing()
        }
        
        hotometers = DataManager.getHodometerHistory()
        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .NoMoreData
            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
            return
        }
        orderID = lastOrderID
        table?.reloadData()
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
        commitBtn.addTarget(self, action: #selector(InvoiceVC.commitAction(_:)), forControlEvents: .TouchUpInside)
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
        
        header.setRefreshingTarget(self, refreshingAction: #selector(InvoiceVC.headerRefresh))
        table?.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(InvoiceVC.footerRefresh))
        table?.mj_footer = footer
    }
    
    func headerRefresh() {
        SocketManager.sendData(.ObtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
            "order_id_": 0,
            "count_": 10])
        
    }
    
    func footerRefresh() {
        SocketManager.sendData(.ObtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
            "order_id_": orderID,
            "count_": 10])
    }
    
    func commitAction(sender: UIButton) {
        XCGLogger.debug("\(self.selectedOrderList.keys)")
        if selectedOrderList.count == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "尚未选择开票行程", ForDuration: 1.5, completion: nil)
            return
        }
        let invoiceDetailVC = InvoiceDetailVC()
        invoiceDetailVC.selectedOrderList = selectedOrderList
        navigationController?.pushViewController(invoiceDetailVC, animated: true)
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = hotometers != nil ? hotometers!.count : 0
        footer.hidden = cnt < 10 ? true : false
        return cnt
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InvoiceCell", forIndexPath: indexPath) as! InvoiceCell
        let hodometer = hotometers![indexPath.row]
        let selectStatue = selectedOrderList.indexForKey(hodometer.order_id_) == nil ? false : true
        let last = indexPath.row == self.hotometers!.count - 1 ? true : false
        cell.setInfo(hodometer, selected: selectStatue, last: last)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? InvoiceCell {
            if cell.selectAction() == true {
                selectedOrderList[cell.hodometerInfo!.order_id_] = cell.hodometerInfo
            } else {
                selectedOrderList.removeValueForKey(cell.hodometerInfo!.order_id_)
            }
        }
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "7月"
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
//    
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.001
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
}
