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
    var consumes:Results<CenturionCardConsumedInfo>?
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    var selectedOrderList:Results<OpenTicketInfo>?
    var totalInfos:Results<OpenTicketInfo>? {
        didSet{
            if totalInfos == nil {
                return
            }
            table?.mj_footer.isHidden =  totalInfos!.count <= 10
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = NSHomeDirectory()
        XCGLogger.debug(path)
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "按行程开票"
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        header.perform(#selector(MJRefreshHeader.beginRefreshing), with: nil, afterDelay: 0.5)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceVC.obtainTripReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ObtainTripReply), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceVC.centurionCardConsumedReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.CenturionCardConsumedReply), object: nil)
    }
    
    func obtainTripReply(_ notification: Notification) {
        if header.state == MJRefreshState.refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.refreshing {
            footer.endRefreshing()
        }
        
        hotometers = DataManager.getHodometerHistory()
        for info in hotometers! {
            DataManager.insertOpenTicketWithHodometerInfo(info)
        }
        totalInfos = DataManager.getOpenTicketsInfo()
        table?.reloadData()
    }
    
    func centurionCardConsumedReply(_ notification: Notification)  {
        if header.state == MJRefreshState.refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.refreshing {
            footer.endRefreshing()
        }
        consumes = DataManager.getCenturionCardConsumed()
        for info in consumes! {
            DataManager.insertOpenTicketWithConsumedInfo(info)
        }
        totalInfos = DataManager.getOpenTicketsInfo()
        table?.reloadData()
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .none
        table?.register(InvoiceCell.self, forCellReuseIdentifier: "InvoiceCell")
        view.addSubview(table!)
        
        let commitBtn = UIButton()
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), for: UIControlState())
        commitBtn.setTitle("提交", for: UIControlState())
        commitBtn.addTarget(self, action: #selector(InvoiceVC.commitAction(_:)), for: .touchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
        }
        
        table?.snp_makeConstraints({ (make) in
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
        SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
            "order_id_": 0,
            "count_": 10])
        SocketManager.sendData(.centurionCardConsumedRequest, data: ["uid_": DataManager.currentUser!.uid])
    }
    
    func footerRefresh() {
        SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
            "order_id_": orderID,
            "count_": 10])
        SocketManager.sendData(.centurionCardConsumedRequest, data: ["uid_": DataManager.currentUser!.uid])
    }
    
    func commitAction(_ sender: UIButton) {
        let realm = try! Realm()
        selectedOrderList = realm.objects(OpenTicketInfo.self).filter("selected = true")
        if selectedOrderList!.count == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "尚未选择开票行程", ForDuration: 1.5, completion: nil)
            return
        }
        let invoiceDetailVC = InvoiceDetailVC()
        invoiceDetailVC.selectedOrderList = selectedOrderList
        navigationController?.pushViewController(invoiceDetailVC, animated: true)
    }
    
    // MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = totalInfos != nil ?  totalInfos?.count :0
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceCell", for: indexPath) as! InvoiceCell
        let info = totalInfos![indexPath.row]
        cell.info = info
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = totalInfos![indexPath.row]
        let realm = try! Realm()
        try! realm.write({
            info.selected = !info.selected
        })
        tableView.reloadData()
        
    }
    
    
}
