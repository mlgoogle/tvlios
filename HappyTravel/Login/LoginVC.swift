//
//  LoginVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/18.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class LoginVC: UIViewController, UITextFieldDelegate {
    
    let tags = ["usernameField": 1001,
                "passwdField": 1002,
                "loginBtn": 1003,
                "fieldUnderLine": 10040,
                "loginWithMSGBtn": 1005]
    
    var username:String?
    var passwd:String?
    
    var loginWithMSGVC:LoginWithMSGVC?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
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
        
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(LoginVC.touchWhiteSpace))
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
//        usernameField.text = "15157109258"
        username = usernameField.text
        
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
            make.left.equalTo(usernameField)
            make.top.equalTo(usernameField.snp_bottom).offset(20)
            make.right.equalTo(usernameField)
            make.height.equalTo(35)
        })
//        passwdField.text = "223456"
        passwd = passwdField.text
        
        for i in 0...2 {
            let fieldUnderLine = UIView()
            fieldUnderLine.tag = tags["fieldUnderLine"]! + i
            fieldUnderLine.backgroundColor = UIColor.grayColor()
            view.addSubview(fieldUnderLine)
            fieldUnderLine.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(usernameField)
                make.right.equalTo(usernameField)
                make.bottom.equalTo(i == 0 ? usernameField : passwdField).offset(1)
                make.height.equalTo(1)
            })
        }
        
        let loginBtn = UIButton()
        loginBtn.tag = tags["loginBtn"]!
        loginBtn.backgroundColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1)
        loginBtn.setTitle("登录", forState: .Normal)
        loginBtn.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Normal)
        loginBtn.layer.cornerRadius = 45 / 2.0
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: #selector(LoginVC.login(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(loginBtn)
        loginBtn.snp_makeConstraints { (make) in
            make.left.equalTo(usernameField)
            make.right.equalTo(usernameField)
            make.top.equalTo(passwdField.snp_bottom).offset(60)
            make.height.equalTo(45)
        }
        
//        let servantLoginBtn = UIButton()
//        servantLoginBtn.tag = 20001
//        servantLoginBtn.backgroundColor = .clearColor()
//        servantLoginBtn.setTitle("服务者登录", forState: .Normal)
//        servantLoginBtn.setTitleColor(UIColor.init(red: 0/255.0, green: 120/255.0, blue: 200/255.0, alpha: 1), forState: .Normal)
//        servantLoginBtn.layer.borderColor = UIColor.init(red: 0/255.0, green: 120/255.0, blue: 200/255.0, alpha: 1).CGColor
//        servantLoginBtn.layer.borderWidth = 1
//        servantLoginBtn.layer.cornerRadius = 5
//        servantLoginBtn.layer.masksToBounds = true
//        servantLoginBtn.addTarget(self, action: #selector(LoginVC.login(_:)), forControlEvents: .TouchUpInside)
//        view.addSubview(servantLoginBtn)
//        servantLoginBtn.snp_makeConstraints { (make) in
//            make.centerX.equalTo(view)
//            make.top.equalTo(loginBtn.snp_bottom).offset(5)
//            make.width.equalTo(100)
//            make.height.equalTo(25)
//        }
        
        let loginWithMSGBtn = UIButton()
        loginWithMSGBtn.tag = tags["loginWithMSGBtn"]!
        loginWithMSGBtn.backgroundColor = .clearColor()
        loginWithMSGBtn.setTitle("使用手机短信登录", forState: .Normal)
        loginWithMSGBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), forState: .Normal)
        loginWithMSGBtn.addTarget(self, action: #selector(LoginVC.login(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(loginWithMSGBtn)
        loginWithMSGBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-60)
            make.height.equalTo(25)
        }
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.loginResult(_:)), name: NotifyDefine.LoginResult, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
    
    func login(sender: UIButton?) {
        var dict:Dictionary<String, AnyObject>?
        
        if sender?.tag == tags["loginBtn"]! {
            dict = ["phone_num_": username!, "passwd_": passwd!, "user_type_": 1]
        } else if sender?.tag == 20001 {
            dict = ["phone_num_": "15158110001", "passwd_": "123456", "user_type_": 2]
        } else if sender?.tag == tags["loginWithMSGBtn"]! {
            loginWithMSGVC = LoginWithMSGVC()
            presentViewController(loginWithMSGVC!, animated: false, completion: nil)
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: CommonDefine.UserName)
        NSUserDefaults.standardUserDefaults().setObject(passwd, forKey: CommonDefine.Passwd)
        NSUserDefaults.standardUserDefaults().setObject("\(dict!["user_type_"]!)", forKey: CommonDefine.UserType)
        
        SocketManager.sendData(.Login, data: dict)
        
        
    }
    
    func randomSmallCaseString(length: Int) -> String {
        var output = ""
        
        for _ in 0..<length {
            let randomNumber = arc4random() % 26 + 97
            let randomChar = Character(UnicodeScalar(randomNumber))
            output.append(randomChar)
        }
        return output
    }
    
    func loginResult(notification: NSNotification?) {
        let data = notification?.userInfo!["data"]
        let err = data!.allKeys!.contains({ (key) -> Bool in
            return key as! String == "error_" ? true : false
        })
        if err {
            XCGLogger.error("err:\(data!["error_"] as! Int)")
            return
        }
        XCGLogger.debug("\(data!)")
    
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginSuccessed, object: nil, userInfo: ["data": data!])
        
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["usernameField"]!:
            username = textField.text
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
        
        if textField.tag == tags["usernameField"]! {
            username = textField.text! + string
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
