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
                "registBtn": 1003,
                "fieldUnderLine": 10040,
                "loginWithAccountBtn": 1005,
                "getVerifyCodeBtn": 1006,
                "passwdField": 1007,
                "reInPasswdField": 1008]
    
    var username:String?
    var passwd:String?
    var repasswd:String?
    var verifyCode:String?
    var verifyCodeTime = 0
    var token:String?
    var timer:NSTimer?
    var timeSecond:Int = 0
    var resetPasswdVC:ResetPasswdVC?
    var startTime = 0.0
    var isForget: Bool = false
    
    //手机号视图
    let photoNumberView:UIView = UIView()
    //输入验证码视图
    let verifyView: UIView = UIView()
    //请输入登录密码视图
    let enterPasswordView:UIView = UIView()
    //再次输入登录密码视图
    let reInPasswdView:UIView = UIView()
    
    //手机号码图片
    let photoImage: UIImageView = UIImageView()
    //验证码图片
    let verifyImage: UIImageView = UIImageView()
    //输入密码图片
    let passwordImage:UIImageView = UIImageView()
    //再次输入登录密码图片
    let reInPasswdImage: UIImageView = UIImageView()
    //输入邀请码图片
    let inviteCodeImage: UIImageView = UIImageView()
    //眼睛的按钮
    let eyeBtn:UIButton = UIButton()
    
    //输入手机号文本框
    let usernameField = UITextField()
    //输入密码文本框
    let passwdField = UITextField()
    //输入验证码文本框
    let verifyCodeField = UITextField()
    //再次输入密码文本框
    let reInPasswdField = UITextField()
    
    //发送验证码按钮
    let getVerifyCodeBtn = UIButton()
    
    //三根线
    let oneLine:UIView = UIView()
    let twoLine:UIView = UIView()
    let threeLine: UIView = UIView()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        initView()
        let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        leftBtn.setImage(UIImage.init(named: "return"), forState: UIControlState.Normal)
        leftBtn.addTarget(self, action: #selector(didBack), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    func didBack() {
        usernameField.resignFirstResponder()
        passwdField.resignFirstResponder()
        reInPasswdField.resignFirstResponder()
        verifyCodeField.resignFirstResponder()
        if isForget {
            navigationController?.popViewControllerAnimated(true)
        }
        else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        startTime = NSDate().timeIntervalSinceNow
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let endTime = NSDate().timeIntervalSinceNow
        
        let timeCount = endTime - startTime
        MobClick.event(CommonDefine.BuriedPoint.register, durations:Int32(timeCount))
    }
    
    func loginSuccessed(notification: NSNotification) {
        dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func initView() {
        
        view.addSubview(photoNumberView)
        view.addSubview(verifyView)
        view.addSubview(enterPasswordView)
        view.addSubview(reInPasswdView)
        reInPasswdView.addSubview(reInPasswdField)
        reInPasswdView.addSubview(reInPasswdImage)
        verifyView.addSubview(verifyImage)
        verifyView.addSubview(verifyCodeField)
        verifyView.addSubview(getVerifyCodeBtn)
        photoNumberView.addSubview(photoImage)
        photoNumberView.addSubview(usernameField)
        enterPasswordView.addSubview(passwdField)
        enterPasswordView.addSubview(passwordImage)
        enterPasswordView.addSubview(eyeBtn)
        view.addSubview(oneLine)
        view.addSubview(twoLine)
        view.addSubview(threeLine)
        
        //输入手机号视图
        photoNumberView.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(15)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.height.equalTo(51)
        }
        photoNumberView.backgroundColor = UIColor.whiteColor()
        
        photoImage.snp_makeConstraints { (make) in
            make.left.equalTo(photoNumberView).offset(15)
            make.top.equalTo(photoNumberView).offset(16)
            make.height.equalTo(20)
            make.width.equalTo(14)
        }
        photoImage.image = UIImage.init(named:"photoNumber")
        
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
        usernameField.textColor = UIColor.blackColor()
        usernameField.setValue(UIFont.systemFontOfSize(14), forKeyPath: "_placeholderLabel.font")
        usernameField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(photoImage.snp_right).offset(16)
            make.top.equalTo(photoNumberView).offset(0)
            make.right.equalTo(photoNumberView).offset(0)
            make.height.equalTo(51)
        })
        
        //验证码视图
        verifyView.snp_makeConstraints { (make) in
            make.left.equalTo(photoNumberView)
            make.top.equalTo(photoNumberView.snp_bottom)
            make.height.equalTo(51)
            make.right.equalTo(photoNumberView)
        }
        verifyView.backgroundColor = UIColor.whiteColor()
        
        verifyImage.snp_makeConstraints { (make) in
            make.left.equalTo(verifyView).offset(15)
            make.top.equalTo(verifyView).offset(16)
            make.height.equalTo(20)
            make.width.equalTo(17)
        }
        verifyImage.image = UIImage.init(named:"verificationCode")
        
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
        verifyCodeField.textColor = UIColor.blackColor()
        verifyCodeField.setValue(UIFont.systemFontOfSize(14), forKeyPath: "_placeholderLabel.font")
    
        
        getVerifyCodeBtn.tag = tags["getVerifyCodeBtn"]!
        getVerifyCodeBtn.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        getVerifyCodeBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        getVerifyCodeBtn.setTitle("获取验证码", forState: .Normal)
        getVerifyCodeBtn.setTitleColor(UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), forState: .Normal)
        getVerifyCodeBtn.layer.cornerRadius = 18
        getVerifyCodeBtn.layer.masksToBounds = true
        getVerifyCodeBtn.addTarget(self, action: #selector(LoginWithMSGVC.getVerifyCodeAction(_:)), forControlEvents: .TouchUpInside)
        getVerifyCodeBtn.snp_makeConstraints { (make) in
            make.right.equalTo(verifyView).offset(-15)
            make.top.equalTo(verifyView).offset(8)
            make.width.equalTo(101)
            make.height.equalTo(36)
        }
        verifyCodeField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(verifyImage.snp_right).offset(16)
            make.top.equalTo(verifyView)
            make.right.equalTo(getVerifyCodeBtn.snp_left).offset(-10)
            make.height.equalTo(51)
        })
        
        //输入登录密码视图
        enterPasswordView.snp_makeConstraints { (make) in
            make.top.equalTo(verifyView.snp_bottom)
            make.right.equalTo(verifyView)
            make.left.equalTo(verifyView)
            make.height.equalTo(51)
        }
        enterPasswordView.backgroundColor = UIColor.whiteColor()
        
        passwordImage.snp_makeConstraints { (make) in
            make.left.equalTo(enterPasswordView).offset(15)
            make.top.equalTo(enterPasswordView).offset(16)
            make.height.equalTo(20)
            make.width.equalTo(15)
        }
        passwordImage.image = UIImage.init(named:"password")
        
        passwdField.tag = tags["passwdField"]!
        passwdField.secureTextEntry = true
        passwdField.delegate = self
        passwdField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        passwdField.rightViewMode = .WhileEditing
        passwdField.clearButtonMode = .WhileEditing
        passwdField.backgroundColor = UIColor.clearColor()
        passwdField.textAlignment = .Left
        passwdField.attributedPlaceholder = NSAttributedString.init(string: "请输入登录密码", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        passwdField.textColor = UIColor.blackColor()
        passwdField.setValue(UIFont.systemFontOfSize(14), forKeyPath: "_placeholderLabel.font")
        
        passwdField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(passwordImage.snp_right).offset(15)
            make.top.equalTo(enterPasswordView)
            make.right.equalTo(eyeBtn.snp_left)
            make.height.equalTo(51)
        })
        
        
        eyeBtn.snp_makeConstraints { (make) in
            make.right.equalTo(enterPasswordView).offset(-19)
            make.top.equalTo(enterPasswordView).offset(20)
            make.height.equalTo(12)
            make.width.equalTo(22)
        }
        eyeBtn.setBackgroundImage(UIImage.init(named: "eyeInvisible"), forState: UIControlState.Normal)
        eyeBtn.addTarget(self, action: #selector(eyeBtnDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        //再次输入登录密码视图
        reInPasswdView.snp_makeConstraints { (make) in
            make.top.equalTo(enterPasswordView.snp_bottom)
            make.right.equalTo(enterPasswordView)
            make.left.equalTo(enterPasswordView)
            make.height.equalTo(51)
        }
        reInPasswdView.backgroundColor = UIColor.whiteColor()
        
        reInPasswdImage.snp_makeConstraints { (make) in
            make.left.equalTo(reInPasswdView).offset(15)
            make.top.equalTo(reInPasswdView).offset(16)
            make.height.equalTo(20)
            make.width.equalTo(15)
        }
        reInPasswdImage.image = UIImage.init(named:"password")
        
        reInPasswdField.tag = tags["reInPasswdField"]!
        reInPasswdField.secureTextEntry = true
        reInPasswdField.delegate = self
        reInPasswdField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        reInPasswdField.rightViewMode = .WhileEditing
        reInPasswdField.clearButtonMode = .WhileEditing
        reInPasswdField.backgroundColor = UIColor.clearColor()
        reInPasswdField.textAlignment = .Left
        reInPasswdField.attributedPlaceholder = NSAttributedString.init(string: "请再次输入登录密码", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        reInPasswdField.textColor = UIColor.blackColor()
        reInPasswdField.setValue(UIFont.systemFontOfSize(14), forKeyPath: "_placeholderLabel.font")
        
        reInPasswdField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(reInPasswdImage.snp_right).offset(15)
            make.top.equalTo(reInPasswdView)
            make.right.equalTo(reInPasswdView)
            make.height.equalTo(51)
        })
        
        
        //三根线的约束
        oneLine.snp_makeConstraints { (make) in
            make.bottom.equalTo(photoNumberView)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.height.equalTo(1)
        }
        oneLine.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        twoLine.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        threeLine.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        twoLine.snp_makeConstraints { (make) in
            make.bottom.equalTo(verifyView)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.height.equalTo(1)
        }
        threeLine.snp_makeConstraints { (make) in
            make.bottom.equalTo(enterPasswordView)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.height.equalTo(1)
        }
        
        
        let registBtn = UIButton()
        view.addSubview(registBtn)
        registBtn.tag = tags["registBtn"]!
        registBtn.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        if isForget {
            registBtn.setTitle("确定", forState: .Normal)
        }else{
           registBtn.setTitle("注册", forState: .Normal)
        }
        registBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            make.top.equalTo(reInPasswdView.snp_bottom).offset(40)
            make.height.equalTo(45)
        }
        
        registBtn.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Normal)
        registBtn.layer.cornerRadius = 45 / 2.0
        registBtn.layer.masksToBounds = true
        registBtn.addTarget(self, action: #selector(LoginWithMSGVC.nextAction(_:)), forControlEvents: .TouchUpInside)
        
      
//        
//        let loginWithAccountBtn = UIButton()
//        loginWithAccountBtn.tag = tags["loginWithAccountBtn"]!
//        loginWithAccountBtn.backgroundColor = .clearColor()
//        loginWithAccountBtn.setTitle("使用账号密码登录", forState: .Normal)
//        loginWithAccountBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), forState: .Normal)
//        loginWithAccountBtn.addTarget(self, action: #selector(LoginWithMSGVC.loginWithAccountAction(_:)), forControlEvents: .TouchUpInside)
//        view.addSubview(loginWithAccountBtn)
//        loginWithAccountBtn.snp_makeConstraints { (make) in
//            make.centerX.equalTo(view)
//            make.bottom.equalTo(view).offset(-60)
//            make.height.equalTo(25)
//        }
    }
    
    //可视密码按钮点击
    var selectorBtn:UIButton = {
        let btn:UIButton = UIButton()
        btn.selected = true
        return btn
    }()
    func eyeBtnDidClick(sender: UIButton) {
        
        sender.selected = selectorBtn.selected
        if sender.selected {
            passwdField.secureTextEntry = false
            eyeBtn.setBackgroundImage(UIImage.init(named: "eyeVisible"), forState: UIControlState.Normal)
            eyeBtn.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(16)
                make.top.equalTo(enterPasswordView).offset(18)
            })
        }
        else{
            passwdField.secureTextEntry = true
            eyeBtn.setBackgroundImage(UIImage.init(named: "eyeInvisible"), forState: UIControlState.Normal)
            eyeBtn.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(12)
                make.top.equalTo(enterPasswordView).offset(20)
            })
        }
        selectorBtn.selected = !sender.selected
    }


    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification?) {
//        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
//        var vFrame = view.frame
//        if vFrame.origin.y == 0 {
//            vFrame.origin.y -= frame.size.height
//            view.frame = vFrame
//        }
    }
    
    func keyboardWillHide(notification: NSNotification?) {
//        var vFrame = view.frame
//        vFrame.origin.y = 0
//        view.frame = vFrame
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
        button.setTitleColor(UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1), forState: .Normal)

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LoginWithMSGVC.timerAction), userInfo: nil, repeats: true)
    }
    func timerAction() {
        
        timeSecond -= 1
        let button = view.viewWithTag(tags["getVerifyCodeBtn"]!) as! UIButton
        if timeSecond > 0 {
            let showInfo = String(format: "%ds", timeSecond);
            button.setTitle(showInfo, forState: .Normal)
            button.setTitleColor(UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1), forState: UIControlState.Normal)
            
            
        } else {
            button.userInteractionEnabled = true
            button.setTitleColor(UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), forState: .Normal)
            button.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
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
        
        let req = VerifyCodeRequestModel()
        req.phone_num_ = username
        req.verify_type_ = 1
        APIHelper.commonAPI().verifyCode(req, complete: { [weak self](response) in
            if let model = response as? VerifyInfoModel {
                sender.setTitleColor(UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1), forState: UIControlState.Normal)
                self?.verifyCodeTime = model.timestamp_
                self?.token = model.token_
            }
        }, error: { (err) in
            SVProgressHUD.showErrorMessage(ErrorMessage: "发送验证码失败，请稍后再试！", ForDuration: 1, completion: nil)
        })
        sender.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
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
        
        if  passwd == nil || passwd?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入密码", ForDuration: 1, completion: nil)
            return
        }
        
        if  repasswd == nil || repasswd?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请再次输入密码", ForDuration: 1, completion: nil)
            return
        }
        
        if passwd != repasswd {
            SVProgressHUD.showErrorMessage(ErrorMessage: "两次输入密码不一致", ForDuration: 1, completion: nil)
            return
        }
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        
        let model = RegisterAccountBaseInfo()
            model.phone_num_ = username!
            model.passwd_ = passwd!
            model.timestamp_ = Int64(verifyCodeTime)
            model.verify_code_ = Int(verifyCode!)!
            model.token_ = token ?? ""
            model.invitation_phone_num_  = verifyCode
            APIHelper.userAPI().registerAccount(model, complete: { (response) in
                    if let model = response as? RegisterAccountModel {
                        SVProgressHUD.dismiss()
                        NSUserDefaults.standardUserDefaults().setObject(self.username, forKey: CommonDefine.UserName)
                        NSUserDefaults.standardUserDefaults().setObject(self.passwd, forKey: CommonDefine.Passwd)
                        let loginModel = LoginModel()
                        APIHelper.userAPI().login(loginModel, complete: { [weak self](response) in
                            if let user = response as? UserInfoModel {
                                CurrentUser = user
                                CurrentUser.login_ = true
                                self?.dismissAll({ () in
                                    NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginSuccessed, object: nil, userInfo: nil)
                                })
        
                            }
                            }, error: { (err) in
                                NSUserDefaults.standardUserDefaults().removeObjectForKey(CommonDefine.Passwd)
                                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginFailed, object: nil, userInfo: nil)
                                XCGLogger.debug(err)
                        })
                    }
                    }, error: { (err) in
                        let warning = SocketRequest.errorString(err.code)
                        SVProgressHUD.showErrorMessage(ErrorMessage: warning, ForDuration: 1, completion: nil)
                })

//        resetPasswdVC = ResetPasswdVC()
//        resetPasswdVC!.verifyCodeTime = verifyCodeTime
//        resetPasswdVC!.token = token
//        resetPasswdVC?.username = username
//        resetPasswdVC?.verifyCode = Int(verifyCode!)!
//        presentViewController(resetPasswdVC!, animated: false, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameField.resignFirstResponder()
        passwdField.resignFirstResponder()
        verifyCodeField.resignFirstResponder()
        reInPasswdField.resignFirstResponder()
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["usernameField"]!:
            username = ""
            break
        case tags["verifyCodeField"]!:
            verifyCode = ""
        case tags["passwdField"]!:
            passwd = ""
            break
        case tags["reInPasswdField"]!:
            repasswd = ""
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
        else if textField.tag == tags["reInPasswdField"]! {
            repasswd = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        } else if textField.tag == tags["passwdField"]! {
            passwd = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
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
