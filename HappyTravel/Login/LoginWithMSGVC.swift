//
//  LoginWithMSGVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/8.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class LoginWithMSGVC: UIViewController, UITextFieldDelegate {
    
    let tags = ["usernameField": 1001,
                "verifyCodeField": 1002,
                "nextBtn": 1003,
                "fieldUnderLine": 10040,
                "loginWithAccountBtn": 1005,
                "getVerifyCodeBtn": 1006]
    
    var username:String?
    var passwd:String?
    var verifyCode:String?
    var verifyCodeTime = 0
    var token:String?
    
    var resetPasswdVC:ResetPasswdVC?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        registerNotify()
    }
    
    func initView() {
        let bgView = UIImageView()
        bgView.userInteractionEnabled = true
        bgView.image = UIImage.init(named: "login-bg")
        view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
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
        
        let usernameField = UITextField()
        usernameField.tag = tags["usernameField"]!
        usernameField.secureTextEntry = false
        usernameField.delegate = self
        usernameField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        usernameField.rightViewMode = .WhileEditing
        usernameField.clearButtonMode = .WhileEditing
        usernameField.backgroundColor = UIColor.clearColor()
        usernameField.textAlignment = .Left
        usernameField.attributedPlaceholder = NSAttributedString.init(string: "请输入手机号码", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        view.addSubview(usernameField)
        usernameField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view).offset(60)
            make.top.equalTo(logo.snp_bottom).offset(60)
            make.right.equalTo(view).offset(-60)
            make.height.equalTo(35)
        })
        
        let verifyCodeField = UITextField()
        verifyCodeField.tag = tags["verifyCodeField"]!
        verifyCodeField.secureTextEntry = false
        verifyCodeField.delegate = self
        verifyCodeField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        verifyCodeField.rightViewMode = .WhileEditing
        verifyCodeField.clearButtonMode = .WhileEditing
        verifyCodeField.backgroundColor = UIColor.clearColor()
        verifyCodeField.textAlignment = .Left
        verifyCodeField.attributedPlaceholder = NSAttributedString.init(string: "请输入验证码", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        view.addSubview(verifyCodeField)
        
        let getVerifyCodeBtn = UIButton()
        getVerifyCodeBtn.tag = tags["getVerifyCodeBtn"]!
        getVerifyCodeBtn.backgroundColor = UIColor.clearColor()
        getVerifyCodeBtn.setTitle("发送验证码", forState: .Normal)
        getVerifyCodeBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), forState: .Normal)
        getVerifyCodeBtn.addTarget(self, action: #selector(LoginWithMSGVC.getVerifyCodeAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(getVerifyCodeBtn)
        getVerifyCodeBtn.snp_makeConstraints { (make) in
            make.right.equalTo(usernameField)
            make.top.equalTo(verifyCodeField)
            make.bottom.equalTo(verifyCodeField)
            make.width.equalTo(90)
        }
        
        verifyCodeField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(usernameField)
            make.top.equalTo(usernameField.snp_bottom).offset(20)
            make.right.equalTo(getVerifyCodeBtn.snp_left).offset(-10)
            make.height.equalTo(35)
        })
        
        for i in 0...3 {
            let fieldUnderLine = UIView()
            fieldUnderLine.tag = tags["fieldUnderLine"]! + i
            fieldUnderLine.backgroundColor = UIColor.grayColor()
            view.addSubview(fieldUnderLine)
            fieldUnderLine.snp_makeConstraints(closure: { (make) in
                if i < 2 {
                    make.left.equalTo(usernameField)
                } else {
                    make.left.equalTo(getVerifyCodeBtn)
                }
                if i == 0 || i == 2 {
                    make.right.equalTo(usernameField)
                } else if i == 1 {
                    make.right.equalTo(verifyCodeField)
                }
                make.bottom.equalTo(i == 0 ? usernameField : verifyCodeField).offset(1)
                make.height.equalTo(1)
            })
        }
        
        let nextBtn = UIButton()
        nextBtn.tag = tags["nextBtn"]!
        nextBtn.backgroundColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1)
        nextBtn.setTitle("下一步", forState: .Normal)
        nextBtn.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Normal)
        nextBtn.layer.cornerRadius = 45 / 2.0
        nextBtn.layer.masksToBounds = true
        nextBtn.addTarget(self, action: #selector(LoginWithMSGVC.nextAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(nextBtn)
        nextBtn.snp_makeConstraints { (make) in
            make.left.equalTo(usernameField)
            make.right.equalTo(usernameField)
            make.top.equalTo(verifyCodeField.snp_bottom).offset(60)
            make.height.equalTo(45)
        }
        
        let loginWithAccountBtn = UIButton()
        loginWithAccountBtn.tag = tags["loginWithAccountBtn"]!
        loginWithAccountBtn.backgroundColor = .clearColor()
        loginWithAccountBtn.setTitle("使用账号密码登录", forState: .Normal)
        loginWithAccountBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), forState: .Normal)
        loginWithAccountBtn.addTarget(self, action: #selector(LoginWithMSGVC.loginWithAccountAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(loginWithAccountBtn)
        loginWithAccountBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-60)
            make.height.equalTo(25)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let textField = view.viewWithTag(tags["usernameField"]!) {
            if !textField.exclusiveTouch {
                textField.resignFirstResponder()
            }
        }
        
        if let textField = view.viewWithTag(tags["verifyCodeField"]!) {
            if !textField.exclusiveTouch {
                textField.resignFirstResponder()
            }
        }
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginWithMSGVC.loginResult(_:)), name: NotifyDefine.LoginResult, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginWithMSGVC.verifyCodeInfoNotify(_:)), name: NotifyDefine.VerifyCodeInfo, object: nil)
    }
    
    func loginResult(notification: NSNotification?) {
        let data = notification?.userInfo!["data"]
        let err = data!.allKeys!.contains({ (key) -> Bool in
            return key as! String == "error_" ? true : false
        })
        if err {
            XCGLogger.debug("err:\(data!["error_"] as! Int)")
            return
        }
        XCGLogger.debug("\(data!)")
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginSuccessed, object: nil, userInfo: ["data": data!])
        
    }
    
    func verifyCodeInfoNotify(notification: NSNotification?) {
        if let data = notification?.userInfo!["data"] {
            verifyCodeTime = (data["timestamp_"] as? Int)!
            token = data["token_"] as? String
        }
    }
    
    func loginWithAccountAction(sender: UIButton?) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func getVerifyCodeAction(sender: UIButton) {
        let dict  = ["verify_type_": 1, "phone_num_": "15157109258"]
        SocketManager.sendData(.SendMessageVerify, data: dict)
    }
    
    func nextAction(sender: UIButton?) {
        resetPasswdVC = ResetPasswdVC()
        resetPasswdVC!.verifyCodeTime = verifyCodeTime
        resetPasswdVC!.token = token
        presentViewController(resetPasswdVC!, animated: false, completion: nil)
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["usernameField"]!:
            username = textField.text
            break
        case tags["verifyCodeField"]!:
            verifyCode = textField.text
        default:
            break
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 15 {
            return false
        }
        if let loginBtn = view.viewWithTag(tags["loginBtn"]!) as? UIButton {
            loginBtn.enabled = false
        }
        
        if textField.tag == tags["usernameField"]! {
            username = textField.text! + string
        } else if textField.tag == tags["verifyCodeField"]! {
            verifyCode = textField.text! + string
            
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
