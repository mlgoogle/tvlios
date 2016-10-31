//
//  InvoiceHistoryDetailVC.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class InvoiceHistoryDetailVC: UIViewController {
    
    var invoice_id_ = 0
    
    var tableView:UITableView?
    var invoiceInfo:InvoiceInfo?
    var rows:Array = [5 , 3, 1]
    var titles =  [["发票抬头", "收件人", "联系电话", "所在区域", "收件地址"],
                   ["发票类型","发票金额","申请时间"],
                   ["所含服务"]]
    
    
    
    var infoArray = [["杭州云巅科技有限公司", "标标", "13569365932", "杭州市", "收件地址"],
                     ["发票类型","发票金额","申请时间"],
                     ["所含服务"]]
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        regitserNotification()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "开票详情"
        
        
        initViews()
        SocketManager.sendData(.InvoiceDetailRequest, data: ["invoice_id_" : invoice_id_])
    }
    
    func initViews() {
        tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .None
        tableView?.estimatedRowHeight = 70
        tableView?.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView!)
        tableView?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
        tableView?.tableHeaderView = InvouiceHistoryDetailHeader.init(frame: CGRectMake(0, 0,  UIScreen.mainScreen().bounds.size.width, 65))
        tableView?.registerClass(InvoiceHistoryDetailCustomCell.self, forCellReuseIdentifier: "detailCustomCell")
        tableView?.registerClass(InvoiceHistoryDetailNormalCell.self, forCellReuseIdentifier: "detailNormalCell")
    }
    
    func regitserNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceHistoryDetailVC.receivedData(_:)), name: NotifyDefine.InvoiceDetailReply, object: nil)
    }
    
    
    func receivedData(notification:NSNotification) {
        
        let dict = notification.userInfo!["data"]
        
        
    }
    
}


extension InvoiceHistoryDetailVC:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 70
        }
        
        return 44
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("detailCustomCell", forIndexPath: indexPath) as! InvoiceHistoryDetailCustomCell
            
            
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("detailNormalCell", forIndexPath: indexPath) as! InvoiceHistoryDetailNormalCell
        

        cell.setTitleLabelText(titles[indexPath.section][indexPath.row])

        /**
         这里填充假数据，等接口更新
         */
        cell.setInfoLabelText(infoArray[indexPath.section][indexPath.row])
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {
            let includeVC = InvoiceIncludeServiceVC()
            
            navigationController?.pushViewController(includeVC, animated: true)
        }
    }
}
