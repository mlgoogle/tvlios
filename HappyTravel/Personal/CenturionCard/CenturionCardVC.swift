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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
//        _ = SocketManager.sendData(.centurionCardInfoRequest, data: nil)
        _ = SocketManager.sendData(.centurionCardInfoRequest, data: nil) { [weak self](result) in
            if let strongSelf = self{
                strongSelf.table?.reloadData()
            }
        }
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    func receivedData(_ notifation:Notification) {
        let dict = notifation.userInfo!["data"] as? [String: AnyObject]

        if let errorCode = dict!["error_"] {
            SVProgressHUD.showWainningMessage(WainningMessage: errorCode as! Int == -1040 ? "当前没有在线服务管家" : "未知错误：\(errorCode)", ForDuration: 1.5, completion: nil)
        } else {
            let userInfo = UserInfo()
            
            userInfo.setInfo(.other, info: dict)
            
            DataManager.updateUserInfo(userInfo)
            let chatVC = ChatVC()
            chatVC.servantInfo = userInfo
            navigationController?.pushViewController(chatVC, animated: true)
            
        }
        
        
    }
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(CenturionCardVC.receivedData), name: NSNotification.Name(rawValue: NotifyDefine.ServersManInfoReply), object: nil)
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .plain)
        table?.backgroundColor = UIColor.white
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.separatorStyle = .none
        table?.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
        table?.register(CenturionCardBaseInfoCell.self, forCellReuseIdentifier: "CenturionCardBaseInfoCell")
        table?.register(CenturionCardServicesCell.self, forCellReuseIdentifier: "CenturionCardServicesCell")
        table?.register(CenturionCardLvSelCell.self, forCellReuseIdentifier: "CenturionCardLvSelCell")
        view.addSubview(table!)
        
        callServantBtn = UIButton()
        callServantBtn?.setTitle("联系服务管家", for: UIControlState())
        callServantBtn?.setTitleColor(UIColor.white, for: UIControlState())
        callServantBtn?.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), for: UIControlState())
        callServantBtn?.addTarget(self, action: #selector(CenturionCardVC.callSrevant), for: .touchUpInside)
        view.addSubview(callServantBtn!)
        callServantBtn?.isHidden = DataManager.currentUser!.centurionCardLv <= 0
        callServantBtn?.snp.makeConstraints({ (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(65)
            
        })
    
        table?.snp.makeConstraints({ (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(0)
        })
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "share"), style: .plain, target: self, action: #selector(shareToOthers))
    }
    
    func shareToOthers() {
        if (DataManager.currentUser?.centurionCardLv)! == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "只有开通的帐号才能进行分享！！！", ForDuration: 1, completion: nil)
            return
        }
        
        let shareController = ShareViewController()
        shareController.modalPresentationStyle = .custom
        shareController.shareImage = shareImage()
        present(shareController, animated: true
            , completion: nil)
    }
    
    func callSrevant() {
        _ = SocketManager.sendData(.serversManInfoRequest, data: nil)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? AtapteWidthValue(209) : (indexPath.row == 1 ? AtapteWidthValue(70) : AtapteWidthValue(500))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CenturionCardBaseInfoCell", for: indexPath) as! CenturionCardBaseInfoCell
            cell.setInfo(DataManager.currentUser)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CenturionCardLvSelCell", for: indexPath) as! CenturionCardLvSelCell
            cell.delegate = self
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CenturionCardServicesCell", for: indexPath) as! CenturionCardServicesCell
            cell.delegate = self
            cell.setInfo(services)
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - CenturionCardLvSelCellDelegate
    func selectedAction(_ index: Int) {
        if selectedIndex == index {
            return
        }
        selectedIndex = index
        services = DataManager.getCenturionCardServiceWithLV(index + 1)
        table?.reloadRows(at: [IndexPath.init(row: 2, section: 0)], with: .fade)
        callServantBtn?.isHidden = index >= DataManager.currentUser!.centurionCardLv
    }
    
    // MARK: - CenturionCardServicesCellDelegate
    func serviceTouched(_ service: CenturionCardServiceInfo) {
        let detailVC = CenturionCardDetailVC()
        detailVC.service = service
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func moneyIsTooLess() {
        let alert = UIAlertController.init(title: "余额不足", message: "\n请前往充值", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "前往充值", style: .default, handler: { (action: UIAlertAction) in
            let rechargeVC = RechargeVC()
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func buyNowButtonTouched() {
        if selectedIndex == 3 {
            let alert = UIAlertController.init(title: "购买提示", message: "对不起，四星会员仅支持内部邀请！", preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "好的", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let curLv = DataManager.currentUser?.centurionCardLv
        if curLv <= 0 {
            UIApplication.shared.openURL(URL.init(string: "http://baidu.com")!)
            return
        }
        
        let realm = try! Realm()
        let price: CentuionCardPriceInfo? = realm.objects(CentuionCardPriceInfo.self).filter("blackcard_lv_ = \(selectedIndex)").first
        
        if price?.blackcard_price_ != nil &&
            price?.blackcard_price_ > 0 &&
            price?.blackcard_price_ > DataManager.currentUser?.cash{
            
            moneyIsTooLess()
            return
        }
        
        let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)! as AnyObject,
                                        "wanted_lv_": (selectedIndex + 1) as AnyObject]
        SVProgressHUD.showProgressMessage(ProgressMessage: "获取订单信息...")
        SocketManager.sendData(.getUpCenturionCardOriderRequest, data: dict as AnyObject?) { [weak self](result) in
            
            let data = result["data"] as! NSDictionary
            if let errorCord = data.value(forKey: "error_"){
                let errorMsg = CommonDefine.errorMsgs[errorCord as! Int]
                SVProgressHUD.showErrorMessage(ErrorMessage:errorMsg! , ForDuration: 1, completion: nil)
                return
            }
            if let strongSelf = self {
                strongSelf.upCenturionCardLv(data)
                SVProgressHUD.dismiss()
            }
        }
    }

    
    /// 逻辑牵扯有点多  等其他全迁移到3.0再重写这个
    ///
    /// - Parameter record: 用了OC类型
    func upCenturionCardLv(_ record: NSDictionary) {

        let price = record.value(forKey: "order_price_") as! Int
        let msg = "\n您即将预支付人民币:\(Double(price)/100)元"
        let alert = UIAlertController.init(title: "付款确认", message: msg, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "请输入密码"
            textField.isSecureTextEntry = true
        })
        
        let ok = UIAlertAction.init(title: "确认付款", style: .default, handler: { [weak self] (action) in
            let weakSelf = self
            let passwd = alert.textFields?.first?.text
            /**
             *  密码为空
             */
            if passwd?.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                SVProgressHUD.showErrorMessage(ErrorMessage: "请输入密码", ForDuration: 1, completion: nil)
                return
            }
            /**
             *  密码错误
             */
            if let localPasswd = UserDefaults.standard.object(forKey: CommonDefine.Passwd) as? String {
                if passwd != localPasswd {
                    SVProgressHUD.showErrorMessage(ErrorMessage: "密码输入错误，请重新输入", ForDuration: 2, completion: nil)
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
            SVProgressHUD.showProgressMessage(ProgressMessage: "支付中...")
            let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)! as AnyObject,
                "order_id_": record.value(forKey: "order_id_")! as AnyObject,
                "passwd_": passwd! as AnyObject]
            SocketManager.sendData(.payForInvitationRequest, data: dict as AnyObject?, result: { (result) in
                let data = result["data"] as! NSDictionary
                if let errorCord = data.value(forKey: "error_"){
                    let errorMsg = CommonDefine.errorMsgs[errorCord as! Int]
                    SVProgressHUD.showErrorMessage(ErrorMessage:errorMsg! , ForDuration: 2, completion: nil)
                    return
                }
                    
                let orderStatus = data.value(forKey: "result_") as? Int
                if orderStatus == -1 {
                    SVProgressHUD.showErrorMessage(ErrorMessage: "密码错误", ForDuration: 2, completion: nil)
                }
                if orderStatus == -2 {
                    weakSelf!.moneyIsTooLess()
                }
                if orderStatus == 0 {
                    SVProgressHUD.showSuccessMessage(SuccessMessage: "购买成功!", ForDuration: 2, completion: {
                        _ = SocketManager.sendData(.userCenturionCardInfoRequest, data: ["uid_": DataManager.currentUser!.uid])
                        DataManager.currentUser?.centurionCardLv = weakSelf!.selectedIndex + 1
                        weakSelf!.viewDidLoad()
                    })
                }

            })
            
            
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func shareImage()-> UIImage  {
        table!.frame =  CGRect.init(origin: CGPoint.zero, size: table!.contentSize)
        table!.setContentOffset(CGPoint.zero, animated: false)
        table!.reloadData()
        UIGraphicsBeginImageContext(table!.contentSize)
        UIGraphicsBeginImageContextWithOptions(table!.contentSize, true, table!.layer.contentsScale)
	    let context = UIGraphicsGetCurrentContext()
	    table!.layer.render(in: context!)
	    let img = UIGraphicsGetImageFromCurrentImageContext()
	    UIGraphicsEndImageContext()
	    return img!;
    }
    
}
