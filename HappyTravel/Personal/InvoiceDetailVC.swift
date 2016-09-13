//
//  InvoiceDetailVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class InvoiceDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var table:UITableView?
    var messageInfo:Array<UserInfo>? = []
    var segmentIndex = 0
    
    let tags = ["titleLab_Invoice": 1001,
                "textField_Invoice": 1002,
                "titleLab_Personal": 1003,
                "textField_Personal": 1004,
                "descLab_Invoice": 1008,
                "textView_Personal": 1005,
                "commitBtn": 1006,
                "bottomLine": 1007]
    
    let invoiceInfo = ["发票抬头",
                       "纳税人号",
                       "注册地址",
                       "注册电话",
                       "开户银行",
                       "银行账号",
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
            }
            descLab?.text = invoiceInfo[indexPath.row]
        } else {
            cell?.accessoryType = .None
            var textField = cell?.contentView.viewWithTag(tags["textField_Invoice"]!) as? UITextField
            if textField == nil {
                textField = UITextField()
                textField?.tag = tags["textField_Invoice"]!
                textField?.secureTextEntry = true
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
            
        } else {
            var textField = cell?.contentView.viewWithTag(tags["textField_Invoice"]!) as? UITextField
            if textField == nil {
                textField = UITextField()
                textField?.tag = tags["textField_Invoice"]!
                textField?.secureTextEntry = true
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
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == invoiceInfo.count - 1 {
            let action = UIAlertView.init(title: "选择发票类型", message: "", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "差旅费", "文体用品", "餐饮发票", "其他")
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
    
    func segmentChange(sender: AnyObject?) {
        segmentIndex = (sender?.selectedSegmentIndex)!
        table?.reloadData()
    }
    
}

