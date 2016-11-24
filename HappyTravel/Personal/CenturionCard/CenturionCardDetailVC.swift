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

class CenturionCardDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table:UITableView?
    
    let tags = ["headView": 1001,
                "titleLab": 1002,
                "descLab": 1003,
                "callServantBtn": 1004]
    
    var serviceTel = "10086"
    
    var service:CenturionCardServiceInfo?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "服务详情"
        
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
    func receivedData(_ notifation:Notification) {
        
        let dict = notifation.userInfo!["data"] as! [String : AnyObject]
        
        
        if let errorCode = dict["error_"] {
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
    
        NotificationCenter.default.addObserver(self, selector: #selector(CenturionCardDetailVC.receivedData), name: NSNotification.Name(rawValue: NotifyDefine.ServersManInfoReply), object: nil)
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .grouped)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table?.separatorStyle = .none
        view.addSubview(table!)
        table?.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return headViewCell(tableView, indexPath: indexPath)
        } else if indexPath.section == 1 || indexPath.section == 2 {
            return descCell(tableView, indexPath: indexPath)
        } else if indexPath.section == 3 {
            return callServantCell(tableView, indexPath: indexPath)
        }
        
        return UITableViewCell()
    }
    
    func headViewCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HeadViewCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.selectionStyle = .none
        }
        
        var headView = cell?.contentView.viewWithTag(tags["headView"]!) as? UIImageView
        if headView == nil {
            headView = UIImageView()
            headView?.tag = tags["headView"]!
            cell?.contentView.addSubview(headView!)
            headView?.snp.makeConstraints({ (make) in
                make.edges.equalTo(cell!.contentView)
                make.width.height.equalTo(210)
            })
        }
        headView?.image = UIImage.init(named: "bg-card-detail")
//        headView?.kf_setImageWithURL(NSURL(string: service?.privilege_bg_! == nil ? "" : service!.privilege_bg_!), placeholderImage: UIImage.init(named: "bg-card-detail"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        
        return cell!
    }
    
    func descCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DescCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.selectionStyle = .none
        }
        
        var title = cell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel
        if title == nil {
            title = UILabel()
            title?.tag = tags["titleLab"]!
            title?.backgroundColor = UIColor.clear
            title?.font = UIFont.systemFont(ofSize: S15)
            title?.textColor = UIColor.black
            cell?.contentView.addSubview(title!)
            title?.snp.makeConstraints({ (make) in
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
            descLab?.backgroundColor = UIColor.clear
            descLab?.font = UIFont.systemFont(ofSize: S13)
            descLab?.textColor = UIColor.gray
            descLab?.numberOfLines = 0
            cell?.contentView.addSubview(descLab!)
            descLab?.snp.makeConstraints({ (make) in
                make.left.equalTo(cell!.contentView).offset(15)
                make.top.equalTo(title!.snp.bottom).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-15)
                make.right.equalTo(cell!.contentView).offset(-15)
            })
        }
        descLab?.text = indexPath.section == 1 ? service?.privilege_summary_! : service?.privilege_details_!

        return cell!
    }
    
    func callServantCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DescCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
            cell?.contentView.backgroundColor = UIColor.clear
        }
        
        let title = service?.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ? "联系服务管家" : "购买此服务"
        var callServantBtn = cell?.contentView.viewWithTag(tags["callServantBtn"]!) as? UIButton
        if callServantBtn == nil {
            callServantBtn = UIButton()
            callServantBtn?.tag = tags["callServantBtn"]!
            callServantBtn?.backgroundColor = UIColor.white
            callServantBtn?.setTitle(title, for: UIControlState())
            callServantBtn?.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), for: UIControlState())
            callServantBtn?.layer.masksToBounds = true
            callServantBtn?.layer.cornerRadius = 5
            callServantBtn?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            callServantBtn?.layer.borderWidth = 1
            callServantBtn?.addTarget(self, action: #selector(CenturionCardDetailVC.callSrevant), for: .touchUpInside)
            cell?.contentView.addSubview(callServantBtn!)
            callServantBtn?.snp.makeConstraints({ (make) in
                make.centerX.equalTo(cell!.contentView)
                make.top.equalTo(cell!.contentView).offset(60)
                make.bottom.equalTo(cell!.contentView).offset(-20)
                make.width.equalTo(120)
                make.height.equalTo(40)
                
            })
        }

        return cell!
    }
    
    func callSrevant() {
        if service?.privilege_lv_ <= DataManager.currentUser!.centurionCardLv {
            _ = SocketManager.sendData(.serversManInfoRequest, data: nil)

            
        } else {
            
            let alert = UIAlertController.init(title: "呼叫", message: serviceTel, preferredStyle: .alert)
            let ensure = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
                UIApplication.shared.openURL(URL(string: "tel://\(self.serviceTel)")!)
            })
            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction) in
                
            })
            alert.addAction(ensure)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

