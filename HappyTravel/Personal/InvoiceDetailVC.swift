//
//  InvoiceDetailVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class InvoiceDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate {
    
    var table:UITableView?
    var selectedOrderList:Dictionary<Int, HodometerInfo> = [:]
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
    
    var invoiceInfoDict = ["order_id_": -1,
                           "title_": "",
                           "taxpayer_num_": "",
                           "company_addr_": "",
                           "invoice_type_": 0,
                           
                           "user_name_": "",
                           "user_mobile_": "",
                           "area_": "",
                           "addr_detail_": "",
                           "remarks_": ""]
    
    let invoiceInfo = ["发票抬头",
                       "纳税人号",
                       "注册地址",
                       "发票类型"]
    
    let personalInfo = ["联 系 人",
                        "联系电话",
                        "所在区域",
                        "详细地址",
                        "备注信息"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "开票信息设置"
        
        initView()
        
        registerNotify()
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(InvoiceCell.self, forCellReuseIdentifier: "InvoiceCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceDetailVC.drawBillReply(_:)), name: NotifyDefine.DrawBillReply, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceDetailVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceDetailVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func drawBillReply(notification: NSNotification?) {
        if let dict = notification?.userInfo!["data"] as? Dictionary<String, AnyObject> {
            if dict["invoice_status_"] as! Int == 0 {
                
                let alert = UIAlertController.init(title: "发票状态", message: "发票信息审核中", preferredStyle: .Alert)
                
                let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    // MARK: - UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return invoiceInfo.count
        } else if section == 1 {
            return personalInfo.count
        } else {
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return invoiceInfoCell(tableView, indexPath: indexPath)
        } else if indexPath.section == 1 {
            return personalInfoCell(tableView, indexPath: indexPath)
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("CommitButton")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.contentView.userInteractionEnabled = true
                cell?.userInteractionEnabled = true
                cell?.selectionStyle = .None
                cell?.backgroundColor = UIColor.clearColor()
                cell?.contentView.backgroundColor = UIColor.clearColor()
            }
            
            var commitBtn = cell?.contentView.viewWithTag(tags["commitBtn"]!) as? UIButton
            if commitBtn == nil {
                commitBtn = UIButton()
                commitBtn?.tag = tags["commitBtn"]!
                commitBtn?.setTitle("提交", forState: .Normal)
                commitBtn?.backgroundColor = UIColor.init(decR: 11, decG: 19, decB: 31, a: 1)
                commitBtn?.layer.cornerRadius = 5
                commitBtn?.layer.masksToBounds = true
                commitBtn?.addTarget(self, action: #selector(InvoiceDetailVC.commit), forControlEvents: .TouchUpInside)
                cell?.contentView.addSubview(commitBtn!)
                commitBtn?.snp_makeConstraints(closure: { (make) in
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
                bottomLine?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(commitBtn!)
                    make.bottom.equalTo(cell!.contentView)
                    make.right.equalTo(cell!.contentView)
                    make.height.equalTo(1)
                })
                
            }
            bottomLine?.hidden = true

            return cell!
        }
        
    }
    
    func invoiceInfoCell(tableView:UITableView, indexPath: NSIndexPath) ->UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("InvoiceInfo")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .None
            cell?.contentView.userInteractionEnabled = true
            cell?.userInteractionEnabled = true
            cell?.selectionStyle = .None
        }
        
        var titleLab = cell?.contentView.viewWithTag(tags["titleLab_Invoice"]!) as? UILabel
        if titleLab == nil {
            titleLab = UILabel()
            titleLab?.tag = tags["titleLab_Invoice"]!
            titleLab?.backgroundColor = UIColor.clearColor()
            titleLab?.textAlignment = .Right
            titleLab?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView).offset(15)
                make.bottom.equalTo(cell!.contentView).offset(-15)
                make.width.equalTo(60)
            })
        }
        titleLab?.text = invoiceInfo[indexPath.row]
        
        if indexPath.row == invoiceInfo.count - 1 {
            cell?.accessoryType = .DisclosureIndicator
            var descLab = cell?.contentView.viewWithTag(tags["descLab_Invoice"]!) as? UILabel
            if descLab == nil {
                descLab = UILabel()
                descLab?.tag = tags["descLab_Invoice"]!
                descLab?.backgroundColor = UIColor.clearColor()
                descLab?.textAlignment = .Left
                descLab?.textColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
                descLab?.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(descLab!)
                descLab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.top.equalTo(titleLab!)
                    make.bottom.equalTo(titleLab!)
                })
                self.descLab = descLab
            }
            descLab?.text = descLabText == nil ? invoiceInfo[indexPath.row] : descLabText
        } else {
            cell?.accessoryType = .None
            var textField = cell?.contentView.viewWithTag(tags["textField_Invoice"]!) as? UITextField
            if textField == nil {
                textField = UITextField()
                textField?.tag = tags["textField_Invoice"]!
                textField?.secureTextEntry = false
                textField?.delegate = self
                textField?.rightViewMode = .WhileEditing
                textField?.clearButtonMode = .WhileEditing
                cell?.contentView.addSubview(textField!)
                textField?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                })
            }
            textField?.placeholder = invoiceInfo[indexPath.row]
            if textField?.placeholder?.compare("发票抬头") == .OrderedSame {
                textField?.text = invoiceInfoDict["title_"] as? String
            } else if textField?.placeholder?.compare("纳税人号") == .OrderedSame {
                textField?.text = invoiceInfoDict["taxpayer_num_"] as? String
            } else if textField?.placeholder?.compare("注册地址") == .OrderedSame {
                textField?.text = invoiceInfoDict["company_addr_"] as? String
            } else if textField?.placeholder?.compare("联 系 人") == .OrderedSame {
                textField?.text = invoiceInfoDict["user_name_"] as? String
            } else if textField?.placeholder?.compare("联系电话") == .OrderedSame {
                textField?.text = invoiceInfoDict["user_mobile_"] as? String
                textField?.keyboardType = .PhonePad
            } else if textField?.placeholder?.compare("所在区域") == .OrderedSame {
                textField?.text = invoiceInfoDict["area_"] as? String
            } else if textField?.placeholder?.compare("详细地址") == .OrderedSame {
                textField?.text = invoiceInfoDict["addr_detail_"] as? String
            }
        }
        
        var bottomLine = cell?.contentView.viewWithTag(tags["bottomLine"]!)
        if bottomLine == nil {
            bottomLine = UIView()
            bottomLine?.tag = tags["bottomLine"]!
            bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
            cell?.contentView.addSubview(bottomLine!)
            bottomLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
            })
        }
        bottomLine?.hidden = (indexPath.row == invoiceInfo.count - 1 ? true : false)
        
        return cell!
    }
    
    func personalInfoCell(tableView:UITableView, indexPath: NSIndexPath) ->UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PersonalInfo")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .None
            cell?.contentView.userInteractionEnabled = true
            cell?.userInteractionEnabled = true
            cell?.selectionStyle = .None
        }
        
        var titleLab = cell?.contentView.viewWithTag(tags["titleLab_Personal"]!) as? UILabel
        if titleLab == nil {
            titleLab = UILabel()
            titleLab?.tag = tags["titleLab_Personal"]!
            titleLab?.backgroundColor = UIColor.clearColor()
            titleLab?.textAlignment = .Right
            titleLab?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView).offset(15)
                make.width.equalTo(60)
            })
        }
        titleLab?.text = personalInfo[indexPath.row]
        
        var bottomLine = cell?.contentView.viewWithTag(tags["bottomLine"]!)
        if bottomLine == nil {
            bottomLine = UIView()
            bottomLine?.tag = tags["bottomLine"]!
            bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
            cell?.contentView.addSubview(bottomLine!)
            bottomLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
            })
        }
        bottomLine?.hidden = (indexPath.row == personalInfo.count - 1 ? true : false)
        
        if indexPath.row == personalInfo.count - 1 {
            var textView = cell?.contentView.viewWithTag(tags["textView_Personal"]!) as? UITextView
            if textView == nil {
                textView = UITextView()
                textView?.delegate = self
                textView?.tag = tags["textView_Personal"]!
                textView?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
                textView?.textAlignment = .Left
                textView?.textColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
                textView?.font = UIFont.systemFontOfSize(15)
                textView?.layer.cornerRadius = 5
                textView?.layer.masksToBounds = true
                cell?.contentView.addSubview(textView!)
                textView?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.top.equalTo(titleLab!)
                    make.height.equalTo(80)
                })
            }
            
            bottomLine?.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
                make.top.equalTo(textView!.snp_bottom).offset(10)
            })
            
            textView?.text = invoiceInfoDict["remark_"] as? String
            if textView?.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                textView?.textColor = UIColor.blackColor()
            }
            
            
        } else {
            var textField = cell?.contentView.viewWithTag(tags["textField_Invoice"]!) as? UITextField
            if textField == nil {
                textField = UITextField()
                textField?.tag = tags["textField_Invoice"]!
                textField?.secureTextEntry = false
                textField?.delegate = self
                textField?.rightViewMode = .WhileEditing
                textField?.clearButtonMode = .WhileEditing
                cell?.contentView.addSubview(textField!)
                textField?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                })
            }
            textField?.placeholder = personalInfo[indexPath.row]
            
            bottomLine?.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView)
                make.right.equalTo(cell!.contentView)
                make.height.equalTo(1)
            })
            
            if textField?.placeholder?.compare("发票抬头") == .OrderedSame {
                textField?.text = invoiceInfoDict["title_"] as? String
            } else if textField?.placeholder?.compare("纳税人号") == .OrderedSame {
                textField?.text = invoiceInfoDict["taxpayer_num_"] as? String
            } else if textField?.placeholder?.compare("注册地址") == .OrderedSame {
                textField?.text = invoiceInfoDict["company_addr_"] as? String
            } else if textField?.placeholder?.compare("联 系 人") == .OrderedSame {
                textField?.text = invoiceInfoDict["user_name_"] as? String
            } else if textField?.placeholder?.compare("联系电话") == .OrderedSame {
                textField?.text = invoiceInfoDict["user_mobile_"] as? String
                textField?.keyboardType = .PhonePad
            } else if textField?.placeholder?.compare("所在区域") == .OrderedSame {
                textField?.text = invoiceInfoDict["area_"] as? String
            } else if textField?.placeholder?.compare("详细地址") == .OrderedSame {
                textField?.text = invoiceInfoDict["addr_detail_"] as? String
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == invoiceInfo.count - 1 {
            let action = UIAlertView.init(title: "选择发票类型", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "差旅费", "文体用品", "餐饮发票", "其他")
            action.show()
            
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else if section == 1 {
            return 10
        } else {
            return 40
        }
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.placeholder?.compare("发票抬头") == .OrderedSame {
            invoiceInfoDict["title_"] = textField.text
        } else if textField.placeholder?.compare("纳税人号") == .OrderedSame {
            invoiceInfoDict["taxpayer_num_"] = textField.text
        } else if textField.placeholder?.compare("注册地址") == .OrderedSame {
            invoiceInfoDict["company_addr_"] = textField.text
        } else if textField.placeholder?.compare("联 系 人") == .OrderedSame {
            invoiceInfoDict["user_name_"] = textField.text
        } else if textField.placeholder?.compare("联系电话") == .OrderedSame {
            invoiceInfoDict["user_mobile_"] = textField.text
        } else if textField.placeholder?.compare("所在区域") == .OrderedSame {
            invoiceInfoDict["area_"] = textField.text
        } else if textField.placeholder?.compare("详细地址") == .OrderedSame {
            invoiceInfoDict["addr_detail_"] = textField.text
        }
    }
    
    //MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.compare("\n").rawValue == 0 {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        invoiceInfoDict["remark_"] = textView.text
        if textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            textView.textColor = UIColor.blackColor()
        } else {
            textView.textColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
        }
    }
    
    //MARK: - UIAlertViewDelegate
    func alertViewCancel(alertView: UIAlertView) {
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        invoiceInfoDict["invoice_type_"] = buttonIndex
        XCGLogger.debug("\(buttonIndex)")
        descLab?.text = alertView.buttonTitleAtIndex(buttonIndex)
        descLabText = descLab?.text
        descLab?.textColor = UIColor.blackColor()
    }
    
    func commit() {
        for (order_id_, _) in selectedOrderList {
            invoiceInfoDict["order_id_"] = order_id_
            SocketManager.sendData(.DrawBillRequest, data: invoiceInfoDict)
        }
    }
}

