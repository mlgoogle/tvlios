//
//  ModifyPasswordVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/24.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ModifyPasswordVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var table:UITableView?
    var tableOption:Array<Array<Array<String>>>?
    var sureBtn:UIButton?
    var oldPasswd:String? = ""
    var newPasswd:String? = ""
    var verifyPasswd:String? = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "修改密码"
        
        tableOption = [[["原始密码", "请输入原始密码"]], [["新密码", "请输入新密码"],["确认密码", "请重新输入密码"]], [["确认"]]]
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
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(ModifyPasswordVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ModifyPasswordVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ModifyPasswordVC.modifyPasswordSucceed), name: NSNotification.Name(rawValue: NotifyDefine.ModifyPasswordSucceed), object: nil)

    }
    /**
     密码修改成功
     */
    func modifyPasswordSucceed() {
        
        SocketManager.logoutCurrentAccount()
        _ = navigationController?.popToRootViewController(animated: true)
    }
    /**
     
     键盘弹出监听
     - parameter notification:
     */
    func keyboardWillShow(_ notification: Notification?) {
        let frame = (notification!.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let inset = UIEdgeInsetsMake(0, 0, (frame?.size.height)!, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
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
        
        hideKeyboard()
    }
    
    func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(InvoiceDetailVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableOption![section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableOption!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < 2 {
            return 10
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .none
            cell?.contentView.isUserInteractionEnabled = true
            cell?.isUserInteractionEnabled = true
            cell?.selectionStyle = .none
        }
        
        var title = cell?.contentView.viewWithTag(1001) as? UILabel
        if title == nil {
            title = UILabel()
            title?.tag = 1001
            title?.backgroundColor = UIColor.clear
            title?.font = UIFont.systemFont(ofSize: S15)
            cell?.contentView.addSubview(title!)
            title?.snp.makeConstraints({ (make) in
                make.left.equalTo(cell!.contentView).offset(10)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
                make.width.equalTo(AtapteWidthValue(65))
            })
        }
        
        var inputView = cell?.contentView.viewWithTag(1002 + indexPath.row + indexPath.section) as? UITextField
        if inputView == nil {
            inputView = UITextField()
            inputView?.tag = 1002 + indexPath.row + indexPath.section
            inputView?.isSecureTextEntry = true
            inputView?.delegate = self
            inputView?.rightViewMode = .whileEditing
            inputView?.clearButtonMode = .whileEditing
            cell?.contentView.addSubview(inputView!)
            inputView?.snp.makeConstraints({ (make) in
                make.left.equalTo(title!.snp.right).offset(10)
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
            sureBtn?.setTitle(tableOption?[indexPath.section][indexPath.row][0], for: UIControlState())
            sureBtn?.addTarget(self, action: #selector(ModifyPasswordVC.modifyPwd(_:)), for: .touchUpInside)
            sureBtn?.isEnabled = false
            cell?.contentView.addSubview(sureBtn!)
            sureBtn?.snp.makeConstraints({ (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView)
                make.width.equalTo(UIScreen.main.bounds.size.width-40)
                make.height.equalTo(35)
            })
        }
        if indexPath.section == 2 {
            title?.isHidden = true
            sureBtn?.isHidden = false
            inputView?.isHidden = true
            cell?.backgroundColor = UIColor.clear
            cell?.contentView.backgroundColor = UIColor.clear
        } else {
            title?.isHidden = false
            inputView?.isHidden = false
            inputView?.placeholder = tableOption?[indexPath.section][indexPath.row][1]
            title?.text = tableOption?[indexPath.section][indexPath.row][0]
            sureBtn?.isHidden = true
            cell?.backgroundColor = UIColor.white
            cell?.contentView.backgroundColor = UIColor.white
        }
        
        var separateLine = cell?.contentView.viewWithTag(1003)
        if separateLine == nil {
            separateLine = UIView()
            separateLine?.backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
            cell?.contentView.addSubview(separateLine!)
            separateLine?.snp.makeConstraints({ (make) in
                make.left.equalTo(title!)
                make.right.equalTo(cell!.contentView).offset(40)
                make.bottom.equalTo(cell!.contentView).offset(0.5)
                make.height.equalTo(1)
            })
        }
        separateLine?.isHidden = true
        if ((tableOption?[indexPath.section].count)! > indexPath.row) && (((tableOption?[indexPath.section].count)! - 1) != indexPath.row) {
            separateLine?.isHidden = false
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func modifyPwd(_ sender: UIButton?) {
        let dict = ["uid_": DataManager.currentUser!.uid, "old_passwd_": "\(oldPasswd!)", "new_passwd_": "\(newPasswd!)"] as [String : Any]
        _ = SocketManager.sendData(.modifyPassword, data: dict as AnyObject?)
        XCGLogger.debug("\(self.oldPasswd!)\n\(self.newPasswd!)\n\(self.verifyPasswd!)")
    }
    
    //MARK: - UITextField
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location > 15 {
            return false
        }
        
        sureBtn?.isEnabled = false
        sureBtn?.backgroundColor = UIColor.init(decR: 170, decG: 170, decB: 170, a: 1)
        if textField.tag == 1002 {
            oldPasswd = textField.text! + string
        } else if textField.tag == 1003 {
            newPasswd = textField.text! + string
            if oldPasswd?.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                sureBtn?.setTitle("旧密码不能为空", for: .disabled)
            }
        } else if textField.tag == 1004 {
            verifyPasswd = textField.text! + string
            if oldPasswd?.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                sureBtn?.setTitle("旧密码不能为空", for: .disabled)
            } else {
                if newPasswd?.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                    sureBtn?.setTitle("新密码不能为空", for: .disabled)
                } else {
                    if verifyPasswd?.lengthOfBytes(using: String.Encoding.utf8) >= newPasswd?.lengthOfBytes(using: String.Encoding.utf8) {
                        if verifyPasswd! != newPasswd! {
                            sureBtn?.setTitle("新密码不一致", for: .disabled)
                        } else {
                            sureBtn?.backgroundColor = UIColor.init(decR: 10, decG: 20, decB: 40, a: 1)
                            sureBtn?.isEnabled = true
                        }
                    } else {
                        sureBtn?.setTitle("确认", for: .disabled)
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
        NotificationCenter.default.removeObserver(self)
    }
}

