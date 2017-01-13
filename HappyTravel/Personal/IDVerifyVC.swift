//
//  IDVerifyVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/12.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD


class IDVerifyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var table:UITableView?
    let titles:[String]! = ["真实姓名", "身份证号码"]
    
    let tags = ["title": 1001,
                "inputView": 1002]
    
    var id:String?
    var name:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colorWithHexString("#f2f2f2")
        
        initTableView()
        hideKeyboard()
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        initNav()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: -- Nav
    func initNav()  {
        title = "身份验证"
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "提交", style: .Plain, target: self, action: #selector(rightItemTapped(_:)))
        }
        
    }
    
    func rightItemTapped(item: UIBarButtonItem) {
        view.endEditing(true)
        guard name != nil && id != nil else {
            SVProgressHUD.showWainningMessage(WainningMessage: "请完善信息", ForDuration: 1.5, completion: nil)
            return
        }
        let req = IDverifyRequestModel()
        req.uid_ = CurrentUser.uid_
        req.id_card_name = name
        req.id_card_num_ = id
        APIHelper.commonAPI().IDVerify(req, complete: { [weak self](response) in
            SVProgressHUD.showWainningMessage(WainningMessage: "提交验证信息成功", ForDuration: 1.5, completion: { () in
                self!.navigationController?.popViewControllerAnimated(true)
            })
        }, error: { (err) in
            SVProgressHUD.showWainningMessage(WainningMessage: "提交验证信息失败，请稍后再试", ForDuration: 1.5, completion: nil)
        })
    }
    
    //MARK: -- tableView
    func initTableView() {
        table = UITableView.init(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = colorWithHexString("#f2f2f2")
        table?.delegate = self
        table?.dataSource = self
        table?.rowHeight = 45
        table?.tableFooterView = UIView()
        table?.separatorStyle = .None
        view.addSubview(table!)
        table?.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("IDVerifyCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .None
            cell?.selectionStyle = .None
        }
        
        var title = cell?.contentView.viewWithTag(tags["title"]!) as? UILabel
        if title == nil {
            title = UILabel()
            title?.tag = tags["title"]!
            title?.backgroundColor = UIColor.clearColor()
            title?.font = UIFont.systemFontOfSize(S14)
            cell?.contentView.addSubview(title!)
            title?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(20)
                make.top.equalTo(5)
                make.bottom.equalTo(-5)
                make.width.equalTo(80)
            })
        }
        title?.text = titles[indexPath.section]
        
        var inputView = cell?.viewWithTag(tags["inputView"]!) as? UITextField
        if inputView == nil {
            inputView = UITextField()
            inputView?.delegate = self
            inputView?.tag = tags["inputView"]!
            inputView?.backgroundColor = UIColor.clearColor()
            cell?.contentView.addSubview(inputView!)
            inputView?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(title!.snp_right).offset(10)
                make.top.equalTo(title!)
                make.bottom.equalTo(title!)
                make.right.equalTo(cell!.contentView).offset(-20)
            })
        }
        inputView?.placeholder = "请输入" + titles[indexPath.section]
        inputView?.text = indexPath.section == 0 ? name : id
        
        return cell!
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
        table?.scrollIndicatorInsets = inset
    }
    
    func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    //MARK: - UITextField
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.placeholder == "请输入身份证号码" {
            id = textField.text
        } else {
            name = textField.text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 18 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField.placeholder == "请输入身份证号码" {
            id = nil
        } else {
            name = nil
        }
        return true
    }
}
