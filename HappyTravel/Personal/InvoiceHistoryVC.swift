//
//  InvoiceHistoryVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/26.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import MJRefresh
import RealmSwift
class InvoiceHistoryVC:UIViewController {
    
    
    
    var tableView:UITableView?
    
    var historyData:Results<InvoiceHistoryInfo>?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    var last_invoice_id_ = 0

    
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "开票记录"
        
        initView()
        
    }
    
    /**
      注册通知监听
     */
    func registerNotify() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceHistoryVC.receivedData), name: NotifyDefine.InvoiceInfoReply, object: nil)
    }
    
    /**
     回调
     - parameter notify:
     */
    func receivedData(notify:NSNotification) {
        
        
        if header.state == MJRefreshState.Refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.Refreshing {
            footer.endRefreshing()
        }
    
        let realm = try! Realm()
        historyData = realm.objects(InvoiceHistoryInfo.self).sorted("invoice_time_", ascending: false)

        
        let lastOrderID = notify.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .NoMoreData
            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
            return
        }
        last_invoice_id_ = lastOrderID
        tableView?.reloadData()
        
    }
    
    /**
     
     初始化UI
     
     - returns: 
     */
    func initView() {
        
        tableView = UITableView(frame: CGRectZero, style: .Grouped)
        automaticallyAdjustsScrollViewInsets = false
        tableView?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = 60
        tableView?.separatorStyle = .None
        tableView?.registerClass(InvoiceHistoryCell.self, forCellReuseIdentifier: "InvoiceHistory")
        view.addSubview(tableView!)
        tableView?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(InvoiceHistoryVC.headerRefresh))
        tableView?.mj_header = header
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(InvoiceHistoryVC.footerRefresh))
        tableView?.mj_footer = footer
        registerNotify()
        header.beginRefreshing()

    }
    
    
    func headerRefresh() {
        SocketManager.sendData(.InvoiceInfoRequest, data: ["uid_": DataManager.currentUser!.uid,
                                                        "count_" : 10,
                                              "last_invoice_id_" : 0])
        
        
    }
    
    func footerRefresh() {
        SocketManager.sendData(.InvoiceInfoRequest, data: ["uid_": DataManager.currentUser!.uid,
                                                        "count_" : 10,
                                              "last_invoice_id_" : last_invoice_id_])

    }
    
}




// MARK: - TableView
extension InvoiceHistoryVC:UITableViewDataSource, UITableViewDelegate {

    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let histroyDetailVC = InvoiceHistoryDetailVC()
        let invoiceInfo = historyData![indexPath.row] as InvoiceHistoryInfo
        histroyDetailVC.invoice_id_ = invoiceInfo.invoice_id_
        navigationController?.pushViewController(histroyDetailVC, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        let count = historyData != nil ? historyData?.count : 0
        footer.hidden = count < 10 ? true : false
        return count!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("InvoiceHistory", forIndexPath: indexPath) as! InvoiceHistoryCell
        let last = indexPath.row == historyData!.count - 1 ? true : false

        cell.setupDatawith(historyData![indexPath.row], last: last)
        return cell
        
    }
}
