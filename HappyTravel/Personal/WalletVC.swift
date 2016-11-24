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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        walletTable?.reloadData()
        SVProgressHUD.showProgressMessage(ProgressMessage: "初始化钱包环境...")
        NotificationCenter.default.addObserver(self, selector: #selector(checkUserResultReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.CheckUserCashResult), object: nil)
       _ = SocketManager.sendData(.checkUserCash, data: ["uid_":DataManager.currentUser!.uid])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "钱包"
        
        initView()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        SVProgressHUD.dismiss()
    }
    
    func initView() {
        walletTable = UITableView(frame: CGRect.zero, style: .grouped)
        walletTable?.delegate = self
        walletTable?.dataSource = self
        walletTable?.estimatedRowHeight = 60
        walletTable?.rowHeight = UITableViewAutomaticDimension
        walletTable?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        walletTable?.separatorStyle = .none
        view.addSubview(walletTable!)
        walletTable?.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
    }
    
    func initData() {
        
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = .clear
            let label = UILabel()
            label.backgroundColor = .clear
            label.text = "发票管理"
            label.font = .systemFont(ofSize: S15)
            label.textColor = UIColor.gray
            view.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.left.equalTo(view).offset(AtapteWidthValue(20))
                make.top.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            })
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .disclosureIndicator
            cell?.selectionStyle = .none
        }
        
        var icon = cell?.contentView.viewWithTag(1001) as? UIImageView
        if icon == nil {
            icon = UIImageView()
            icon?.backgroundColor = UIColor.clear
            cell?.contentView.addSubview(icon!)
            icon?.snp.makeConstraints({ (make) in
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
            title?.backgroundColor = UIColor.clear
            title?.textColor = UIColor.black
            title?.font = UIFont.systemFont(ofSize: 15)
            cell?.contentView.addSubview(title!)
            title?.snp.makeConstraints({ (make) in
                make.left.equalTo(icon!.snp.right).offset(10)
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
            separateLine?.snp.makeConstraints({ (make) in
                make.left.equalTo(icon!)
                make.right.equalTo(cell!.contentView).offset(40)
                make.bottom.equalTo(cell!.contentView).offset(0.5)
                make.height.equalTo(1)
            })
        }
        separateLine?.isHidden = true
        
        var subTitleLabel = cell?.contentView.viewWithTag(1004) as? UILabel
        if subTitleLabel == nil {
            subTitleLabel = UILabel()
            subTitleLabel?.tag = 1004
            subTitleLabel?.backgroundColor = UIColor.clear
            subTitleLabel?.textColor = UIColor.black
            subTitleLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.contentView.addSubview(subTitleLabel!)
            subTitleLabel?.snp.makeConstraints({ (make) in
                make.centerY.equalTo(cell!.contentView.snp.centerY)
                make.right.equalTo(0)
            })
        }
        subTitleLabel?.isHidden = indexPath.section != 0
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                icon?.image = UIImage.init(named: "cash")
                title?.text = "余额"
                let cash: String = String(format:"%.2f元", Double((DataManager.currentUser?.cash)!)/100)
                subTitleLabel?.text = cash
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                icon?.image = UIImage.init(named: "invoice")
                title?.text = "按行程开票"
                separateLine?.isHidden = false
            } else if indexPath.row == 1 {
                icon?.image = UIImage.init(named: "invoice-history")
                title?.text = "开票记录"
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                XCGLogger.debug("余额")
                let rechargeVC = RechargeVC()
                navigationController?.pushViewController(rechargeVC, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                XCGLogger.debug("按行程开票")
                let invoiceVC = InvoiceVC()
                navigationController?.pushViewController(invoiceVC, animated: true)
            } else if indexPath.row == 1 {
                XCGLogger.debug("开票记录")
                let invoiceHistotyVC = InvoiceHistoryVC()
                navigationController?.pushViewController(invoiceHistotyVC, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func checkUserResultReply(_ notice: Notification) {
        let data = notice.userInfo!["data"] as! NSDictionary
        let code = data.value(forKey: "code")
        if (code as AnyObject).int32Value == 0 {
            unowned let weakSelf = self
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法验证，请稍后再试", ForDuration: 1, completion: {
              _ = weakSelf.navigationController?.popViewController(animated: true)
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

