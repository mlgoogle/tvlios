
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
class InvoiceDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate {
    
    var table:UITableView?
    var selectedOrderList:List<TicketModel>?
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
//    var drawModel:DrawBillBaseInfo?
    
    let invoiceInfo = ["发票抬头",
                       "纳税人号",
                       "注册地址",
                       "发票类型"]
    
    let personalInfo = ["联 系 人",
                        "联系电话",
                        "所在区域",
                        "详细地址",
                        "备注信息"]
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        view.backgroundColor = UIColor.redColor()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceDetailVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InvoiceDetailVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
            titleLab?.font = UIFont.systemFontOfSize(S15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.top.equalTo(cell!.contentView).offset(15)
                make.bottom.equalTo(cell!.contentView).offset(-15)
                make.width.equalTo(AtapteWidthValue(65))
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
                descLab?.font = UIFont.systemFontOfSize(S15)
                cell?.contentView.addSubview(descLab!)
                descLab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.top.equalTo(titleLab!)
                    make.bottom.equalTo(titleLab!)
                })
                self.descLab = descLab
            }
            descLab?.text = descLabText ?? invoiceInfo[indexPath.row]
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
                textField?.font = UIFont.systemFontOfSize(S15)
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
                textField?.text = invoiceInfoDict!["title_"] as? String
