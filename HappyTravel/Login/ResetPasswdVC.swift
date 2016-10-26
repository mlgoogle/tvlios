//
//  ResetPasswdVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/8.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class ResetPasswdVC: UIViewController, UITextFieldDelegate {
    
    let tags = ["passwdField": 1001,
                "reInPasswdField": 1002,
                "sureBtn": 1003,
                "fieldUnderLine": 10040]
    
    var passwd:String?
    var repasswd:String?
    var verifyCodeTime = 0
    var token:String?
    var verifyCode = 0
    var username:String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func initView() {
        let bgView = UIImageView()
        bgView.userInteractionEnabled = true
        bgView.image = UIImage.init(named: "login-bg")
        view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(ResetPasswdVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        bgView.addGestureRecognizer(touch)
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        bgView.addSubview(blurView)
        blurView.snp_makeConstraints { (make) in
            make.edges.equalTo(bgView)
        }
        
        let width = UIScreen.mainScreen().bounds.size.width / 3.0
        let logo = UIImageView()
        logo.backgroundColor = UIColor.grayColor()
        logo.layer.cornerRadius = width / 2.0
        logo.layer.masksToBounds = true
        logo.image = UIImage.init(named: "logo")
        view.addSubview(logo)
        logo.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(100)
            make.width.equalTo(width)
            make.height.equalTo(width)
        }
        
        let passwdField = UITextField()
        passwdField.tag = tags["passwdField"]!
        passwdField.secureTextEntry = true
        passwdField.delegate = self
        passwdField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        passwdField.rightViewMode = .WhileEditing
        passwdField.clearButtonMode = .WhileEditing
        passwdField.backgroundColor = UIColor.clearColor()
        passwdField.textAlignment = .Left
        passwdField.attributedPlaceholder = NSAttributedString.init(string: "请输入密码", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        view.addSubview(passwdField)
        passwdField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view).offset(60)
            make.top.equalTo(logo.snp_bottom).offset(60)
            make.right.equalTo(view).offset(-60)
            make.height.equalTo(35)
        })
        
        let reInPasswdField = UITextField()
        reInPasswdField.tag = tags["reInPasswdField"]!
        reInPasswdField.secureTextEntry = true
        reInPasswdField.delegate = self
        reInPasswdField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        reInPasswdField.rightViewMode = .WhileEditing
        reInPasswdField.clearButtonMode = .WhileEditing
        reInPasswdField.backgroundColor = UIColor.clearColor()
        reInPasswdField.textAlignment = .Left
        reInPasswdField.attributedPlaceholder = NSAttributedString.init(string: "请重新输入密码", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        view.addSubview(reInPasswdField)
        reInPasswdField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(passwdField)
            make.top.equalTo(passwdField.snp_bottom).offset(20)
            make.right.equalTo(passwdField)
            make.height.equalTo(35)
        })
        
        for i in 0...2 {
            let fieldUnderLine = UIView()
            fieldUnderLine.tag = tags["fieldUnderLine"]! + i
            fieldUnderLine.backgroundColor = UIColor.grayColor()
            view.addSubview(fieldUnderLine)
            fieldUnderLine.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(passwdField)
                make.right.equalTo(passwdField)
                make.bottom.equalTo(i == 0 ? passwdField : reInPasswdField).offset(1)
                make.height.equalTo(1)
            })
        }
        
        let sureBtn = UIButton()
        sureBtn.tag = tags["sureBtn"]!
        sureBtn.backgroundColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1)
        sureBtn.setTitle("确认", forState: .Normal)
        sureBtn.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Normal)
        sureBtn.layer.cornerRadius = 45 / 2.0
        sureBtn.layer.masksToBounds = true
        sureBtn.addTarget(self, action: #selector(ResetPasswdVC.sureAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(sureBtn)
        sureBtn.snp_makeConstraints { (make) in
            make.left.equalTo(passwdField)
            make.right.equalTo(passwdField)
            make.top.equalTo(reInPasswdField.snp_bottom).offset(60)
            make.height.equalTo(45)
        }
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ResetPasswdVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ResetPasswdVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ResetPasswdVC.registerAccountReply(_:)), name: NotifyDefine.RegisterAccountReply, object: nil)
    }
    
    func registerAccountReply(notification: NSNotification) {
        if let dict = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
            if dict["result"] as! Int == 0 {
                let action = UIAlertView.init(title: "注册失败", message: "账号已存在", delegate: nil, cancelButtonTitle: "确定")
                action.show()
            } else if dict["result"] as! Int == 1 {
                let loginDict = ["phone_num_": username!, "passwd_": passwd!, "user_type_": 1]
                SocketManager.sendData(.Login, data: loginDict)
                
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        var vFrame = view.frame
        if vFrame.origin.y == 0 {
            vFrame.origin.y -= frame.size.height
            view.frame = vFrame
        }
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        var vFrame = view.frame
        vFrame.origin.y = 0
        view.frame = vFrame
    }
    
    func sureAction(sender: UIButton?) {
        let dict:Dictionary<String, AnyObject>? = ["phone_num_": username!,
                                                   "passwd_": passwd!,
                                                   "user_type_": 1,
                                                   "timestamp_": verifyCodeTime,
                                                   "verify_code_": verifyCode,
                                                   "token_": token!]
        SocketManager.sendData(.RegisterAccountRequest, data: dict)
    
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["passwdField"]!:
            passwd = textField.text
            break
        case tags["reInPasswdField"]!:
            repasswd = textField.text
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
        
        if textField.tag == tags["reInPasswdField"]! {
            repasswd = textField.text! + string
        } else if textField.tag == tags["passwdField"]! {
            passwd = textField.text! + string
            
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