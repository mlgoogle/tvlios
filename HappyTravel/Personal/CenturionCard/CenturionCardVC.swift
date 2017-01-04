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
    
    var buyVIPView:UIView?
    
    var priceLab:UILabel?
    
    var serviceTel = "0571-87611687"
    
    var services:Results<CenturionCardServiceInfo>?

    var startTime = 0.0
    
    var selectedIndex = 0
    weak var lvContentCollectionView:UICollectionView?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.automaticallyAdjustsScrollViewInsets
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "黑卡会员"
        
        var lv = DataManager.currentUser!.centurionCardLv
        if lv == 0 {
            lv += 1
        }
        services = DataManager.getCenturionCardServiceWithLV(lv)
        
        SocketManager.sendData(.CenturionCardInfoRequest, data: nil)
        SocketManager.sendData(.CenturionVIPPriceRequest, data: nil)
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
        startTime = NSDate().timeIntervalSinceNow
        
        SocketManager.sendData(.UserCenturionCardInfoRequest, data: ["uid_": DataManager.currentUser!.uid])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let endTime = NSDate().timeIntervalSinceNow
        
        let timeCount = endTime - startTime
        MobClick.event(CommonDefine.BuriedPoint.vippage, durations:Int32(timeCount))
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
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
        
        createGetCenturionCardVIPView()
    
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(0)
        })
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "share"), style: .Plain, target: self, action: #selector(shareToOthers))
    }
    
    func createGetCenturionCardVIPView() {
        buyVIPView = UIView()
        buyVIPView?.backgroundColor = UIColor.whiteColor()
        buyVIPView?.userInteractionEnabled = true
        buyVIPView?.layer.shadowColor = UIColor.grayColor().CGColor
        buyVIPView?.layer.shadowRadius = 3
        buyVIPView?.layer.shadowOpacity = 0.3
        view.addSubview(buyVIPView!)
        buyVIPView?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(callServantBtn!)
        })
        
        let btn = UIButton()
        btn.backgroundColor = colorWithHexString("#162334")
        btn.setTitle("购买此服务", forState: .Normal)
        btn.addTarget(self, action: #selector(buyVIP(_:)), forControlEvents: .TouchUpInside)
        buyVIPView?.addSubview(btn)
        btn.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(buyVIPView!)
            make.top.equalTo(buyVIPView!)
            make.bottom.equalTo(buyVIPView!)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 8.0 * 3)
        })
        
        let titleLab = UILabel()
        titleLab.backgroundColor = UIColor.clearColor()
        titleLab.text = "会员:"
        titleLab.textColor = UIColor.blackColor()
        titleLab.font = UIFont.systemFontOfSize(S12)
        buyVIPView?.addSubview(titleLab)
        titleLab.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(40)
            make.centerY.equalTo(buyVIPView!).offset(5)
        })
        
        priceLab = UILabel()
        priceLab?.backgroundColor = UIColor.clearColor()
        priceLab?.text = "1999"
        priceLab?.textColor = UIColor.blackColor()
        priceLab?.font = UIFont.systemFontOfSize(S18)
        buyVIPView?.addSubview(priceLab!)
        priceLab?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(titleLab.snp_right).offset(5)
            make.bottom.equalTo(titleLab).offset(3)
        })
        
        let unitLab = UILabel()
        unitLab.backgroundColor = UIColor.clearColor()
        unitLab.text = "元/年"
        unitLab.textColor = UIColor.blackColor()
        unitLab.font = UIFont.systemFontOfSize(S12)
        buyVIPView?.addSubview(unitLab)
        unitLab.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(priceLab!.snp_right).offset(5)
            make.bottom.equalTo(titleLab)
        })
        
        buyVIPView?.hidden = !(callServantBtn?.hidden)!
    }
    
    func buyVIP(sender: UIButton) {
        buyNowButtonTouched()
    }
    
    func shareToOthers() {
        if (DataManager.currentUser?.centurionCardLv)! == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "只有开通的帐号才能进行分享！！！", ForDuration: 1, completion: nil)
            return
        }
        
        let shareController = ShareViewController()
        shareController.modalPresentationStyle = .Custom
        shareController.shareImage = shareImage()
        
        presentViewController(shareController, animated: true) { 
        }
    }
    
    func callSrevant() {
//        let userInfo = UserInfo()
//        userInfo.uid = 50
//        userInfo.nickname = "优悦金牌客服"
//        let chatVC = ChatVC()
//        chatVC.servantInfo = userInfo
//        navigationController?.pushViewController(chatVC, animated: true)
        
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
    
    func returnCellHeightWithInfo(info:Results<CenturionCardServiceInfo>?) -> CGFloat {
        
        let serviceInfo = info?.first
        var height = DataManager.currentUser?.centurionCardLv >=  serviceInfo?.privilege_lv_ ? AtapteWidthValue(240) : AtapteWidthValue(80)
        if (info?.count)! % 4 == 0 {
            height += CGFloat(((info?.count)! / 4)) * AtapteWidthValue(80)
        } else {
            height += CGFloat(((info?.count)! / 4) + 1) * AtapteWidthValue(80)

        }
        
        
        return height
    }
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return indexPath.row == 0 ? AtapteWidthValue(209) : (indexPath.row == 1 ? AtapteWidthValue(70) : returnCellHeightWithInfo(services))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CenturionCardBaseInfoCell", forIndexPath: indexPath) as! CenturionCardBaseInfoCell
            cell.setInfo(DataManager.currentUser)

            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CenturionCardLvSelCell", forIndexPath: indexPath) as! CenturionCardLvSelCell
            lvContentCollectionView = cell.contentCollection
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
//        if selectedIndex == index {
//            return
//        }
        selectedIndex = index
        services = DataManager.getCenturionCardServiceWithLV(index + 1)
        table?.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 2, inSection: 0)], withRowAnimation: .Fade)
        callServantBtn?.hidden = index >= DataManager.currentUser!.centurionCardLv
        buyVIPView?.hidden = !(callServantBtn?.hidden)!
        if let info = DataManager.getData(CentuionCardPriceInfo.self, filter: "blackcard_lv_ = \(index+1)") as? CentuionCardPriceInfo {
            priceLab?.text = "\(info.blackcard_price_ / 100)"
        }
        if index == 3 {
            callServantBtn?.hidden = true
            buyVIPView?.hidden = true
        }
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
        
         MobClick.event(CommonDefine.BuriedPoint.vipLvpay)
        if selectedIndex == 3 {
            let alert = UIAlertController.init(title: "购买提示", message: "对不起，四星会员仅支持内部邀请！", preferredStyle: .Alert)
            let ok = UIAlertAction.init(title: "好的", style: .Default, handler: nil)
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let curLv = DataManager.currentUser?.centurionCardLv
        if curLv <= 0 {
            UIApplication.sharedApplication().openURL(NSURL.init(string: "http://www.yundiantrip.com/?page_id=6")!)
            return
        }
        
        let currentCardInfo = DataManager.getData(CentuionCardPriceInfo.self, filter: "blackcard_lv_ = \((DataManager.currentUser?.centurionCardLv)!)")
        let price = DataManager.getData(CentuionCardPriceInfo.self, filter: "blackcard_lv_ = \(selectedIndex + 1)")
        let totalPrice = 0 + (price?.blackcard_price_)!

        if price?.blackcard_price_ != nil &&
            price?.blackcard_price_ > 0 &&
           totalPrice - (currentCardInfo?.blackcard_price_)! > DataManager.currentUser?.cash {
            
            moneyIsTooLess()
            return
        }
        
        upCenturionCardLv(totalPrice - (currentCardInfo?.blackcard_price_)!)
    }
    
    /**
     跳转到设置支付密码界面
     */
    func jumpToPayPasswdVC() {
        let payPasswdVC = PayPasswdVC()
        payPasswdVC.payPasswdStatus = PayPasswdStatus(rawValue: (DataManager.currentUser?.has_passwd_)!)!
        navigationController?.pushViewController(payPasswdVC, animated: true)
    }
    
    func upCenturionCardLv(price:Int) {
        if DataManager.currentUser?.has_passwd_ == -1 {
            let alert = UIAlertController.init(title: "提示", message: "您尚未设置支付密码", preferredStyle: .Alert)
            weak var weakSelf = self
            let gotoSetup = UIAlertAction.init(title: "前往设置", style: .Default, handler: { (action) in
                weakSelf?.jumpToPayPasswdVC()
            })
            let cancel = UIAlertAction.init(title: "取消", style: .Default, handler: nil)
            alert.addAction(gotoSetup)
            alert.addAction(cancel)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
//        let price = record.valueForKey("order_price_")?.integerValue
        let msg = "\n您即将预支付人民币:\(Double(price)/100)元"
        let alert = UIAlertController.init(title: "付款确认", message: msg, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "请输入支付密码"
            textField.secureTextEntry = true
        })
        
        let ok = UIAlertAction.init(title: "确认付款", style: .Default, handler: { [weak self] (action) in
            let weakSelf = self
            let passwd = alert.textFields?.first?.text
            /**
             *  密码为空
             */
            if passwd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                SVProgressHUD.showErrorMessage(ErrorMessage: "请输入支付密码", ForDuration: 1, completion: nil)
                return
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
                "wanted_lv_": self!.selectedIndex+1]
//            SVProgressHUD.showProgressMessage(ProgressMessage: "获取订单信息...")
            SVProgressHUD.show()
            SocketManager.sendData(.getUpCenturionCardOriderRequest, data: dict) { [weak self](result) in
                
                let data = result["data"] as! NSDictionary
                if let errorCord = data.valueForKey("error_"){
                    let errorMsg = CommonDefine.errorMsgs[errorCord as! Int]
                    SVProgressHUD.showErrorMessage(ErrorMessage:errorMsg! , ForDuration: 1, completion: nil)
                    return
                }
                if let strongSelf = self {
                    strongSelf.payWithRecord(data, password: passwd!)
                }
            }
            
            
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    func payWithRecord(record:NSDictionary, password:String) {
        SVProgressHUD.showProgressMessage(ProgressMessage: "支付中...")
        let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)!,
                                        "order_id_": record.valueForKey("order_id_")!,
                                        "passwd_": password]
        unowned let weakSelf = self
        SocketManager.sendData(.PayForInvitationRequest, data: dict, result: { (result) in
            let data = result["data"] as! NSDictionary
            if let errorCord = data.valueForKey("error_"){
                let errorMsg = CommonDefine.errorMsgs[errorCord as! Int]
                SVProgressHUD.showErrorMessage(ErrorMessage:errorMsg! , ForDuration: 2, completion: nil)
                return
            }
            
            let orderStatus = data.valueForKey("result_") as? Int
            if orderStatus == -1 {
                
                SVProgressHUD.showErrorMessage(ErrorMessage: "密码错误", ForDuration: 2, completion: nil)
            }
            if orderStatus == -2 {
                weakSelf.moneyIsTooLess()
            }
            if orderStatus == 0 {
                SVProgressHUD.showSuccessMessage(SuccessMessage: "购买成功!", ForDuration: 2, completion: {
                    SocketManager.sendData(.UserCenturionCardInfoRequest, data: ["uid_": DataManager.currentUser!.uid])
                    DataManager.currentUser?.centurionCardLv = weakSelf.selectedIndex + 1
                    weakSelf.refreshData()
                })
            }
            
        })
    }
    
    func refreshData() {
        var lv = DataManager.currentUser!.centurionCardLv
        if lv == 0 {
            lv += 1
        }
        services = DataManager.getCenturionCardServiceWithLV(lv)
        lvContentCollectionView?.reloadData()
        table?.reloadData()
    }
    func shareImage()-> UIImage  {
        let view = UIView(frame:  CGRectMake(0, 0, ScreenWidth, 160))
        let imageView = UIImageView(frame: CGRectMake((ScreenWidth - 150) / 2, 10, 140, 140))
        imageView.backgroundColor = UIColor.whiteColor()
        let image = UIImage(named: "share_erweima")
        imageView.image = image
        view.addSubview(imageView)
        table?.tableFooterView = view
        let frame = table?.frame
        table!.frame =  CGRect.init(origin: CGPointZero, size: table!.contentSize)
        table!.setContentOffset(CGPointZero, animated: false)
        table!.reloadData()
        UIGraphicsBeginImageContextWithOptions((table?.contentSize)!,false, 1)
	    let context = UIGraphicsGetCurrentContext()
	    table!.layer.renderInContext(context!)
        table?.drawViewHierarchyInRect((table?.frame)!, afterScreenUpdates: false)
	    let img = UIGraphicsGetImageFromCurrentImageContext()
	    UIGraphicsEndImageContext()
        table?.frame = frame!
        table?.tableFooterView?.frame = CGRectZero
        table?.tableFooterView = nil
        
	    return img;
    }
    
}
