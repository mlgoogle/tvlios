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
    var timer:NSTimer?
    var timeSecond:Int = 0
    var resetPasswdVC:ResetPasswdVC?
    var startTime = 0.0
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        startTime = NSDate().timeIntervalSinceNow

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        let endTime = NSDate().timeIntervalSinceNow
        
        let timeCount = endTime - startTime
        MobClick.event(CommonDefine.BuriedPoint.register, durations:Int32(timeCount))
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
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(LoginWithMSGVC.touchWhiteSpace))
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
        usernameField.keyboardType = .PhonePad
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
        verifyCodeField.keyboardType = .NumberPad
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
            make.width.equalTo(100)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginWithMSGVC.loginResult(_:)), name: NotifyDefine.LoginResult, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginWithMSGVC.verifyCodeInfoNotify(_:)), name: NotifyDefine.VerifyCodeInfo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginWithMSGVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginWithMSGVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
    
    func verifyCodeInfoNotify(notification: NSNotification?) {
        SVProgressHUD.dismiss()
        if let data = notification?.userInfo!["data"] {
            verifyCodeTime = (data["timestamp_"] as? Int)!
            token = data["token_"] as? String
        }else{
            SVProgressHUD.showErrorMessage(ErrorMessage: "发送验证码失败，请稍后再试！", ForDuration: 1, completion: nil)
        }
    }
    
    func loginWithAccountAction(sender: UIButton?) {
        dismissViewControllerAnimated(false, completion: nil)
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
        button.setTitle("60s", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Normal)

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LoginWithMSGVC.timerAction), userInfo: nil, repeats: true)
    }
    func timerAction() {
        
        timeSecond -= 1
        let button = view.viewWithTag(tags["getVerifyCodeBtn"]!) as! UIButton
        if timeSecond > 0 {
            let showInfo = String(format: "%ds", timeSecond);
            button.setTitle(showInfo, forState: .Normal)
            
        } else {
            button.userInteractionEnabled = true
            button.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), forState: .Normal)
            button.setTitle("重新获取", forState: .Normal)
            timer?.invalidate()
            timer = nil
        }
    }
    /**
     获取验证码
     - parameter sender:
     */
    func getVerifyCodeAction(sender: UIButton) {
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^1[3|4|5|7|8][0-9]\\d{8}$")
        if predicate.evaluateWithObject(username) == false {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入正确的手机号", ForDuration: 1.5, completion: nil)
            return
        }
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        let dict  = ["verify_type_": 1, "phone_num_": username!]
        SocketManager.sendData(.SendMessageVerify, data: dict)
        sender.userInteractionEnabled = false
        setupCountdown()
    }
    
    func nextAction(sender: UIButton?) {
         MobClick.event(CommonDefine.BuriedPoint.registerNext)
        if username?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入手机号", ForDuration: 1, completion: nil)
            return
        }
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^1[3|4|5|7|8][0-9]\\d{8}$")
        if predicate.evaluateWithObject(username) == false {
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
        presentViewController(resetPasswdVC!, animated: false, completion: nil)
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(textField: UITextField) -> Bool {
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 15 {
            return false
        }
        
        if textField.tag == tags["usernameField"]! {
            username = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        } else if textField.tag == tags["verifyCodeField"]! {
            verifyCode = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        }
        
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        timer?.invalidate()
        timer = nil
    }
    
    
}
