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
    
//    var historyData:Results<InvoiceHistoryInfo>?
    var historyModel:InvoiceHistoryModel?
    
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
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceHistoryVC.receivedData), name: NotifyDefine.InvoiceInfoReply, object: nil)
    }
    
    /**
     回调
     - parameter notify:
     */
//    func receivedData(notify:NSNotification) {
    
        
//        if header.state == MJRefreshState.Refreshing {
//            header.endRefreshing()
//        }
//        if footer.state == MJRefreshState.Refreshing {
//            footer.endRefreshing()
//        }
//    
//        let realm = try! Realm()
//        historyData = realm.objects(InvoiceHistoryInfo.self).sorted("invoice_time_", ascending: false)
//
//        
//        let lastOrderID = notify.userInfo!["lastOrderID"] as! Int
//        if lastOrderID == -1001 {
//            footer.state = .NoMoreData
//            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
//            return
//        }
//        last_invoice_id_ = lastOrderID
//        tableView?.reloadData()
        
//    }
    
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
        let model = InvoiceBaseInfo()
        model.uid_ = Int64(CurrentUser.uid_)
        model.count_ = 10
        model.last_invoice_id_ = 0
        InvoiceInfoRequest(model)
        
//        SocketManager.sendData(.InvoiceInfoRequest, data: ["uid_": CurrentUser.uid_,
//                                                        "count_" : 10,
//                                              "last_invoice_id_" : 0])
        
        
    }
    
    func footerRefresh() {
        let model = InvoiceBaseInfo()
        model.uid_ = Int64(CurrentUser.uid_)
        model.count_ = 10
        model.last_invoice_id_ = Int64(last_invoice_id_)
        InvoiceInfoRequest(model)
        
//        SocketManager.sendData(.InvoiceInfoRequest, data: ["uid_": CurrentUser.uid_,
//                                                        "count_" : 10,
//                                              "last_invoice_id_" : last_invoice_id_])

    }
    
    func InvoiceInfoRequest(model: InvoiceBaseInfo) {
        APIHelper.consumeAPI().InvoiceHistoryInfo(model, complete: { (response) in
            
            if let historyModel = response as? InvoiceHistoryModel {
                DataManager.insertData(historyModel)
                self.historyModel = historyModel
            }

            if self.header.state == MJRefreshState.Refreshing {
                self.header.endRefreshing()
            }
            if self.footer.state == MJRefreshState.Refreshing {
                self.footer.endRefreshing()
            }
            
//            let realm = try! Realm()
//            self.historyData = realm.objects(InvoiceHistoryInfo.self).sorted("invoice_time_", ascending: false)
            
            
            let lastOrderID = model.last_invoice_id_//notify.userInfo!["lastOrderID"] as! Int
            if lastOrderID == -1001 {
                self.footer.state = .NoMoreData
                self.footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
                return
            }
            self.last_invoice_id_ = Int(lastOrderID)
            self.tableView?.reloadData()

            }, error: { (err) in
        })
    }
    
}




// MARK: - TableView
extension InvoiceHistoryVC:UITableViewDataSource, UITableViewDelegate {

    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let histroyDetailVC = InvoiceHistoryDetailVC()
//        let invoiceInfo = historyData![indexPath.row] as InvoiceHistoryInfo
        let invoiceInfo = historyModel!.invoice_list_[indexPath.row] as InvoiceHistoryInfoModel
        histroyDetailVC.invoice_id_ = Int(invoiceInfo.invoice_id_)
        histroyDetailVC.invoice_status = Int(invoiceInfo.invoice_status_)
        navigationController?.pushViewController(histroyDetailVC, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
//        let count = historyData?.count ?? 0
        let count = historyModel?.invoice_list_.count ?? 0
        footer.hidden = count < 10 ? true : false
        return count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("InvoiceHistory", forIndexPath: indexPath) as! InvoiceHistoryCell
//        let last = indexPath.row == historyData!.count - 1 ? true : false
//        cell.setupDatawith(historyData![indexPath.row], last: last)

        let last = indexPath.row == historyModel!.invoice_list_.count - 1 ? true : false
        cell.setupDatawith(historyModel!.invoice_list_[indexPath.row], last: last)

        return cell
        
    }
}
