//
//  InvoiceDetailVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class InvoiceDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate {
    
    var table:UITableView?
    var selectedOrderList:Results<OpenTicketInfo>?
    var segmentIndex = 0
    var descLab:UILabel?
    var descLabText:String?
    
    let tags = ["titleLab_Invoice": 1001,
                "textField_Invoice": 1002,
                "titleLab_Personal": 1003,
                "textField_Personal": 1004,
                "descLab_Invoice": 1008,
                "textView_Personal": 1005,
                "commitBtn": 1006,
                "bottomLine": 1007]
    
    var invoiceInfoDict:[String: AnyObject]?
    
    let invoiceInfo = ["发票抬头",
                       "纳税人号",
                       "注册地址",
                       "发票类型"]
    
    let personalInfo = ["联 系 人",
                        "联系电话",
                        "所在区域",
                        "详细地址",
                        "备注信息"]
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "开票信息设置"
        
        initData()
        initView()
        registerNotify()
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .none
        table?.register(InvoiceCell.self, forCellReuseIdentifier: "InvoiceCell")
        view.addSubview(table!)
        table?.snp_makeConstraints({ (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
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
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceDetailVC.drawBillReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.DrawBillReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceDetailVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceDetailVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
   
    /**
     发票请求回调
     
     - parameter notification: 
     */
    func drawBillReply(_ notification: Notification?) {
        SVProgressHUD.dismiss()
        if let dict = notification?.userInfo!["data"] as? Dictionary<String, AnyObject> {
            if let _ = dict["oid_str_"] as? String {
                let alert = UIAlertController.init(title: "发票状态", message: "发票信息审核中", preferredStyle: .alert)
                let action = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func keyboardWillShow(_ notification: Notification?) {
        let frame = (notification!.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let inset = UIEdgeInsetsMake(0, 0, (frame?.size.height)!, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    // MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return invoiceInfo.count
        } else if section == 1 {
            return personalInfo.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return invoiceInfoCell(tableView, indexPath: indexPath)
        } else if indexPath.section == 1 {
            return personalInfoCell(tableView, indexPath: indexPath)
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CommitButton")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .none
                cell?.contentView.isUserInteractionEnabled = true
                cell?.isUserInteractionEnabled = true
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
            
            var commitBtn = cell?.contentView.viewWithTag(tags["commitBtn"]!) as? UIButton
            if commitBtn == nil {
                commitBtn = UIButton()
                commitBtn?.tag = tags["commitBtn"]!
                commitBtn?.setTitle("提交", for: UIControlState())
                commitBtn?.backgroundColor = UIColor.init(decR: 11, decG: 19, decB: 31, a: 1)
                commitBtn?.layer.cornerRadius = 5
                commitBtn?.layer.masksToBounds = true
                commitBtn?.addTarget(self, action: #selector(InvoiceDetailVC.commit), for: .touchUpInside)
                cell?.contentView.addSubview(commitBtn!)
                commitBtn?.snp_makeConstraints({ (make) in
                    make.left.equalTo(cell!.contentView).offset(20)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.top.equalTo(cell!.contentView)
                    make.height.equalTo(40)
                })
            }
            
            var bottomLine = cell?.contentView.viewWithTag(tags["bottomLine"]!)
            if bottomLine == nil {
                bottomLine = UIView()
                bottomLine?.tag = tags["bottomLine"]!
                bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
                cell?.contentView.addSubview(bottomLine!)
                bottomLine?.snp_makeConstraints({ (make) in
                    make.left.equalTo(commitBtn!)
                    make.bottom.equalTo(cell!.contentView)
                    make.right.equalTo(cell!.contentView)
                    make.height.equalTo(1)
                })
                
            }
            bottomLine?.isHidden = true

            return cell!
        }
        
    }
    
    func invoiceInfoCell(_ tableView:UITableView, indexPath: IndexPath) ->UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceInfo")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .none
            cell?.contentView.isUserInteractionEnabled = true
            cell?.isUserInteractionEnabled = true
            cell?.selectionStyle = .none
        }
        
        var titleLab = cell?.contentView.viewWithTag(tags["titleLab_Invoice"]!) as? UILabel
        if titleLab == nil {
            titleLab = UILabel()
            titleLab?.tag = tags["titleLab_Invoice"]!
            titleLab?.backgroundColor = UIColor.clear
            titleLab?.textAlignment = .right
            titleLab?.font = UIFont.systemFont(ofSize: S15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints({ (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView).offset(15)
                make.bottom.equalTo(cell!.contentView).offset(-15)
                make.width.equalTo(AtapteWidthValue(65))
            })
        }
        titleLab?.text = invoiceInfo[indexPath.row]
        
        if indexPath.row == invoiceInfo.count - 1 {
            cell?.accessoryType = .disclosureIndicator
            var descLab = cell?.contentView.viewWithTag(tags["descLab_Invoice"]!) as? UILabel
            if descLab == nil {
                descLab = UILabel()
                descLab?.tag = tags["descLab_Invoice"]!
                descLab?.backgroundColor = UIColor.clear
                descLab?.textAlignment = .left
                descLab?.textColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
                descLab?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(descLab!)
                descLab?.snp_makeConstraints({ (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.top.equalTo(titleLab!)
                    make.bottom.equalTo(titleLab!)
                })
                self.descLab = descLab
            }
            descLab?.text = descLabText == nil ? invoiceInfo[indexPath.row] : descLabText
        } else {
            cell?.accessoryType = .none
            var textField = cell?.contentView.viewWithTag(tags["textField_Invoice"]!) as? UITextField
            if textField == nil {
                textField = UITextField()
                textField?.tag = tags["textField_Invoice"]!
                textField?.isSecureTextEntry = false
                textField?.delegate = self
                textField?.rightViewMode = .whileEditing
                textField?.clearButtonMode = .whileEditing
                textField?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(textField!)
                textField?.snp_makeConstraints({ (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                })
            }
            textField?.placeholder = invoiceInfo[indexPath.row]
            if textField?.placeholder?.compare("发票抬头") == .orderedSame {
                textField?.text = invoiceInfoDict!["title_"] as? String
            } else if textField?.placeholder?.compare("纳税人号") == .orderedSame {
                textField?.text = invoiceInfoDict!["taxpayer_num_"] as? String
            } else if textField?.placeholder?.compare("注册地址") == .orderedSame {
                textField?.text = invoiceInfoDict!["company_addr_"] as? String
            } else if textField?.placeholder?.compare("联 系 人") == .orderedSame {
                textField?.text = invoiceInfoDict!["user_name_"] as? String
            } else if textField?.placeholder?.compare("联系电话") == .orderedSame {
                textField?.text = invoiceInfoDict!["user_mobile_"] as? String
                textField?.keyboardType = .phonePad
            } else if textField?.placeholder?.compare("所在区域") == .orderedSame {
                textField?.text = invoiceInfoDict!["area_"] as? String
            } else if textField?.placeholder?.compare("详细地址") == .orderedSame {
                textField?.text = invoiceInfoDict!["addr_detail_"] as? String
            }
        }
        
        var bottomLine = cell?.contentView.viewWithTag(tags["bottomLine"]!)
        if bottomLine == nil {
            bottomLine = UIView()
            bottomLine?.tag = tags["bottomLine"]!
            bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
            cell?.contentView.addSubview(bottomLine!)
            bottomLine?.snp_makeConstraints({ (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
            })
        }
        bottomLine?.isHidden = (indexPath.row == invoiceInfo.count - 1 ? true : false)
        
        return cell!
    }
    
    func personalInfoCell(_ tableView:UITableView, indexPath: IndexPath) ->UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PersonalInfo")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .none
            cell?.contentView.isUserInteractionEnabled = true
            cell?.isUserInteractionEnabled = true
            cell?.selectionStyle = .none
        }
        
        var titleLab = cell?.contentView.viewWithTag(tags["titleLab_Personal"]!) as? UILabel
        if titleLab == nil {
            titleLab = UILabel()
            titleLab?.tag = tags["titleLab_Personal"]!
            titleLab?.backgroundColor = UIColor.clear
            titleLab?.textAlignment = .right
            titleLab?.font = UIFont.systemFont(ofSize: S15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints({ (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView).offset(15)
                make.width.equalTo(AtapteWidthValue(65))
            })
        }
        titleLab?.text = personalInfo[indexPath.row]
        
        var bottomLine = cell?.contentView.viewWithTag(tags["bottomLine"]!)
        if bottomLine == nil {
            bottomLine = UIView()
            bottomLine?.tag = tags["bottomLine"]!
            bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
            cell?.contentView.addSubview(bottomLine!)
            bottomLine?.snp_makeConstraints({ (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
            })
        }
        bottomLine?.isHidden = (indexPath.row == personalInfo.count - 1 ? true : false)
        
        if indexPath.row == personalInfo.count - 1 {
            var textView = cell?.contentView.viewWithTag(tags["textView_Personal"]!) as? UITextView
            if textView == nil {
                textView = UITextView()
                textView?.delegate = self
                textView?.tag = tags["textView_Personal"]!
                textView?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
                textView?.textAlignment = .left
                textView?.textColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
                textView?.font = UIFont.systemFont(ofSize: S15)
                textView?.layer.cornerRadius = 5
                textView?.layer.masksToBounds = true
                cell?.contentView.addSubview(textView!)
                textView?.snp_makeConstraints({ (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.top.equalTo(titleLab!)
                    make.height.equalTo(80)
                })
            }
            
            bottomLine?.snp_remakeConstraints({ (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
                make.top.equalTo(textView!.snp_bottom).offset(10)
            })
            
            textView?.text = invoiceInfoDict!["remark_"] as? String
            if textView?.text.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                textView?.textColor = UIColor.black
            }
            
            
        } else {
            var textField = cell?.contentView.viewWithTag(tags["textField_Invoice"]!) as? UITextField
            if textField == nil {
                textField = UITextField()
                textField?.tag = tags["textField_Invoice"]!
                textField?.isSecureTextEntry = false
                textField?.delegate = self
                textField?.rightViewMode = .whileEditing
                textField?.clearButtonMode = .whileEditing
                textField?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(textField!)
                textField?.snp_makeConstraints({ (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                })
            }
            textField?.placeholder = personalInfo[indexPath.row]
            
            bottomLine?.snp_remakeConstraints({ (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
            })
            
            if textField?.placeholder?.compare("发票抬头") == .orderedSame {
                textField?.text = invoiceInfoDict!["title_"] as? String
            } else if textField?.placeholder?.compare("纳税人号") == .orderedSame {
                textField?.text = invoiceInfoDict!["taxpayer_num_"] as? String
            } else if textField?.placeholder?.compare("注册地址") == .orderedSame {
                textField?.text = invoiceInfoDict!["company_addr_"] as? String
            } else if textField?.placeholder?.compare("联 系 人") == .orderedSame {
                textField?.text = invoiceInfoDict!["user_name_"] as? String
            } else if textField?.placeholder?.compare("联系电话") == .orderedSame {
                textField?.text = invoiceInfoDict!["user_mobile_"] as? String
                textField?.keyboardType = .phonePad
            } else if textField?.placeholder?.compare("所在区域") == .orderedSame {
                textField?.text = invoiceInfoDict!["area_"] as? String
            } else if textField?.placeholder?.compare("详细地址") == .orderedSame {
                textField?.text = invoiceInfoDict!["addr_detail_"] as? String
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == invoiceInfo.count - 1 {
            let action = UIAlertView.init(title: "选择发票类型", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "差旅费", "文体用品", "餐饮发票", "其他")
            action.show()
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else if section == 1 {
            return 10
        } else {
            return 40
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.placeholder?.compare("发票抬头") == .orderedSame {
            invoiceInfoDict!["title_"] = textField.text as AnyObject?
        } else if textField.placeholder?.compare("纳税人号") == .orderedSame {
            invoiceInfoDict!["taxpayer_num_"] = textField.text as AnyObject?
        } else if textField.placeholder?.compare("注册地址") == .orderedSame {
            invoiceInfoDict!["company_addr_"] = textField.text as AnyObject?
        } else if textField.placeholder?.compare("联 系 人") == .orderedSame {
            invoiceInfoDict!["user_name_"] = textField.text as AnyObject?
        } else if textField.placeholder?.compare("联系电话") == .orderedSame {
            invoiceInfoDict!["user_mobile_"] = textField.text as AnyObject?
        } else if textField.placeholder?.compare("所在区域") == .orderedSame {
            invoiceInfoDict!["area_"] = textField.text as AnyObject?
        } else if textField.placeholder?.compare("详细地址") == .orderedSame {
            invoiceInfoDict!["addr_detail_"] = textField.text as AnyObject?
        }
    }
    
    //MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.compare("\n").rawValue == 0 {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        invoiceInfoDict!["remark_"] = textView.text as AnyObject?
        if textView.text.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            textView.textColor = UIColor.black
        } else {
            textView.textColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
        }
    }
    
    //MARK: - UIAlertViewDelegate
    func alertViewCancel(_ alertView: UIAlertView) {
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            return
        }
        invoiceInfoDict!["invoice_type_"] = buttonIndex as AnyObject?
        XCGLogger.debug("\(buttonIndex)")
        descLab?.text = alertView.buttonTitle(at: buttonIndex)
        descLabText = descLab?.text
        descLab?.textColor = UIColor.black
    }
    
    func commit() {
        if invoiceInfoDict!["title_"]?.length == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "请输入发票抬头", ForDuration: 1, completion: nil)
            return
        }
        if invoiceInfoDict!["taxpayer_num_"]?.length == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "请输入纳税人号", ForDuration: 1, completion: nil)
            return
        }
        if invoiceInfoDict!["company_addr_"]?.length == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "请输入注册地址", ForDuration: 1, completion: nil)
            return
        }
        if invoiceInfoDict!["invoice_type_"]?.intValue == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "请选择发票类型", ForDuration: 1, completion: nil)
            return
        }
        if invoiceInfoDict!["user_name_"]?.length == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage:  "请输入联系人", ForDuration: 1, completion: nil)
            return
        }
        if invoiceInfoDict!["user_mobile_"]?.length == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "请输入联系电话", ForDuration: 1, completion: nil)
            return
        }
        if invoiceInfoDict!["area_"]?.length == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "请输入所在区域", ForDuration: 1, completion: nil)
            return
        }
        if invoiceInfoDict!["addr_detail_"]?.length == 0 {
            SVProgressHUD.showWainningMessage(WainningMessage: "请输入详细地址", ForDuration: 1, completion: nil)
            return
        }
        UserDefaults.standard.setValue(invoiceInfoDict, forKey:UserDefaultKeys.invoiceInfoDict)
        var oidStr = "" 
        for (index, orderInfo) in selectedOrderList!.enumerated() {
            oidStr += "\(orderInfo.order_id_)"
            if index < selectedOrderList!.count - 1 {
                oidStr += ","
            }
            let realm = try! Realm()
            let object = realm.objects(OpenTicketInfo.self).filter("order_id_ = \(orderInfo.order_id_)").first
            try! realm.write({ 
                realm.delete(object!)
            })
        }
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        invoiceInfoDict!["oid_str_"] = oidStr as AnyObject?
        SocketManager.sendData(.drawBillRequest, data: invoiceInfoDict as AnyObject?)
    }
    
    //MARK: -- DATA
    func initData() {
        invoiceInfoDict = UserDefaults.standard.value(forKey: UserDefaultKeys.invoiceInfoDict) as? [String: AnyObject]
        if invoiceInfoDict != nil {
            invoiceInfoDict!["invoice_type_"] = 0 as AnyObject?
            invoiceInfoDict!["uid_"] = DataManager.currentUser!.uid as AnyObject?
        }else{
            invoiceInfoDict =  ["oid_str_": "" as AnyObject,
                                "title_": "" as AnyObject,
                                "taxpayer_num_": "" as AnyObject,
                                "company_addr_": "" as AnyObject,
                                "invoice_type_": 0 as AnyObject,
                                "user_name_": "" as AnyObject,
                                "user_mobile_": "" as AnyObject,
                                "area_": "" as AnyObject,
                                "addr_detail_": "" as AnyObject,
                                "remarks_": "" as AnyObject,
                                "uid_": DataManager.currentUser!.uid as AnyObject]

        }
        
        
        table?.reloadData()
    }
}

