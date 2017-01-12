//
//  WalletVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/23.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
class WalletVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var walletTable:UITableView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        walletTable?.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkUserResultReply(_:)), name: NotifyDefine.CheckUserCashResult, object: nil)
        
        APIHelper.userAPI().cash({ [weak self](response) in
            if let dict = response as? [String: AnyObject] {
                if let cash = dict["user_cash_"] as? Int {
                    CurrentUser.user_cash_ = cash
                }
                if let hasPasswd = dict["has_passwd_"] as? Int {
                    CurrentUser.has_passwd_ = hasPasswd
                }
                self!.walletTable?.reloadData()
                return
            }
            SVProgressHUD.showWainningMessage(WainningMessage: "初始化钱包环境失败，请稍后再试..", ForDuration: 1.5, completion: nil)
        }, error: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "钱包"
        
        initView()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        SVProgressHUD.dismiss()
    }
    
    func initView() {
        walletTable = UITableView(frame: CGRectZero, style: .Grouped)
        walletTable?.delegate = self
        walletTable?.dataSource = self
        walletTable?.estimatedRowHeight = 60
        walletTable?.rowHeight = UITableViewAutomaticDimension
        walletTable?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        walletTable?.separatorStyle = .None
        view.addSubview(walletTable!)
        walletTable?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
    }
    
    func initData() {
        
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = .clearColor()
            let label = UILabel()
            label.backgroundColor = .clearColor()
            label.text = "发票管理"
            label.font = .systemFontOfSize(S15)
            label.textColor = UIColor.grayColor()
            view.addSubview(label)
            label.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(view).offset(AtapteWidthValue(20))
                make.top.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            })
            return view
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("WalletCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .DisclosureIndicator
            cell?.selectionStyle = .None
        }
        
        var icon = cell?.contentView.viewWithTag(1001) as? UIImageView
        if icon == nil {
            icon = UIImageView()
            icon?.backgroundColor = UIColor.clearColor()
            cell?.contentView.addSubview(icon!)
            icon?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
                make.width.equalTo(25)
            })
        }
        
        var title = cell?.contentView.viewWithTag(1002) as? UILabel
        if title == nil {
            title = UILabel()
            title?.tag = 1002
            title?.backgroundColor = UIColor.clearColor()
            title?.textColor = UIColor.blackColor()
            title?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(title!)
            title?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(icon!.snp_right).offset(10)
                make.top.equalTo(icon!)
                make.bottom.equalTo(icon!)
                make.right.equalTo(cell!.contentView)
            })
        }
        
        var separateLine = cell?.contentView.viewWithTag(1003)
        if separateLine == nil {
            separateLine = UIView()
            separateLine?.tag = 1003
            separateLine?.backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
            cell?.contentView.addSubview(separateLine!)
            separateLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(icon!)
                make.right.equalTo(cell!.contentView).offset(40)
                make.bottom.equalTo(cell!.contentView).offset(0.5)
                make.height.equalTo(1)
            })
        }
        separateLine?.hidden = true
        
        var subTitleLabel = cell?.contentView.viewWithTag(1004) as? UILabel
        if subTitleLabel == nil {
            subTitleLabel = UILabel()
            subTitleLabel?.tag = 1004
            subTitleLabel?.backgroundColor = UIColor.clearColor()
            subTitleLabel?.textColor = UIColor.blackColor()
            subTitleLabel?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(subTitleLabel!)
            subTitleLabel?.snp_makeConstraints(closure: { (make) in
                make.centerY.equalTo(cell!.contentView.snp_centerY)
                make.right.equalTo(0)
            })
        }
        subTitleLabel?.hidden = indexPath.section != 0
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                icon?.image = UIImage.init(named: "cash")
                title?.text = "余额"
                let cash: String = String(format:"%.2f元", Double(CurrentUser.user_cash_)/100)
                subTitleLabel?.text = cash
                separateLine?.hidden = false
            } else if indexPath.row == 1 {
                icon?.image = UIImage.init(named: "modify_pass")
                title?.text = CurrentUser.has_passwd_ == -1 ? "设置支付密码" : "修改支付密码"
                subTitleLabel?.text = ""
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                icon?.image = UIImage.init(named: "invoice")
                title?.text = "按行程开票"
                separateLine?.hidden = false
            } else if indexPath.row == 1 {
                icon?.image = UIImage.init(named: "invoice-history")
                title?.text = "开票记录"
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let rechargeVC = RechargeVC()
                 MobClick.event(CommonDefine.BuriedPoint.rechargeBtn)
                navigationController?.pushViewController(rechargeVC, animated: true)
            } else if indexPath.row == 1 {
                let payPasswdVC = PayPasswdVC()
                payPasswdVC.payPasswdStatus = PayPasswdStatus(rawValue: CurrentUser.has_passwd_)!
                navigationController?.pushViewController(payPasswdVC, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let invoiceVC = InvoiceVC()
                navigationController?.pushViewController(invoiceVC, animated: true)
            } else if indexPath.row == 1 {
                let invoiceHistotyVC = InvoiceHistoryVC()
                navigationController?.pushViewController(invoiceHistotyVC, animated: true)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func checkUserResultReply(notice: NSNotification) {
        let data = notice.userInfo!["data"] as! NSDictionary
        let code = data.valueForKey("code")
        if code?.intValue == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法验证，请稍后再试", ForDuration: 1, completion: {
                self.navigationController?.popViewControllerAnimated(true)
            })
            return
        }
        SVProgressHUD.dismiss()
        walletTable?.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

