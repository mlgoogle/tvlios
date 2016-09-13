//
//  ModifyPasswordVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/24.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class ModifyPasswordVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var table:UITableView?
    var tableOption:Array<Array<Array<String>>>?
    var sureBtn:UIButton?
    var oldPasswd:String? = ""
    var newPasswd:String? = ""
    var verifyPasswd:String? = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "修改密码"
        
        tableOption = [[["原始密码", "请输入原始密码"]], [["新密码", "请输入新密码"],["确认密码", "请重新输入密码"]], [["确认"]]]
        initView()
        
        registerNotify()
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ModifyPasswordVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ModifyPasswordVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        table?.separatorStyle = .None
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableOption![section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableOption!.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < 2 {
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
            cell?.accessoryType = .None
            cell?.contentView.userInteractionEnabled = true
            cell?.userInteractionEnabled = true
            cell?.selectionStyle = .None
        }
        
        var title = cell?.contentView.viewWithTag(1001) as? UILabel
        if title == nil {
            title = UILabel()
            title?.tag = 1001
            title?.backgroundColor = UIColor.clearColor()
            title?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(title!)
            title?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(10)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
                make.width.equalTo(60)
            })
        }
        
        var inputView = cell?.contentView.viewWithTag(1002 + indexPath.row + indexPath.section) as? UITextField
        if inputView == nil {
            inputView = UITextField()
            inputView?.tag = 1002 + indexPath.row + indexPath.section
            inputView?.secureTextEntry = true
            inputView?.delegate = self
            inputView?.rightViewMode = .WhileEditing
            inputView?.clearButtonMode = .WhileEditing
            cell?.contentView.addSubview(inputView!)
            inputView?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(title!.snp_right).offset(10)
                make.top.equalTo(title!)
                make.bottom.equalTo(title!)
                make.right.equalTo(cell!.contentView).offset(-20)
            })
        }
        
        sureBtn = cell?.contentView.viewWithTag(2001) as? UIButton
        if sureBtn == nil {
            sureBtn = UIButton()
            sureBtn?.backgroundColor = UIColor.init(decR: 170, decG: 170, decB: 170, a: 1)
            sureBtn?.tag = 2001
            sureBtn?.layer.cornerRadius = 5
            sureBtn?.layer.masksToBounds = true
            sureBtn?.setTitle(tableOption?[indexPath.section][indexPath.row][0], forState: .Normal)
            sureBtn?.addTarget(self, action: #selector(ModifyPasswordVC.modifyPwd(_:)), forControlEvents: .TouchUpInside)
            sureBtn?.enabled = false
            cell?.contentView.addSubview(sureBtn!)
            sureBtn?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView)
                make.width.equalTo(UIScreen.mainScreen().bounds.size.width-40)
                make.height.equalTo(35)
            })
        }
        if indexPath.section == 2 {
            title?.hidden = true
            sureBtn?.hidden = false
            inputView?.hidden = true
            cell?.backgroundColor = UIColor.clearColor()
            cell?.contentView.backgroundColor = UIColor.clearColor()
        } else {
            title?.hidden = false
            inputView?.hidden = false
            inputView?.placeholder = tableOption?[indexPath.section][indexPath.row][1]
            title?.text = tableOption?[indexPath.section][indexPath.row][0]
            sureBtn?.hidden = true
            cell?.backgroundColor = UIColor.whiteColor()
            cell?.contentView.backgroundColor = UIColor.whiteColor()
        }
        
        var separateLine = cell?.contentView.viewWithTag(1003)
        if separateLine == nil {
            separateLine = UIView()
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
        if ((tableOption?[indexPath.section].count)! > indexPath.row) && (((tableOption?[indexPath.section].count)! - 1) != indexPath.row) {
            separateLine?.hidden = false
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                XCGLogger.debug("余额")
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                XCGLogger.debug("按行程开票")
            } else if indexPath.row == 1 {
                XCGLogger.debug("开票记录")
            }
        }
    }
    
    func modifyPwd(sender: UIButton?) {
//        let dict = ["uid_": DataManager.currentUser!.uid!, "old_passwd_": "123456x", "new_passwd_": "223456x"]
//        SocketManager.sendData(.ModifyPassword, data: dict)
        XCGLogger.debug("\(self.oldPasswd!)\n\(self.newPasswd!)\n\(self.verifyPasswd!)")
    }
    
    //MARK: - UITextField
    func textFieldDidEndEditing(textField: UITextField) {

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        switch textField.tag {
        case 1002:
            oldPasswd = ""
            break
        case 1003:
            newPasswd = ""
            break
        case 1004:
            verifyPasswd = ""
            break
        default:
            break
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 15 {
            return false
        }
        
        sureBtn?.enabled = false
        sureBtn?.backgroundColor = UIColor.init(decR: 170, decG: 170, decB: 170, a: 1)
        if textField.tag == 1002 {
            oldPasswd = textField.text! + string
        } else if textField.tag == 1003 {
            newPasswd = textField.text! + string
            if oldPasswd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                sureBtn?.setTitle("旧密码不能为空", forState: .Disabled)
            }
        } else if textField.tag == 1004 {
            verifyPasswd = textField.text! + string
            if oldPasswd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                sureBtn?.setTitle("旧密码不能为空", forState: .Disabled)
            } else {
                if newPasswd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                    sureBtn?.setTitle("新密码不能为空", forState: .Disabled)
                } else {
                    if verifyPasswd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) >= newPasswd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
                        if verifyPasswd! != newPasswd! {
                            sureBtn?.setTitle("新密码不一致", forState: .Disabled)
                        } else {
                            sureBtn?.backgroundColor = UIColor.init(decR: 10, decG: 20, decB: 40, a: 1)
                            sureBtn?.enabled = true
                        }
                    } else {
                        sureBtn?.setTitle("确认", forState: .Disabled)
                    }
                }
            }
            
        }
        
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

