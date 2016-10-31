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
    
    var services:Results<InvoiceHistoryInfo>?
    
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
    }
    
}
extension InvoiceIncludeServiceVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = services != nil ? services?.count : 0
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("includeCell", forIndexPath: indexPath) as! InvoiceIncludeCell
        
        cell.setupData()
        return cell
        
    }
    
    
}