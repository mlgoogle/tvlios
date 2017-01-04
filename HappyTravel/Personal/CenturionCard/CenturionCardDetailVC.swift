//
//  CenturionCardDetailVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/20.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
class CenturionCardDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table:UITableView?
    
    let tags = ["headView": 1001,
                "titleLab": 1002,
                "descLab": 1003,
                "callServantBtn": 1004]
    
    var serviceTel = "0571-87611687"
    
    var service:CenturionCardServiceInfo?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "服务详情"
        
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
    func receivedData(notifation:NSNotification) {
        
        let dict = notifation.userInfo!["data"] as? [String: AnyObject]
        
        if let errorCode = dict!["error_"] {
            SVProgressHUD.showWainningMessage(WainningMessage: errorCode as! Int == -1040 ? "当前没有在线服务管家" : "未知错误：\(errorCode)", ForDuration: 1.5, completion: nil)
        } else {
            let userInfo = UserInfo()
            
            userInfo.setInfo(.Other, info: dict)
            
            DataManager.updateUserInfo(userInfo)
            let chatVC = ChatVC()
            chatVC.servantInfo = userInfo
            navigationController?.pushViewController(chatVC, animated: true)
            
        }
        
    }
    func registerNotify() {
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CenturionCardDetailVC.receivedData), name: NotifyDefine.ServersManInfoReply, object: nil)
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        table?.separatorStyle = .None
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return headViewCell(tableView, indexPath: indexPath)
        } else if indexPath.section == 1 || indexPath.section == 2 {
            return descCell(tableView, indexPath: indexPath)
        } else if indexPath.section == 3 {
            return callServantCell(tableView, indexPath: indexPath)
        }
        
        return UITableViewCell()
    }
    
    func headViewCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("HeadViewCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.selectionStyle = .None
        }
        
        var headView = cell?.contentView.viewWithTag(tags["headView"]!) as? UIImageView
        if headView == nil {
            headView = UIImageView()
            headView?.tag = tags["headView"]!
            cell?.contentView.addSubview(headView!)
            headView?.snp_makeConstraints(closure: { (make) in
                make.edges.equalTo(cell!.contentView)
                make.width.height.equalTo(210)
            })
        }
        headView?.image = UIImage.init(named: "bg-card-detail")
//        headView?.kf_setImageWithURL(NSURL(string: service?.privilege_bg_! == nil ? "" : service!.privilege_bg_!), placeholderImage: UIImage.init(named: "bg-card-detail"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        
        return cell!
    }
    
    func descCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DescCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.selectionStyle = .None
        }
        
        var title = cell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel
        if title == nil {
            title = UILabel()
            title?.tag = tags["titleLab"]!
            title?.backgroundColor = UIColor.clearColor()
            title?.font = UIFont.systemFontOfSize(S15)
            title?.textColor = UIColor.blackColor()
            cell?.contentView.addSubview(title!)
            title?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(15)
                make.top.equalTo(cell!.contentView).offset(15)
                make.right.equalTo(cell!.contentView).offset(-15)
            })
        }
        title?.text = indexPath.section == 1 ? service?.privilege_name_! : "服务亮点"
        
        var descLab = cell?.contentView.viewWithTag(tags["descLab"]!) as? UILabel
        if descLab == nil {
            descLab = UILabel()
            descLab?.tag = tags["descLab"]!
            descLab?.backgroundColor = UIColor.clearColor()
            descLab?.font = UIFont.systemFontOfSize(S13)
            descLab?.textColor = UIColor.grayColor()
            descLab?.numberOfLines = 0
            cell?.contentView.addSubview(descLab!)
            descLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(15)
                make.top.equalTo(title!.snp_bottom).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-15)
                make.right.equalTo(cell!.contentView).offset(-15)
            })
        }
        descLab?.text = indexPath.section == 1 ? service?.privilege_summary_! : service?.privilege_details_!

        return cell!
    }
    
    func callServantCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DescCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.selectionStyle = .None
            cell?.backgroundColor = UIColor.clearColor()
            cell?.contentView.backgroundColor = UIColor.clearColor()
        }
        
        let title = service?.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ? "联系服务管家" : "购买此服务"
        var callServantBtn = cell?.contentView.viewWithTag(tags["callServantBtn"]!) as? UIButton
        if callServantBtn == nil {
            callServantBtn = UIButton()
            callServantBtn?.tag = tags["callServantBtn"]!
            callServantBtn?.backgroundColor = UIColor.whiteColor()
            callServantBtn?.setTitle(title, forState: .Normal)
            callServantBtn?.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), forState: .Normal)
            callServantBtn?.layer.masksToBounds = true
            callServantBtn?.layer.cornerRadius = 5
            callServantBtn?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
            callServantBtn?.layer.borderWidth = 1
            callServantBtn?.addTarget(self, action: #selector(CenturionCardDetailVC.callSrevant), forControlEvents: .TouchUpInside)
            cell?.contentView.addSubview(callServantBtn!)
            callServantBtn?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(cell!.contentView)
                make.top.equalTo(cell!.contentView).offset(60)
                make.bottom.equalTo(cell!.contentView).offset(-20)
                make.width.equalTo(120)
                make.height.equalTo(40)
                
            })
        }
        callServantBtn?.hidden = service?.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ? false : true

        return cell!
    }
    
    func callSrevant() {
//        let userInfo = UserInfo()
//        userInfo.uid = 50
//        userInfo.nickname = "优悦金牌客服"
//        let chatVC = ChatVC()
//        chatVC.servantInfo = userInfo
//        navigationController?.pushViewController(chatVC, animated: true)
        
        if service?.privilege_lv_ <= DataManager.currentUser!.centurionCardLv {
            SocketManager.sendData(.ServersManInfoRequest, data: nil)
            
        } else {
            
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
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

