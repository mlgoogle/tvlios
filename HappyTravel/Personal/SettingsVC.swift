//
//  SettingsVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/24.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var settingsTable:UITableView?
    var settingOption:Array<Array<String>>?
    let authUserCardCode = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultKeys.authUserCard)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "设置"
        
        settingOption = [["当前账号", "密码修改", "个人认证", "芝麻信用"], ["阅后即焚"], ["清除缓存", "更新版本", "关于我们"], ["退出当前账号"]]
        initView()
    }
    
    func initView() {
        settingsTable = UITableView(frame: CGRectZero, style: .Grouped)
        settingsTable?.delegate = self
        settingsTable?.dataSource = self
        settingsTable?.estimatedRowHeight = 60
        settingsTable?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        settingsTable?.rowHeight = UITableViewAutomaticDimension
        settingsTable?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        settingsTable?.separatorStyle = .None
        view.addSubview(settingsTable!)
        settingsTable?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingOption![section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settingOption!.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < 3 {
            return 10
        } else {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SettingCell")
        if cell == nil {
            cell = UITableViewCell()
        }
        if indexPath.section == 0 && indexPath.row == 0 {
            cell?.accessoryType = .None
        } else if indexPath.section == 1 && indexPath.row == 0 {
            cell?.accessoryType = .None
        } else if indexPath.section == 2 && indexPath.row == 1 {
            cell?.accessoryType = .None
        } else if indexPath.section == 3 && indexPath.row == 0 {
            cell?.accessoryType = .None
        } else {
            cell?.accessoryType = .DisclosureIndicator
        }
        
        var title = cell?.contentView.viewWithTag(1002) as? UILabel
        if title == nil {
            title = UILabel()
            title?.tag = 1002
            title?.backgroundColor = UIColor.clearColor()
            title?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(title!)
            title?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(10)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
                make.right.equalTo(cell!.contentView).offset(-10)
            })
        }
        if indexPath.section == 3 {
            title?.textAlignment = .Center
            title?.textColor = UIColor.init(decR: 183, decG: 39, decB: 43, a: 1)
        } else {
            title?.textAlignment = .Left
            title?.textColor = UIColor.blackColor()
        }
        title?.text = settingOption?[indexPath.section][indexPath.row]
        
        var rightLab = cell?.contentView.viewWithTag(2001) as? UILabel
        if rightLab == nil {
            rightLab = UILabel()
            rightLab?.tag = 2001
            rightLab?.backgroundColor = UIColor.clearColor()
            rightLab?.textAlignment = .Right
            rightLab?.textColor = UIColor.grayColor()
            rightLab?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(rightLab!)
            rightLab?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(title!)
                make.top.equalTo(title!)
                make.bottom.equalTo(title!)
            })
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            rightLab?.hidden = false
            var number = DataManager.currentUser!.phoneNumber == nil ? "***********" : DataManager.currentUser!.phoneNumber!
            let startIndex = "...".endIndex
            let endIndex = ".......".endIndex
            number.replaceRange(startIndex..<endIndex, with: "****")
            rightLab?.text = number
        } else if indexPath.section == 0 && indexPath.row == 2 && DataManager.currentUser?.authentication == true {
            rightLab?.hidden = false
            rightLab?.text = "已认证"
            cell?.accessoryType = .None
        }else if indexPath.section == 2 && indexPath.row == 0 {
            rightLab?.hidden = false
            rightLab?.text = "0 M"
        } else if indexPath.section == 2 && indexPath.row == 1 {
            rightLab?.hidden = false
            rightLab?.text = "当前为最新版本"
        } else {
            rightLab?.hidden = true
        }
        
        var switchBtn = cell?.contentView.viewWithTag(2002) as? UISwitch
        if switchBtn == nil {
            switchBtn = UISwitch()
            switchBtn?.tag = 2002
            switchBtn?.onTintColor = UIColor.init(decR: 183, decG: 39, decB: 43, a: 1)
            cell?.contentView.addSubview(switchBtn!)
            switchBtn?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(cell!.contentView).offset(-10)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
            })
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            switchBtn?.hidden = false
        } else {
            switchBtn?.hidden = true
        }
        
        var separateLine = cell?.contentView.viewWithTag(1003)
        if separateLine == nil {
            separateLine = UIView()
            separateLine?.tag = 1003
            separateLine?.backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
            cell?.contentView.addSubview(separateLine!)
            separateLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(title!)
                make.right.equalTo(cell!.contentView).offset(40)
                make.bottom.equalTo(cell!.contentView).offset(0.5)
                make.height.equalTo(1)
            })
        }
        separateLine?.hidden = true
        if ((settingOption?[indexPath.section].count)! > indexPath.row) && (((settingOption?[indexPath.section].count)! - 1) != indexPath.row) {
            separateLine?.hidden = false
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                XCGLogger.debug("余额")
            } else if indexPath.row == 1 {
                let modifyPasswordVC = ModifyPasswordVC()
                navigationController?.pushViewController(modifyPasswordVC, animated: true)
            }else if indexPath.row == 2  {
                if DataManager.currentUser?.authentication == true{
                    return
                }
                let controller = UploadUserPictureVC()
                self.navigationController!.pushViewController(controller, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                XCGLogger.debug("按行程开票")
            } else if indexPath.row == 1 {
                XCGLogger.debug("开票记录")
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 { // 退出登录
                SocketManager.logoutCurrentAccount()
                navigationController?.popViewControllerAnimated(false)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
