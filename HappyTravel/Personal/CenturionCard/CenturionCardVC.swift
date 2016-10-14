//
//  CenturionCardVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/13.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import XCGLogger
import RealmSwift


class CenturionCardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "黑卡会员"
        
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func registerNotify() {
        
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(CenturionCardBaseInfoCell.self, forCellReuseIdentifier: "CenturionCardBaseInfoCell")
        table?.registerClass(CenturionCardLvSegmentCell.self, forCellReuseIdentifier: "CenturionCardLvSegmentCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CenturionCardBaseInfoCell", forIndexPath: indexPath) as! CenturionCardBaseInfoCell
            cell.setInfo(DataManager.currentUser)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CenturionCardLvSegmentCell", forIndexPath: indexPath) as! CenturionCardLvSegmentCell
            cell.setInfo(DataManager.currentUser, segmentIndex: 1)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? DistanceOfTravelCell {
            let identDetailVC = IdentDetailVC()
            identDetailVC.hodometerInfo = cell.curHodometerInfo!
            navigationController?.pushViewController(identDetailVC, animated: true)
        }
        
    }

}
