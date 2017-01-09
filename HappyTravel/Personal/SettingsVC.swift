//
//  SettingsVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/24.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD

class SettingCell: UITableViewCell{
    var titleLable: UILabel? = UILabel.init()
    var rightLabel: UILabel? = UILabel.init()
    var switchBtn: UISwitch? = UISwitch()
    var upLine: UIView = UIView()
    
    
    var isBtnCell: Bool?{
        didSet{
            addSwitchBtn()
        }
    }
    var isLogoutCell: Bool? {
        didSet{
            setLogoutCell()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if !self.isEqual(nil) {
            self.selectionStyle = .None
            titleLable?.backgroundColor = UIColor.clearColor()
            titleLable?.font = UIFont.systemFontOfSize(S15)
            titleLable?.textAlignment = .Left
            titleLable?.textColor = UIColor.blackColor()
            contentView.addSubview(titleLable!)
            titleLable?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.bottom.equalTo(contentView).offset(-10)
                make.right.equalTo(contentView).offset(-10)
            })
            
            rightLabel?.backgroundColor = UIColor.clearColor()
            rightLabel?.textAlignment = .Right
            rightLabel?.textColor = UIColor.grayColor()
            rightLabel?.font = UIFont.systemFontOfSize(S15)
            contentView.addSubview(rightLabel!)
            rightLabel?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(titleLable!)
                make.top.equalTo(titleLable!)
                make.bottom.equalTo(titleLable!)
            })
            
            let upLine = UIView()
            upLine.backgroundColor = colorWithHexString("#e2e2e2")
            contentView.addSubview(upLine)
            upLine.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(ScreenWidth)
                make.height.equalTo(0.5)
                make.left.equalTo(titleLable!)
                make.top.equalTo(contentView)
            })
            self.upLine = upLine
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingCell{
    
    func addSwitchBtn() {

        if isBtnCell == false {
            return
        }
        switchBtn?.onTintColor = UIColor.init(decR: 183, decG: 39, decB: 43, a: 1)
        contentView.addSubview(switchBtn!)
        switchBtn?.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(contentView).offset(-10)
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
        })
    }
    
    func setLogoutCell() {
        
        if isLogoutCell == false{
            return
        }
        accessoryType = .None
        titleLable!.textAlignment = .Center
        titleLable!.textColor = UIColor.init(decR: 183, decG: 39, decB: 43, a: 1)
    }
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum SettingItem: String {
        case UserNum = "当前帐号"
        case ChangPwd = "密码修改"
        case AuthUser = "个人认证"
        case NoLeft = "阅后即焚"
        case ClearCache = "清除缓存"
        case UpdateVerison = "更新版本"
        case AboutUs = "关于我们"
        case LogoutUser = "退出当前帐号"
    }
    
    var settingsTable:UITableView?
    var settingOption:[[SettingItem]]?
    var settingOptingValue:[[String]]?
    var authUserCardCode = (DataManager.currentUser?.authentication)!
    var selectIndex: NSIndexPath?
    var autoStatus: String {
        get{
            switch Int(authUserCardCode) {
            case -1:
                return "申请认证"
            case 0:
                return "认证中"
            case 1:
                return "已认证"
            case 2:
                return "认证失败，重新认证"
            default:
                return ""
            }
        }
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置"
        initData()
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        authUserCardCode = CurrentUser.auth_status_

        settingsTable?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    func initView() {
        settingsTable = UITableView(frame: CGRectZero, style: .Grouped)
        settingsTable?.delegate = self
        settingsTable?.dataSource = self
        settingsTable?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        settingsTable?.rowHeight = 45
        settingsTable?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        settingsTable?.separatorStyle = .None
        settingsTable?.registerClass(SettingCell.classForCoder(), forCellReuseIdentifier: "SettingCell")
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
        return section < 2 ? 10:40
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SettingCell = (tableView.dequeueReusableCellWithIdentifier("SettingCell") as? SettingCell)!
        let option = settingOption?[indexPath.section][indexPath.row]
        let value = settingOptingValue?[indexPath.section][indexPath.row]
        cell.titleLable?.text = option!.rawValue
        cell.rightLabel?.text = value
        cell.accessoryType = (value?.characters.count == 0 || option == .ClearCache) ? .DisclosureIndicator:.None
        cell.isLogoutCell = option == .LogoutUser
        cell.upLine.hidden = indexPath.row == 0
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectIndex = indexPath
        let selectOption: SettingItem = settingOption![indexPath.section][indexPath.row] 
        switch selectOption {
            case .ChangPwd:
                let modifyPasswordVC = ModifyPasswordVC()
                navigationController?.pushViewController(modifyPasswordVC, animated: true)
                break
            case .AuthUser:
                if authUserCardCode == 0 || authUserCardCode == 1 {
                    return
                }
                let controller = UploadUserPictureVC()
                self.navigationController!.pushViewController(controller, animated: true)
                break
            case .ClearCache:
                clearCacleSizeCompletion({
                    self.settingOptingValue![(self.selectIndex?.section)!][(self.selectIndex?.row)!] = String(format: "%.2f M",self.calculateCacle())
                    tableView.reloadData()
                })
                break
            case .LogoutUser:
                SocketManager.logoutCurrentAccount()
                navigationController?.popViewControllerAnimated(false)
                break
            case .AboutUs:
                let webVc = CommonWebVC.init(title: "关于我们", url: "http://www.yundiantrip.com")
                self.navigationController?.pushViewController(webVc, animated: true)
                break
            default:
                break
        }
    }
    
    // 计算缓存
    func calculateCacle() ->Double {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let files = NSFileManager.defaultManager().subpathsAtPath(path!)
        var size = 0.00
        for file in files! {
            let filePath = path?.stringByAppendingString("/\(file)")
            let fileAtrributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(filePath!)
            for (attrKey,attrVale) in fileAtrributes {
                if attrKey == NSFileSize {
                    size += attrVale.doubleValue
                }
            }
        }
        let totalSize = size/1024/1024
        return totalSize
    }
    // 清除缓存
    func clearCacleSizeCompletion(completion: (()->Void)?) {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let files = NSFileManager.defaultManager().subpathsAtPath(path!)
        
        for file in files! {
            let filePath = path?.stringByAppendingString("/\(file)")
            if NSFileManager.defaultManager().fileExistsAtPath(filePath!) {
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(filePath!)
                }catch{
                    
                }
            }
        }
        SVProgressHUD.showSuccessMessage(SuccessMessage: "清除成功", ForDuration: 1, completion: completion)
    }
    
    func initData() {
        SocketManager.sendData(.CheckAuthenticateResult, data:["uid_": CurrentUser.uid_]) { [weak self](result) in
            if let strongSelf = self{
                strongSelf.authUserCardCode = DataManager.currentUser!.authentication
                strongSelf.settingOptingValue![0][2] = strongSelf.autoStatus
                dispatch_async(dispatch_get_main_queue(), {
                    strongSelf.settingsTable?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
                })
                
            }
        }
        var number = DataManager.currentUser!.phoneNumber ?? "***********"
        let startIndex = "...".endIndex
        let endIndex = ".......".endIndex
        number.replaceRange(startIndex..<endIndex, with: "****")
    
        settingOption = [[.UserNum, .ChangPwd, .AuthUser ],
                         [.ClearCache, .UpdateVerison, .AboutUs],
                         [.LogoutUser]]
        settingOptingValue = [[number, "", autoStatus],
                              [String(format: "%.2fM",calculateCacle()), "已是最新版本", ""],
                              [""]]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


