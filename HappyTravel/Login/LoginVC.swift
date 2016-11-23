//
//  LoginVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/18.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
class LoginVC: UIViewController, UITextFieldDelegate {
    
    let tags = ["usernameField": 1001,
                "passwdField": 1002,
                "loginBtn": 1003,
                "fieldUnderLine": 10040,
                "loginWithMSGBtn": 1005]
    
    var username:String?
    var passwd:String?
    
    var loginWithMSGVC:LoginWithMSGVC?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        initView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
        NotificationCenter.default.removeObserver(self)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func initView() {
        let bgView = UIImageView()
        bgView.isUserInteractionEnabled = true
        bgView.image = UIImage.init(named: "login-bg")
        view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(LoginVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        bgView.addGestureRecognizer(touch)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        bgView.addSubview(blurView)
        blurView.snp_makeConstraints { (make) in
            make.edges.equalTo(bgView)
        }
        
        let width = UIScreen.main.bounds.size.width / 3.0
        let logo = UIImageView()
        logo.backgroundColor = UIColor.gray
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
        usernameField.isSecureTextEntry = false
        usernameField.delegate = self
        usernameField.textColor = UIColor.white.withAlphaComponent(0.5)
        usernameField.rightViewMode = .whileEditing
        usernameField.clearButtonMode = .whileEditing
        usernameField.backgroundColor = UIColor.clear
        usernameField.textAlignment = .left
        usernameField.keyboardType = .numberPad
        usernameField.attributedPlaceholder = NSAttributedString.init(string: "请输入手机号码", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        view.addSubview(usernameField)
        usernameField.snp_makeConstraints({ (make) in
            make.left.equalTo(view).offset(60)
            make.top.equalTo(logo.snp_bottom).offset(60)
            make.right.equalTo(view).offset(-60)
            make.height.equalTo(35)
        })

        
        let passwdField = UITextField()
        passwdField.tag = tags["passwdField"]!
        passwdField.isSecureTextEntry = true
        passwdField.delegate = self
        passwdField.textColor = UIColor.white.withAlphaComponent(0.5)
        passwdField.rightViewMode = .whileEditing
        passwdField.clearButtonMode = .whileEditing
        passwdField.backgroundColor = UIColor.clear
        passwdField.textAlignment = .left
        passwdField.attributedPlaceholder = NSAttributedString.init(string: "请输入密码", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        view.addSubview(passwdField)
        passwdField.snp_makeConstraints({ (make) in
            make.left.equalTo(usernameField)
            make.top.equalTo(usernameField.snp_bottom).offset(20)
            make.right.equalTo(usernameField)
            make.height.equalTo(35)
        })
        
        for i in 0...2 {
            let fieldUnderLine = UIView()
            fieldUnderLine.tag = tags["fieldUnderLine"]! + i
            fieldUnderLine.backgroundColor = UIColor.gray
            view.addSubview(fieldUnderLine)
            fieldUnderLine.snp_makeConstraints({ (make) in
                make.left.equalTo(usernameField)
                make.right.equalTo(usernameField)
                make.bottom.equalTo(i == 0 ? usernameField : passwdField).offset(1)
                make.height.equalTo(1)
            })
        }
        
        let loginBtn = UIButton()
        loginBtn.tag = tags["loginBtn"]!
        loginBtn.backgroundColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1)
        loginBtn.setTitle("登录", for: UIControlState())
        loginBtn.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: UIControlState())
        loginBtn.layer.cornerRadius = 45 / 2.0
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: #selector(LoginVC.login(_:)), for: .touchUpInside)
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
        loginWithMSGBtn.backgroundColor = .clear
        loginWithMSGBtn.setTitle("使用手机短信登录", for: UIControlState())
        loginWithMSGBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), for: UIControlState())
        loginWithMSGBtn.addTarget(self, action: #selector(LoginVC.login(_:)), for: .touchUpInside)
        view.addSubview(loginWithMSGBtn)
        loginWithMSGBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-60)
            make.height.equalTo(25)
        }
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.loginResult(_:)), name: NSNotification.Name(rawValue: NotifyDefine.LoginResult), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification?) {
        let frame = (notification!.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        var vFrame = view.frame
        if vFrame.origin.y == 0 {
            vFrame.origin.y -= (frame?.size.height)!
            view.frame = vFrame
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        var vFrame = view.frame
        vFrame.origin.y = 0
        view.frame = vFrame
    }
    
    func login(_ sender: UIButton?) {
        var dict:Dictionary<String, AnyObject>?
        if sender?.tag == 20001 {
            dict = ["phone_num_": "15158110001" as AnyObject, "passwd_": "123456" as AnyObject, "user_type_": 2 as AnyObject]
            SocketManager.sendData(.login, data: dict as AnyObject?)
            return
        }
        
        if sender?.tag == tags["loginWithMSGBtn"]! {
            loginWithMSGVC = LoginWithMSGVC()
            present(loginWithMSGVC!, animated: false, completion: nil)
            return
        }
        
        if username == nil || username?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入手机号码", ForDuration: 1, completion: nil)
            return
        }
        
        
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^1[3|4|5|7|8][0-9]\\d{8}$")
        if predicate.evaluate(with: username) == false {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入正确的手机号", ForDuration: 1.5, completion: nil)
            return
        }
        
        
        if passwd == nil || (passwd?.characters.count)! == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入密码", ForDuration: 1, completion: nil)
            return
        }
        
        
        SVProgressHUD.showProgressMessage(ProgressMessage: "登录中...")
        if sender?.tag == tags["loginBtn"]! {
            dict = ["phone_num_": username! as AnyObject, "passwd_": passwd! as AnyObject, "user_type_": 1 as AnyObject]
        }
        UserDefaults.standard.set(username, forKey: CommonDefine.UserName)
        UserDefaults.standard.set(passwd, forKey: CommonDefine.Passwd)
        UserDefaults.standard.set("\(dict!["user_type_"]!)", forKey: CommonDefine.UserType)
        SocketManager.sendData(.login, data: dict as AnyObject?)
    }
    
    func randomSmallCaseString(_ length: Int) -> String {
        var output = ""
        
        for _ in 0..<length {
            let randomNumber = arc4random() % 26 + 97
            let randomChar = Character(UnicodeScalar(randomNumber)!)
            output.append(randomChar)
        }
        return output
    }
    
    func loginResult(_ notification: Notification?) {
        
        let data = notification?.userInfo!["data"]
        if let errorCode = (data as AnyObject).value(forKey: "error_") {
            let errorMsg = CommonDefine.errorMsgs[(errorCode as AnyObject).intValue]
            SVProgressHUD.showErrorMessage(ErrorMessage: errorMsg!, ForDuration: 1.5, completion: nil)
            return
        }
        SVProgressHUD.dismiss()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.LoginSuccessed), object: nil, userInfo: ["data": data!])
        
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["usernameField"]!:
            username = ""
            break
        case tags["passwdField"]!:
            passwd = ""
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
        
        if textField.tag == tags["usernameField"]! {
            username = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        } else if textField.tag == tags["passwdField"]! {
            passwd = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
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
