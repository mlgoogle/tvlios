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
    
    var services:Results<InvoiceServiceInfo>?
    var oid_str_:String!

    
    deinit {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "所含服务"
        
        initViews()
    }

    func initViews() {
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = 60
        tableView?.separatorStyle = .none
        tableView?.register(InvoiceIncludeCell.self, forCellReuseIdentifier: "includeCell")
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })

        SocketManager.sendData(.serviceDetailRequest, data: ["oid_str_" : oid_str_]) { [weak self](result) in
            if let strongSelf = self{
                if  let dict = result["data"] {
                    if let serviceList  = dict["service_list"] as? Array<Dictionary<String, AnyObject>> {
                        
                        for var service in serviceList {
                            service["oid_str_"] = strongSelf.oid_str_
                            let serviceInfo = InvoiceServiceInfo()
                            serviceInfo.setInfoWithCommenInvoice(service)
                            DataManager.insertInvoiceServiceInfo(serviceInfo)
                        }
                    }
                    
                    if let serviceList  = dict["black_list"] as? Array<Dictionary<String, AnyObject>> {
                        
                        for var service in serviceList {
                            service["oid_str_"] = strongSelf.oid_str_
                            let serviceInfo = InvoiceServiceInfo()
                            serviceInfo.setInfoWithBlackCardInvoice(service)
                            DataManager.insertInvoiceServiceInfo(serviceInfo)
                        }
                    }
                    
                    let realm = try! Realm()
                    strongSelf.services = realm.objects(InvoiceServiceInfo.self).filter("oid_str_ == \"\(strongSelf.oid_str_)\"").sorted("order_time_", ascending: true)
                    strongSelf.tableView?.reloadData()
                }
            }
        }
    }
 

    
}
extension InvoiceIncludeServiceVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return services == nil ? 0 : services!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "includeCell", for: indexPath) as! InvoiceIncludeCell
        
        let last = indexPath.row == services!.count - 1 ? true : false
        cell.setupData(services![indexPath.row], isLast:last)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    
}