//                  textField?.text = drawModel?.title_
            } else if textField?.placeholder?.compare("纳税人号") == .OrderedSame {
                textField?.text = invoiceInfoDict!["taxpayer_num_"] as? String
//                textField?.text = drawModel?.taxpayer_num_
            } else if textField?.placeholder?.compare("注册地址") == .OrderedSame {
                textField?.text = invoiceInfoDict!["company_addr_"] as? String
//                textField?.text = drawModel?.company_addr_
            } else if textField?.placeholder?.compare("联 系 人") == .OrderedSame {
                textField?.text = invoiceInfoDict!["user_name_"] as? String
//                textField?.text = drawModel?.user_name_
            } else if textField?.placeholder?.compare("联系电话") == .OrderedSame {
                textField?.text = invoiceInfoDict!["user_mobile_"] as? String
//                textField?.text = drawModel?.user_mobile_
                textField?.keyboardType = .PhonePad
            } else if textField?.placeholder?.compare("所在区域") == .OrderedSame {
                textField?.text = invoiceInfoDict!["area_"] as? String
//                textField?.text = drawModel?.area_
            } else if textField?.placeholder?.compare("详细地址") == .OrderedSame {
                textField?.text = invoiceInfoDict!["addr_detail_"] as? String
//                textField?.text = drawModel?.addr_detail_
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
            titleLab?.font = UIFont.systemFontOfSize(S15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints(closure: { (make) in
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
                textView?.font = UIFont.systemFontOfSize(S15)
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
            
//            textView?.text = drawModel?.remarks_
            textView?.text = invoiceInfoDict!["remark_"] as? String
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
                textField?.font = UIFont.systemFontOfSize(S15)
                cell?.contentView.addSubview(textField!)
                textField?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!.snp_right).offset(10)
                    make.top.equalTo(cell!.contentView).offset(15)
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
                textField?.text = invoiceInfoDict!["title_"] as? String
//                textField?.text = drawModel?.title_
            } else if textField?.placeholder?.compare("纳税人号") == .OrderedSame {
                textField?.text = invoiceInfoDict!["taxpayer_num_"] as? String
//                textField?.text = drawModel?.taxpayer_num_
            } else if textField?.placeholder?.compare("注册地址") == .OrderedSame {
                textField?.text = invoiceInfoDict!["company_addr_"] as? String
//                textField?.text = drawModel?.company_addr_
            } else if textField?.placeholder?.compare("联 系 人") == .OrderedSame {
                textField?.text = invoiceInfoDict!["user_name_"] as? String
//                textField?.text = drawModel?.user_name_
            } else if textField?.placeholder?.compare("联系电话") == .OrderedSame {
                textField?.text = invoiceInfoDict!["user_mobile_"] as? String
//                textField?.text = drawModel?.user_mobile_
                textField?.keyboardType = .PhonePad
            } else if textField?.placeholder?.compare("所在区域") == .OrderedSame {
                textField?.text = invoiceInfoDict!["area_"] as? String
//                textField?.text = drawModel?.area_
            } else if textField?.placeholder?.compare("详细地址") == .OrderedSame {
                textField?.text = invoiceInfoDict!["addr_detail_"] as? String
//                textField?.text = drawModel?.addr_detail_
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
            invoiceInfoDict!["title_"] = textField.text
//            drawModel!.title_ = textField.text
        } else if textField.placeholder?.compare("纳税人号") == .OrderedSame {
            invoiceInfoDict!["taxpayer_num_"] = textField.text
//            drawModel!.taxpayer_num_ = textField.text
        } else if textField.placeholder?.compare("注册地址") == .OrderedSame {
            invoiceInfoDict!["company_addr_"] = textField.text
//            drawModel!.company_addr_ = textField.text
        } else if textField.placeholder?.compare("联 系 人") == .OrderedSame {
            invoiceInfoDict!["user_name_"] = textField.text
//            drawModel!.user_name_ = textField.text
        } else if textField.placeholder?.compare("联系电话") == .OrderedSame {
            invoiceInfoDict!["user_mobile_"] = textField.text
//            drawModel!.user_mobile_ = textField.text
        } else if textField.placeholder?.compare("所在区域") == .OrderedSame {
            invoiceInfoDict!["area_"] = textField.text
//            drawModel!.area_ = textField.text
        } else if textField.placeholder?.compare("详细地址") == .OrderedSame {
            invoiceInfoDict!["addr_detail_"] = textField.text
//            drawModel!.addr_detail_ = textField.text
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
        invoiceInfoDict!["remark_"] = textView.text
//        drawModel!.remarks_ = textView.text
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
        if buttonIndex == 0 {
            return
        }
        invoiceInfoDict!["invoice_type_"] = buttonIndex
//        drawModel!.invoice_type_ = buttonIndex
        XCGLogger.debug("\(buttonIndex)")
        descLab?.text = alertView.buttonTitleAtIndex(buttonIndex)
        descLabText = descLab?.text
        descLab?.textColor = UIColor.blackColor()
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
        if invoiceInfoDict!["invoice_type_"]?.integerValue == 0 {
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
        NSUserDefaults.standardUserDefaults().setValue(invoiceInfoDict, forKey: UserDefaultKeys.invoiceInfoDict)
        var oidStr = ""
        for (index, orderInfo) in selectedOrderList!.enumerate() {
            oidStr +=  index == 0 ? "\(orderInfo.order_id_)" : ",\(orderInfo.order_id_)"
//            let realm = try! Realm()
//            let object = realm.objects(OpenTicketInfo.self).filter("order_id_ = \(orderInfo.order_id_)").first
//            try! realm.write({
//                realm.delete(object!)
//            })
        }
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        
        let model = DrawBillBaseInfo()
        model.oid_str_ = oidStr
        model.title_ = invoiceInfoDict!["title_"] as? String
        model.taxpayer_num_ = invoiceInfoDict!["taxpayer_num_"] as? String
        model.company_addr_ = invoiceInfoDict!["company_addr_"] as? String
        model.invoice_type_ = (invoiceInfoDict!["invoice_type_"] as? Int)!
        model.user_name_ = invoiceInfoDict!["user_name_"] as? String
        model.user_mobile_ = invoiceInfoDict!["user_mobile_"] as? String
        model.area_ = invoiceInfoDict!["area_"] as? String
        model.addr_detail_ = invoiceInfoDict!["addr_detail_"] as? String
        model.remarks_ = invoiceInfoDict!["remarks_"] as? String
        unowned let weakSelf = self
        APIHelper.consumeAPI().drawBillInfo(model, complete: { (response) in
            SVProgressHUD.dismiss()
            if let model = response as? DrawBillModel {
                if  let _ = model.oid_str_ {
                    let alert = UIAlertController.init(title: "发票状态", message: "发票信息审核中", preferredStyle: .Alert)
                    let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    
                    alert.addAction(action)
                    weakSelf.presentViewController(alert, animated: true, completion: nil)
                }
            }
            }, error: { (err) in
                let wainning = SocketRequest.errorString(err.code)
                SVProgressHUD.showWainningMessage(WainningMessage: wainning, ForDuration: 1.5, completion: nil)
        })
    
    }
    
    //MARK: -- DATA
    func initData() {
        
////        drawModel = DataManager.getData(DrawBillBaseInfo.self)?.first
//        drawModel = NSUserDefaults.standardUserDefaults().valueForKey(DrawBillBaseInfo.className()) as? DrawBillBaseInfo
//        if drawModel != nil {
////            let realm = try! Realm()
////            try! realm.write({ ()in
//////                drawModel!.invoice_type_ = 0
////            })
//            
////            drawModel!.uid_ = Int64(CurrentUser.uid_)
//        } else {
//            drawModel = DrawBillBaseInfo()
//        }
        
        invoiceInfoDict = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultKeys.invoiceInfoDict) as? [String: AnyObject]
        if invoiceInfoDict != nil {
            invoiceInfoDict!["invoice_type_"] = 0
            invoiceInfoDict!["uid_"] = CurrentUser.uid_
        }else{
            invoiceInfoDict =  ["oid_str_": "",
                                "title_": "",
                                "taxpayer_num_": "",
                                "company_addr_": "",
                                "invoice_type_": 0,
                                "user_name_": "",
                                "user_mobile_": "",
                                "area_": "",
                                "addr_detail_": "",
                                "remarks_": "",
                                "uid_": CurrentUser.uid_]

        }
        
        
        table?.reloadData()
    }
}

