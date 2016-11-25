//
//  LoginWithMSGVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/8.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
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
    var timer:Timer?
    var timeSecond:Int = 0
    var resetPasswdVC:ResetPasswdVC?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(LoginWithMSGVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        bgView.addGestureRecognizer(touch)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        bgView.addSubview(blurView)
        blurView.snp.makeConstraints { (make) in
            make.edges.equalTo(bgView)
        }
        
        let width = UIScreen.main.bounds.size.width / 3.0
        let logo = UIImageView()
        logo.backgroundColor = UIColor.gray
        logo.layer.cornerRadius = width / 2.0
        logo.layer.masksToBounds = true
        logo.image = UIImage.init(named: "logo")
        view.addSubview(logo)
        logo.snp.makeConstraints { (make) in
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
        usernameField.keyboardType = .phonePad
        usernameField.attributedPlaceholder = NSAttributedString.init(string: "请输入手机号码", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        view.addSubview(usernameField)
        usernameField.snp.makeConstraints({ (make) in
            make.left.equalTo(view).offset(60)
            make.top.equalTo(logo.snp.bottom).offset(60)
            make.right.equalTo(view).offset(-60)
            make.height.equalTo(35)
        })
        
        let verifyCodeField = UITextField()
        verifyCodeField.tag = tags["verifyCodeField"]!
        verifyCodeField.isSecureTextEntry = false
        verifyCodeField.delegate = self
        verifyCodeField.textColor = UIColor.white.withAlphaComponent(0.5)
        verifyCodeField.rightViewMode = .whileEditing
        verifyCodeField.clearButtonMode = .whileEditing
        verifyCodeField.backgroundColor = UIColor.clear
        verifyCodeField.textAlignment = .left
        verifyCodeField.keyboardType = .numberPad
        verifyCodeField.attributedPlaceholder = NSAttributedString.init(string: "请输入验证码", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        view.addSubview(verifyCodeField)
        
        let getVerifyCodeBtn = UIButton()
        getVerifyCodeBtn.tag = tags["getVerifyCodeBtn"]!
        getVerifyCodeBtn.backgroundColor = UIColor.clear
        getVerifyCodeBtn.setTitle("发送验证码", for: UIControlState())
        getVerifyCodeBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), for: UIControlState())
        getVerifyCodeBtn.addTarget(self, action: #selector(LoginWithMSGVC.getVerifyCodeAction(_:)), for: .touchUpInside)
        view.addSubview(getVerifyCodeBtn)
        getVerifyCodeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(usernameField)
            make.top.equalTo(verifyCodeField)
            make.bottom.equalTo(verifyCodeField)
            make.width.equalTo(100)
        }
        
        verifyCodeField.snp.makeConstraints({ (make) in
            make.left.equalTo(usernameField)
            make.top.equalTo(usernameField.snp.bottom).offset(20)
            make.right.equalTo(getVerifyCodeBtn.snp.left).offset(-10)
            make.height.equalTo(35)
        })
        
        for i in 0...3 {
            let fieldUnderLine = UIView()
            fieldUnderLine.tag = tags["fieldUnderLine"]! + i
            fieldUnderLine.backgroundColor = UIColor.gray
            view.addSubview(fieldUnderLine)
            fieldUnderLine.snp.makeConstraints({ (make) in
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
        nextBtn.setTitle("下一步", for: UIControlState())
        nextBtn.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: UIControlState())
        nextBtn.layer.cornerRadius = 45 / 2.0
        nextBtn.layer.masksToBounds = true
        nextBtn.addTarget(self, action: #selector(LoginWithMSGVC.nextAction(_:)), for: .touchUpInside)
        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalTo(usernameField)
            make.right.equalTo(usernameField)
            make.top.equalTo(verifyCodeField.snp.bottom).offset(60)
            make.height.equalTo(45)
        }
        
        let loginWithAccountBtn = UIButton()
        loginWithAccountBtn.tag = tags["loginWithAccountBtn"]!
        loginWithAccountBtn.backgroundColor = .clear
        loginWithAccountBtn.setTitle("使用账号密码登录", for: UIControlState())
        loginWithAccountBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), for: UIControlState())
        loginWithAccountBtn.addTarget(self, action: #selector(LoginWithMSGVC.loginWithAccountAction(_:)), for: .touchUpInside)
        view.addSubview(loginWithAccountBtn)
        loginWithAccountBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-60)
            make.height.equalTo(25)
        }
    }
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let textField = view.viewWithTag(tags["usernameField"]!) {
//            if !textField.exclusiveTouch {
//                textField.resignFirstResponder()
//            }
//        }
//        
//        if let textField = view.viewWithTag(tags["verifyCodeField"]!) {
//            if !textField.exclusiveTouch {
//                textField.resignFirstResponder()
//            }
//        }
//    }

    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginWithMSGVC.loginResult(_:)), name: NSNotification.Name(rawValue: NotifyDefine.LoginResult), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginWithMSGVC.verifyCodeInfoNotify(_:)), name: NSNotification.Name(rawValue: NotifyDefine.VerifyCodeInfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginWithMSGVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginWithMSGVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func loginResult(_ notification: Notification?) {
        let data = notification?.userInfo!["data"] as? [String: Any]
        let err = (data! as AnyObject).allKeys!.contains(where: { (key) -> Bool in
            return key as! String == "error_" ? true : false
        })
        if err {
            XCGLogger.error("err:\(data!["error_"] as! Int)")
            return
        }
        XCGLogger.debug("\(data!)")
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.LoginSuccessed), object: nil, userInfo: ["data": data!])
        
    }
    
    func verifyCodeInfoNotify(_ notification: Notification?) {
        SVProgressHUD.dismiss()
        if let data = notification?.userInfo!["data"] as? [String: Any] {
            verifyCodeTime = (data["timestamp_"] as? Int)!
            token = data["token_"] as? String
        }else{
            SVProgressHUD.showErrorMessage(ErrorMessage: "发送验证码失败，请稍后再试！", ForDuration: 1, completion: nil)
        }
    }
    
    func loginWithAccountAction(_ sender: UIButton?) {
        dismiss(animated: false, completion: nil)
    }
    /**
     添加倒计时
     */
    func setupCountdown() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timeSecond = 60
        let button = view.viewWithTag(tags["getVerifyCodeBtn"]!) as! UIButton
        button.setTitle("60s", for: UIControlState())
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: UIControlState())

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoginWithMSGVC.timerAction), userInfo: nil, repeats: true)
    }
    func timerAction() {
        
        timeSecond -= 1
        let button = view.viewWithTag(tags["getVerifyCodeBtn"]!) as! UIButton
        if timeSecond > 0 {
            let showInfo = String(format: "%ds", timeSecond);
            button.setTitle(showInfo, for: UIControlState())
            
        } else {
            button.isUserInteractionEnabled = true
            button.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), for: UIControlState())
            button.setTitle("重新获取", for: UIControlState())
            timer?.invalidate()
            timer = nil
        }
    }
    /**
     获取验证码
     - parameter sender:
     */
    func getVerifyCodeAction(_ sender: UIButton) {
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^1[3|4|5|7|8][0-9]\\d{8}$")
        if predicate.evaluate(with: username) == false {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入正确的手机号", ForDuration: 1.5, completion: nil)
            return
        }
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        let dict  = ["verify_type_": 1, "phone_num_": username!] as [String : Any]
        _ = SocketManager.sendData(.sendMessageVerify, data: dict as AnyObject?)
        sender.isUserInteractionEnabled = false
        setupCountdown()
    }
    
    func nextAction(_ sender: UIButton?) {
        if username?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入手机号", ForDuration: 1, completion: nil)
            return
        }
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^1[3|4|5|7|8][0-9]\\d{8}$")
        if predicate.evaluate(with: username) == false {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入正确的手机号", ForDuration: 1.5, completion: nil)
            return
        }
        if verifyCode == nil || verifyCode?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入验证码", ForDuration: 1.5, completion: nil)
            return
        }
        
        resetPasswdVC = ResetPasswdVC()
        resetPasswdVC!.verifyCodeTime = verifyCodeTime
        resetPasswdVC!.token = token
        resetPasswdVC?.username = username
        resetPasswdVC?.verifyCode = Int(verifyCode!)!
        present(resetPasswdVC!, animated: false, completion: nil)
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["usernameField"]!:
            username = ""
            break
        case tags["verifyCodeField"]!:
            verifyCode = ""
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
        } else if textField.tag == tags["verifyCodeField"]! {
            verifyCode = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        }
        
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        timer = nil
    }
    
    
}
