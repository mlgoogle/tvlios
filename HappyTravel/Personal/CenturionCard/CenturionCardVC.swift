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
import SVProgressHUD

class CenturionCardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CenturionCardLvSelCellDelegate, CenturionCardServicesCellDelegate {
    
    var table:UITableView?
    
    var callServantBtn:UIButton?
    
    var serviceTel = "10086"
    
    var services:Results<CenturionCardServiceInfo>?

    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "黑卡会员"
        
        var lv = DataManager.currentUser!.centurionCardLv
        if lv == 0 {
            lv += 1
        }
        services = DataManager.getCenturionCardServiceWithLV(lv)
        SocketManager.sendData(.CenturionCardInfoRequest, data: nil)
        SocketManager.sendData(.CenturionCardInfoRequest, data: nil) { [weak self](result) in
            if let strongSelf = self{
                strongSelf.table?.reloadData()
            }
        }
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CenturionCardVC.receivedData), name: NotifyDefine.ServersManInfoReply, object: nil)
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.whiteColor()
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.separatorStyle = .None
        table?.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
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
        callServantBtn?.hidden = DataManager.currentUser!.centurionCardLv <= 0
        callServantBtn?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(65)
            
        })
    
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(0)
        })
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "share"), style: .Plain, target: self, action: #selector(shareToOthers))
    }
    
    func shareToOthers() {
        if (DataManager.currentUser?.centurionCardLv)! == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "只有开通的帐号才能进行分享！！！", ForDuration: 1, completion: nil)
            return
        }
        
        let shareController = ShareViewController()
        shareController.modalPresentationStyle = .Custom
        shareController.shareImage = shareImage()
        presentViewController(shareController, animated: true
            , completion: nil)
    }
    
    func callSrevant() {
        SocketManager.sendData(.ServersManInfoRequest, data: nil)
//        let alert = UIAlertController.init(title: "呼叫", message: serviceTel, preferredStyle: .Alert)
//        let ensure = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
//            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.serviceTel)")!)
//        })
//        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
//            
//        })
//        alert.addAction(ensure)
//        alert.addAction(cancel)
//        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? AtapteWidthValue(209) : (indexPath.row == 1 ? AtapteWidthValue(70) : AtapteWidthValue(500))
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
        if selectedIndex == index {
            return
        }
        selectedIndex = index
        services = DataManager.getCenturionCardServiceWithLV(index + 1)
        table?.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 2, inSection: 0)], withRowAnimation: .Fade)
        callServantBtn?.hidden = index >= DataManager.currentUser!.centurionCardLv
    }
    
    // MARK: - CenturionCardServicesCellDelegate
    func serviceTouched(service: CenturionCardServiceInfo) {
        let detailVC = CenturionCardDetailVC()
        detailVC.service = service
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func moneyIsTooLess() {
        let alert = UIAlertController.init(title: "余额不足", message: "\n请前往充值", preferredStyle: .Alert)
        
        let ok = UIAlertAction.init(title: "前往充值", style: .Default, handler: { (action: UIAlertAction) in
            let rechargeVC = RechargeVC()
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func buyNowButtonTouched() {
        if selectedIndex == 3 {
            let alert = UIAlertController.init(title: "购买提示", message: "对不起，四星会员仅支持内部邀请！", preferredStyle: .Alert)
            let ok = UIAlertAction.init(title: "好的", style: .Default, handler: nil)
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let curLv = DataManager.currentUser?.centurionCardLv
        if curLv <= 0 {
            UIApplication.sharedApplication().openURL(NSURL.init(string: "http://baidu.com")!)
            return
        }
        
        if curLv > 0 {
            let price = 1000
            let msg = "\n您即将预支付人民币:\(Double(price)/100)元"
            let alert = UIAlertController.init(title: "付款确认", message: msg, preferredStyle: .Alert)
            
            alert.addTextFieldWithConfigurationHandler({ (textField) in
                textField.placeholder = "请输入密码"
                textField.secureTextEntry = true
            })
            
            let ok = UIAlertAction.init(title: "确认付款", style: .Default, handler: { [weak self] (action) in
                let weakSelf = self
                let passwd = alert.textFields?.first?.text
                /**
                 *  密码为空
                 */
                if passwd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                    SVProgressHUD.showErrorMessage(ErrorMessage: "请输入密码", ForDuration: 1, completion: nil)
                    return
                }
                /**
                 *  密码错误
                 */
                if let localPasswd = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.Passwd) as? String {
                    if passwd != localPasswd {
                        SVProgressHUD.showErrorMessage(ErrorMessage: "密码输入错误，请重新输入", ForDuration: 1, completion: nil)
                        return
                    }
                    
                }
                /**
                 *  余额不足
                 */
                if DataManager.currentUser?.cash < price {
                    weakSelf!.moneyIsTooLess()
                    return
                }
                /**
                 *  请求购买
                 */
                let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)!,
                    "order_id_": "",
                    "passwd_": passwd!]
                SocketManager.sendData(.UpCenturionCardLvRequest, data: dict, result: { (result) in
                    weakSelf!.viewDidLoad()
                })
        
                
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func shareImage()-> UIImage  {
        table!.frame =  CGRect.init(origin: CGPointZero, size: table!.contentSize)
        table!.setContentOffset(CGPointZero, animated: false)
        table!.reloadData()
        UIGraphicsBeginImageContext(table!.contentSize)
        UIGraphicsBeginImageContextWithOptions(table!.contentSize, true, table!.layer.contentsScale)
	    let context = UIGraphicsGetCurrentContext()
	    table!.layer.renderInContext(context!)
	    let img = UIGraphicsGetImageFromCurrentImageContext()
	    UIGraphicsEndImageContext()
	    return img;
    }
    
}
