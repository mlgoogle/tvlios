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


class CenturionCardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CenturionCardLvSelCellDelegate, CenturionCardServicesCellDelegate {
    
    var table:UITableView?
    
    var callServantBtn:UIButton?
    
    var serviceTel = "10086"
    
    var services:Results<CenturionCardServiceInfo>? = DataManager.getCenturionCardServiceWithLV(DataManager.currentUser!.centurionCardLv)
    
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
        table?.backgroundColor = UIColor.whiteColor()
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(CenturionCardBaseInfoCell.self, forCellReuseIdentifier: "CenturionCardBaseInfoCell")
        table?.registerClass(CenturionCardServicesCell.self, forCellReuseIdentifier: "CenturionCardServicesCell")
        table?.registerClass(CenturionCardLvSelCell.self, forCellReuseIdentifier: "CenturionCardLvSelCell")
        view.addSubview(table!)
        
        callServantBtn = UIButton()
        callServantBtn?.setTitle("联系服务管家", forState: .Normal)
        callServantBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        callServantBtn?.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), forState: .Normal)
        callServantBtn?.addTarget(self, action: #selector(CenturionCardVC.callSrevant), forControlEvents: .TouchUpInside)
        view.addSubview(callServantBtn!)
        callServantBtn?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(DataManager.currentUser!.centurionCardLv > 0 ? 65 : 0.01)
            
        })
        
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(callServantBtn!.snp_top)
        })
    }
    
    func callSrevant() {
        let alert = UIAlertController.init(title: "呼叫", message: serviceTel, preferredStyle: .Alert)
        let ensure = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.serviceTel)")!)
        })
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(ensure)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CenturionCardBaseInfoCell", forIndexPath: indexPath) as! CenturionCardBaseInfoCell
            cell.setInfo(DataManager.currentUser)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CenturionCardLvSelCell", forIndexPath: indexPath) as! CenturionCardLvSelCell
            cell.delegate = self
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CenturionCardServicesCell", forIndexPath: indexPath) as! CenturionCardServicesCell
            cell.delegate = self
            cell.setInfo(services)
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - CenturionCardLvSelCellDelegate
    func selectedAction(index: Int) {
        services = DataManager.getCenturionCardServiceWithLV(index + 1)
        table?.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 2, inSection: 0)], withRowAnimation: .Fade)
        callServantBtn?.snp_remakeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(index < DataManager.currentUser!.centurionCardLv ? 65 : 0.01)
            
        })
    }
    
    // MARK: - CenturionCardServicesCellDelegate
    func serviceTouched(service: CenturionCardServiceInfo) {
        let detailVC = CenturionCardDetailVC()
        detailVC.service = service
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}