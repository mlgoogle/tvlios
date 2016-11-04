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
    var switchBtn: UISwitch?
    
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
            titleLable?.font = UIFont.systemFontOfSize(15)
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
            rightLabel?.font = UIFont.systemFontOfSize(15)
            contentView.addSubview(rightLabel!)
            rightLabel?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(titleLable!)
                make.top.equalTo(titleLable!)
                make.bottom.equalTo(titleLable!)
            })
            
            let downLine = UIView()
            downLine.backgroundColor = colorWithHexString("#e2e2e2")
            contentView.addSubview(downLine)
            downLine.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(ScreenWidth)
                make.height.equalTo(0.5)
                make.centerX.equalTo(contentView)
                make.bottom.equalTo(contentView)
            })
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
        switchBtn = UISwitch()
        switchBtn?.onTintColor = UIColor.init(decR: 183, decG: 39, decB: 43, a: 1)
        contentView.addSubview(switchBtn!)
        switchBtn?.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(contentView).offset(-10)
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
        })
    }
    
    func addUpLine() {
        
        let upLine = UIView()
        accessoryType = .None
        upLine.backgroundColor = colorWithHexString("#e2e2e2")
        contentView.addSubview(upLine)
        upLine.snp_makeConstraints(closure: { (make) in
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(0.5)
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView)
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
    let UserNum = "当前帐号"
    let ChangPwd = "密码修改"
    let AuthUser = "个人认证"
    let SesameCredit = "芝麻信用"
    let NoLeft = "阅后即焚"
    let ClearCache = "清楚缓存"
    let UpdateVerison = "更新版本"
    let AboutUs = "关于我们"
    let LogoutUser = "退出当前帐号"
    var settingsTable:UITableView?
    var settingOption:[[String]]?
    var settingOptingValue:[[String]]?
    var authUserCardCode: NSInteger? = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultKeys.authUserCard+"\(DataManager.currentUser!.uid)") as?  NSInteger
    var selectIndex: NSIndexPath?
    var autoStatus: String {
        get{
            if authUserCardCode == nil {
                return ""
            }
            switch Int(authUserCardCode!) {
            case 1:
                return "认证中"
            case 2:
                return "已认证"
            case 1:
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
        if authUserCardCode == nil  {
            let param = ["uid_":DataManager.currentUser!.uid]
            SocketManager.sendData(.checkAuthenticateResult, data:param)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkAuthResult(_:)), name: NotifyDefine.CheckAuthenticateResult, object: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        return section < 3 ? 10:40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SettingCell = (tableView.dequeueReusableCellWithIdentifier("SettingCell") as? SettingCell)!
        cell.titleLable?.text = settingOption?[indexPath.section][indexPath.row]
        cell.rightLabel?.text = settingOptingValue?[indexPath.section][indexPath.row]
        cell.accessoryType = settingOptingValue?[indexPath.section][indexPath.row] == "" ? .DisclosureIndicator:.None
        cell.isBtnCell = indexPath.section == 1 && indexPath.row == 0
        cell.isLogoutCell = indexPath.section == 3
        if indexPath.row == 0 {
            cell.addUpLine()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectIndex = indexPath
        let selectOption = settingOption![indexPath.section][indexPath.row]
        switch selectOption {
        case ChangPwd:
            let modifyPasswordVC = ModifyPasswordVC()
            navigationController?.pushViewController(modifyPasswordVC, animated: true)
            break
        case AuthUser:
            if authUserCardCode == 1||authUserCardCode == 2{
                return
            }
            let controller = UploadUserPictureVC()
            self.navigationController!.pushViewController(controller, animated: true)
            break
        case ClearCache:
            clearCacleSizeCompletion({
                self.settingOptingValue![(self.selectIndex?.section)!][(self.selectIndex?.row)!] = String(format: "%.2f m",self.calculateCacle())
                tableView.reloadData()
            })
            break
        case LogoutUser:
            SocketManager.logoutCurrentAccount()
            navigationController?.popViewControllerAnimated(false)
            break
        default:
            break
        }
    }
    
    func checkAuthResult(notice: NSNotification) {
        let data = notice.userInfo!["data"] as! NSDictionary
        let failedReson = data["failed_reason_"] as? NSString
        let reviewStatus = data.valueForKey("review_status_")?.integerValue
        if reviewStatus == -1 {
            return
        }
        if failedReson != "" {
            return
        }
        authUserCardCode = reviewStatus! + 1
        let key = UserDefaultKeys.authUserCard+"\(DataManager.currentUser!.uid)"
        NSUserDefaults.standardUserDefaults().setValue(authUserCardCode, forKey:key)
        settingsTable?.reloadData()
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
        
        var number = DataManager.currentUser!.phoneNumber == nil ? "***********" : DataManager.currentUser!.phoneNumber!
        let startIndex = "...".endIndex
        let endIndex = ".......".endIndex
        number.replaceRange(startIndex..<endIndex, with: "****")
    
        settingOption = [[UserNum, ChangPwd, AuthUser, SesameCredit],
                         [NoLeft],
                         [ClearCache, UpdateVerison, AboutUs],
                         [LogoutUser]]
        settingOptingValue = [[number, "", autoStatus, ""],
                              [""],
                              [String(format: "%.2f m",calculateCacle()), "已是更新版本", ""],
                              [""]]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


