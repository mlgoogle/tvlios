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
        NotificationCenter.default.removeObserver(self)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        title = "开票记录"
        
        initView()
        
    }
    
    /**
      注册通知监听
     */
    func registerNotify() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceHistoryVC.receivedData), name: NSNotification.Name(rawValue: NotifyDefine.InvoiceInfoReply), object: nil)
    }
    
    /**
     
     回调
     - parameter notify:
     */
    func receivedData(_ notify:Notification) {
        
        
        if header.state == MJRefreshState.refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.refreshing {
            footer.endRefreshing()
        }
    
        let realm = try! Realm()
        historyData = realm.objects(InvoiceHistoryInfo.self).sorted(byProperty: "invoice_time_", ascending: false)

        
        let lastOrderID = notify.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .noMoreData
            footer.setTitle("多乎哉 不多矣", for: .noMoreData)
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
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        automaticallyAdjustsScrollViewInsets = false
        tableView?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = 60
        tableView?.separatorStyle = .none
        tableView?.register(InvoiceHistoryCell.self, forCellReuseIdentifier: "InvoiceHistory")
        view.addSubview(tableView!)
        tableView?.snp_makeConstraints({ (make) in
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
        SocketManager.sendData(.invoiceInfoRequest, data: ["uid_": DataManager.currentUser!.uid,
                                                        "count_" : 10,
                                              "last_invoice_id_" : 0])
        
        
    }
    
    func footerRefresh() {
        SocketManager.sendData(.invoiceInfoRequest, data: ["uid_": DataManager.currentUser!.uid,
                                                        "count_" : 10,
                                              "last_invoice_id_" : last_invoice_id_])

    }
    
}




// MARK: - TableView
extension InvoiceHistoryVC:UITableViewDataSource, UITableViewDelegate {

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let histroyDetailVC = InvoiceHistoryDetailVC()
        let invoiceInfo = historyData![indexPath.row] as InvoiceHistoryInfo
        histroyDetailVC.invoice_id_ = invoiceInfo.invoice_id_
        navigationController?.pushViewController(histroyDetailVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        let count = historyData != nil ? historyData?.count : 0
        footer.isHidden = count! < 10 ? true : false
        return count!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceHistory", for: indexPath) as! InvoiceHistoryCell
        let last = indexPath.row == historyData!.count - 1 ? true : false

        cell.setupDatawith(historyData![indexPath.row], last: last)
        return cell
        
    }
}
