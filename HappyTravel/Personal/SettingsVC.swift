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
            self.selectionStyle = .none
            titleLable?.backgroundColor = UIColor.clear
            titleLable?.font = UIFont.systemFont(ofSize: S15)
            titleLable?.textAlignment = .left
            titleLable?.textColor = UIColor.black
            contentView.addSubview(titleLable!)
            titleLable?.snp_makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.bottom.equalTo(contentView).offset(-10)
                make.right.equalTo(contentView).offset(-10)
            })
            
            rightLabel?.backgroundColor = UIColor.clear
            rightLabel?.textAlignment = .right
            rightLabel?.textColor = UIColor.gray
            rightLabel?.font = UIFont.systemFont(ofSize: S15)
            contentView.addSubview(rightLabel!)
            rightLabel?.snp_makeConstraints({ (make) in
                make.right.equalTo(titleLable!)
                make.top.equalTo(titleLable!)
                make.bottom.equalTo(titleLable!)
            })
            
            let upLine = UIView()
            upLine.backgroundColor = colorWithHexString("#e2e2e2")
            contentView.addSubview(upLine)
            upLine.snp_makeConstraints({ (make) in
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
        switchBtn?.snp_makeConstraints({ (make) in
            make.right.equalTo(contentView).offset(-10)
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
        })
    }
    
    func setLogoutCell() {
        
        if isLogoutCell == false{
            return
        }
        accessoryType = .none
        titleLable!.textAlignment = .center
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
    let authUserCardCode = (DataManager.currentUser?.authentication)!
    var selectIndex: IndexPath?
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
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置"
        initData()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    func initView() {
        settingsTable = UITableView(frame: CGRect.zero, style: .grouped)
        settingsTable?.delegate = self
        settingsTable?.dataSource = self
        settingsTable?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        settingsTable?.rowHeight = 45
        settingsTable?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        settingsTable?.separatorStyle = .none
        settingsTable?.register(SettingCell.classForCoder(), forCellReuseIdentifier: "SettingCell")
        view.addSubview(settingsTable!)
        settingsTable?.snp_makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingOption![section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingOption!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section < 2 ? 10:40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingCell = (tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell)!
        let option = settingOption?[indexPath.section][indexPath.row]
        let value = settingOptingValue?[indexPath.section][indexPath.row]
        cell.titleLable?.text = option!.rawValue
        cell.rightLabel?.text = value
        cell.accessoryType = (value?.characters.count == 0 || option == .ClearCache) ? .disclosureIndicator:.none
        cell.isLogoutCell = option == .LogoutUser
        cell.upLine.isHidden = indexPath.row == 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                navigationController?.popViewController(animated: false)
                break
            default:
            break
        }
    }
    
    // 计算缓存
    func calculateCacle() ->Double {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let files = FileManager.default.subpaths(atPath: path!)
        var size = 0.00
        for file in files! {
            let filePath = (path)! + "/\(file)"
            let fileAtrributes = try! FileManager.default.attributesOfItem(atPath: filePath)
            for (attrKey,attrVale) in fileAtrributes {
                if attrKey == FileAttributeKey.size {
                    size += (attrVale as AnyObject).doubleValue
                }
            }
        }
        let totalSize = size/1024/1024
        return totalSize
    }
    // 清除缓存
    func clearCacleSizeCompletion(_ completion: (()->Void)?) {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let files = FileManager.default.subpaths(atPath: path!)
        
        for file in files! {
            let filePath = (path)! + "/\(file)"
            if FileManager.default.fileExists(atPath: filePath) {
                do{
                    try FileManager.default.removeItem(atPath: filePath)
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
        number.replaceSubrange(startIndex..<endIndex, with: "****")
    
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


