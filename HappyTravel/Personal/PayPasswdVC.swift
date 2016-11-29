//
//  PayPasswdVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/11/29.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD

enum PayPasswdStatus : Int {
    case NotSetup = -1
    case AlreadySet = 1
}

class PayPasswdVC : UIViewController, UITextFieldDelegate {
    
    // 0: 未设置过支付密码 1: 已设置过支付密码
    var payPasswdStatus:PayPasswdStatus = .NotSetup
    
    var step = 0
    
    var oldPasswd:String?
    
    var newPasswd:String?
    
    var tipsLable:UILabel?
    
    let tips = ["请输入旧的支付密码",
                "请输入新的支付密码",
                "请再次输入新的支付密码"]
    
    var textField:UITextField?
    
    let tags = ["passwdBtn": 1001]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = payPasswdStatus == .NotSetup ? "设置支付密码" : "重新设置支付密码"
        view.backgroundColor = colorWithHexString("#f2f2f2")
        
        step = payPasswdStatus == .NotSetup ? 1 : 0
        
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func registerNotify() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(passwdVerifyReply(_:)), name: NotifyDefine.PasswdVerifyReply, object: nil)
        notificationCenter.addObserver(self, selector: #selector(passwdVerifyReplyError(_:)), name: NotifyDefine.PasswdVerifyReplyError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setupPaymentCodeReply(_:)), name: NotifyDefine.SetupPaymentCodeReply, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setupPaymentCodeReplyError(_:)), name: NotifyDefine.SetupPaymentCodeReplyError, object: nil)
    }
    
    func passwdVerifyReply(notification: NSNotification) {
        textField?.text = ""
        for i in 0...5 {
            if let btn = view.viewWithTag(tags["passwdBtn"]! * 10 + i) as? UIButton {
                btn.setTitle("", forState: .Normal)
            }
        }
        step += 1
        tipsLable?.text = tips[step]
    }
    
    func passwdVerifyReplyError(notification: NSNotification) {
        if let err = notification.userInfo!["err"] as? [Int: String] {
            SVProgressHUD.showWainningMessage(WainningMessage: err.values.first!, ForDuration: 1.5, completion: nil)
            textField?.text = ""
            for i in 0...5 {
                if let btn = view.viewWithTag(tags["passwdBtn"]! * 10 + i) as? UIButton {
                    btn.setTitle("", forState: .Normal)
                }
            }
        }
    }
    
    func setupPaymentCodeReply(notification: NSNotification) {
        weak var weakSelf = self
        SVProgressHUD.showWainningMessage(WainningMessage: "支付密码设置成功", ForDuration: 1.5, completion: { () in
            weakSelf?.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    func setupPaymentCodeReplyError(notification: NSNotification) {
        if let err = notification.userInfo!["err"] as? [Int: String] {
            SVProgressHUD.showWainningMessage(WainningMessage: err.values.first!, ForDuration: 1.5, completion: nil)
            textField?.text = ""
            for i in 0...5 {
                if let btn = view.viewWithTag(tags["passwdBtn"]! * 10 + i) as? UIButton {
                    btn.setTitle("", forState: .Normal)
                }
            }
            step = payPasswdStatus == .NotSetup ? 1 : 0
            tipsLable?.text = tips[step]
        }
    }
    
    func initView() {
        textField = UITextField.init(frame: CGRectZero)
        textField?.backgroundColor = UIColor.clearColor()
        textField?.delegate = self
        textField?.keyboardType = .NumberPad
        view.addSubview(textField!)
        textField?.becomeFirstResponder()
        
        tipsLable = UILabel()
        tipsLable?.backgroundColor = UIColor.clearColor()
        tipsLable?.font = UIFont.systemFontOfSize(16)
        view.addSubview(tipsLable!)
        tipsLable?.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(AtapteHeightValue(146))
        })
        tipsLable?.text = tips[step]
        
        let passwdBoxBGView = UIImageView()
        passwdBoxBGView.image = UIImage.init(named: "passwd_box")
        view.addSubview(passwdBoxBGView)
        passwdBoxBGView.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(tipsLable!.snp_bottom).offset(AtapteHeightValue(40))
            make.width.equalTo(AtapteWidthValue(45)*6)
            make.height.equalTo(AtapteHeightValue(40))
        })
        
        for i in 0...5 {
            let btn = UIButton()
            btn.tag = tags["passwdBtn"]! * 10 + i
            btn.backgroundColor = UIColor.clearColor()
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.setTitle("", forState: .Normal)
            view.addSubview(btn)
            btn.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(passwdBoxBGView).offset(AtapteWidthValue(45)*CGFloat(i))
                make.top.equalTo(passwdBoxBGView)
                make.width.equalTo(AtapteWidthValue(45))
                make.bottom.equalTo(passwdBoxBGView)
            })
        }
        
    }
    
    func nextStep() {
        if step == 0 || step == 1 {
            oldPasswd = textField?.text
            let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)!,
                                            "passwd_": oldPasswd!,
                                            "passwd_type_": 1]
            SocketManager.sendData(.PasswdVerifyRequest, data: dict)
        } else if step == 1 {
            newPasswd = textField?.text
            textField?.text = ""
            for i in 0...5 {
                if let btn = view.viewWithTag(tags["passwdBtn"]! * 10 + i) as? UIButton {
                    btn.setTitle("", forState: .Normal)
                }
            }
            step += 1
            tipsLable?.text = tips[step]
        } else if step == 2 {
            if textField?.text == newPasswd {
                let changeType = DataManager.currentUser?.has_passwd_ == -1 ? 0 : 1
                let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)!,
                                                "new_passwd_": newPasswd!,
                                                "old_passwd_": oldPasswd!,
                                                "passwd_type_": 1,
                                                "change_type_": changeType]
                SocketManager.sendData(.SetupPaymentCodeRequest, data: dict)
                XCGLogger.info("\(oldPasswd ?? "status:\(payPasswdStatus)") <=> \(newPasswd!)")
            } else {
                weak var weakSelf = self
                let alert = UIAlertController.init(title: "错误", message: "两次输入的新密码不一致", preferredStyle: .Alert)
                let reset = UIAlertAction.init(title: "重新设置新密码", style: .Default, handler: { (action) in
                    weakSelf?.textField?.text = ""
                    for i in 0...5 {
                        if let btn = weakSelf?.view.viewWithTag((weakSelf?.tags["passwdBtn"]!)! * 10 + i) as? UIButton {
                            btn.setTitle("", forState: .Normal)
                        }
                    }
                    weakSelf?.step = 1
                    weakSelf?.tipsLable?.text = weakSelf?.tips[(weakSelf?.step)!]
                })
                let inputAgain = UIAlertAction.init(title: "重新输入", style: .Default, handler: { (action) in
                    weakSelf?.textField?.text = ""
                    for i in 0...5 {
                        if let btn = weakSelf?.view.viewWithTag((weakSelf?.tags["passwdBtn"]!)! * 10 + i) as? UIButton {
                            btn.setTitle("", forState: .Normal)
                        }
                    }
                })
                alert.addAction(reset)
                alert.addAction(inputAgain)
                weakSelf?.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    //MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location < 6 {
            if let btn = view.viewWithTag(tags["passwdBtn"]! * 10 + range.location) as? UIButton {
                btn.setTitle(string, forState: .Normal)
                weak var weakSelf = self
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.25)), dispatch_get_main_queue(), { () in
                    if range.location == 5 && string != "" {
                        btn.setTitle("*", forState: .Normal)
                        weakSelf?.nextStep()
                    } else {
                        btn.setTitle(string == "" ? "" : "*", forState: .Normal)
                    }
                    
                })
            }
            return true
        }
        return false
    }
    
}
