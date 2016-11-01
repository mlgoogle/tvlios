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
    
    var services:Array<InvoiceServiceInfo> = Array()
    
    var oid_str_:String!

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        
        SocketManager.sendData(.ServiceDetailRequest, data: ["oid_str_" : oid_str_])
        registerNotifaction()
    }
    func registerNotifaction() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceIncludeServiceVC.receivedData(_:)), name: NotifyDefine.ServiceDetailReply, object: nil)
    }
    
    
    func receivedData(notifcation:NSNotification) {
        
        if  let dict = notifcation.userInfo!["data"] {
            if let serviceList  = dict["service_list"] as? Array<Dictionary<String, AnyObject>> {
                
                for service in serviceList {
                    let serviceInfo = InvoiceServiceInfo(value: service)
                    services.append(serviceInfo)
                }
                tableView?.reloadData()
            }
        }
        
    }
    
}
extension InvoiceIncludeServiceVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return services.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("includeCell", forIndexPath: indexPath) as! InvoiceIncludeCell
        
        let last = indexPath.row == services.count - 1 ? true : false
        cell.setupData(services[indexPath.row], isLast:last)
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    
}