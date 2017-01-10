//
//  InvoiceIncludeServiceVC.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import RealmSwift
class InvoiceIncludeServiceVC: UIViewController {
    
    var tableView:UITableView?
    
    var services:ServiceDetailModel?
    var oid_str_:String!

    
    deinit {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "所含服务"
        
        initViews()
    }

    func initViews() {
        
        tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = 60
        tableView?.separatorStyle = .None
        tableView?.registerClass(InvoiceIncludeCell.self, forCellReuseIdentifier: "includeCell")
        view.addSubview(tableView!)
        tableView?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })

        let req = ServiceDetailRequestModel()
        req.oid_str_ = oid_str_
        APIHelper.consumeAPI().serviceDetail(req, complete: { [weak self](response) in
            if let model = response as? ServiceDetailModel {
                model.oid_str_ = self!.oid_str_
                self!.services = model
                self!.tableView?.reloadData()
            }
        }, error: nil)

    }
 
}
extension InvoiceIncludeServiceVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cnt = services?.service_list_.count ?? 0
        cnt += services?.black_list_.count ?? 0
        cnt += services?.black_buy_list_.count ?? 0
        return cnt
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("includeCell", forIndexPath: indexPath) as! InvoiceIncludeCell
        let serviceCnt = services?.service_list_.count ?? 0
        let blackListCnt = services?.black_list_.count ?? 0
        let buyListCnt = services?.black_buy_list_.count ?? 0
        let last = indexPath.row == (serviceCnt + blackListCnt + buyListCnt) - 1 ? true : false
        let service:Object?
        var type:String?
        if indexPath.row < serviceCnt {
            let tmp = services?.service_list_[indexPath.row]
            service = tmp
            type = tmp?.serviceType
        } else if indexPath.row < serviceCnt + blackListCnt {
            let tmp = services?.black_list_[indexPath.row]
            service = tmp
            type = tmp?.serviceType
        } else if indexPath.row < serviceCnt + blackListCnt + buyListCnt {
            let tmp = services?.black_buy_list_[indexPath.row]
            service = tmp
            type = tmp?.serviceType
        } else {
            service = Object()
        }
        cell.setupData(service, type: type, isLast:last)
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    
}