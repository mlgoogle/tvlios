//
//  InvoiceHistoryDetailVC.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class InvoiceHistoryDetailVC: UIViewController {

    var tableView:UITableView?
    var invoiceInfo:InvoiceInfo?
    var rows:Array = [5 , 3, 1]
    var titles =  [["发票抬头", "收件人", "联系电话", "所在区域", "收件地址"],
                   ["发票类型","发票金额","申请时间"],
                   ["所含服务"]]
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "开票详情"
        
        tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "historyDetailCell")
        view.addSubview(tableView!)
        tableView?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
//        tableView?.tableHeaderView = InvouiceHistoryDetailHeader(frame: <#T##CGRect#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension InvoiceHistoryDetailVC:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section]
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
        
            
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("historyDetailCell", forIndexPath: indexPath)
        cell.textLabel?.text = titles[indexPath.section][indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        cell.textLabel?.textColor = UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
        return cell

    }
    
}
