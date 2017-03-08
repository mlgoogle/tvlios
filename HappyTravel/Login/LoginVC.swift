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
    var currentTextField:UITextField?
    
    var loginWithMSGVC:LoginWithMSGVC?
    var startTime = 0.0
    
    
    let photoNumberView:UIView = UIView()
    let enterPasswordView:UIView = UIView()
    let photoImage: UIImageView = UIImageView()
    let passwordImage:UIImageView = UIImageView()
    let eyeBtn:UIButton = UIButton()
    let usernameField = UITextField()
    let passwdField = UITextField()
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        title = "登录"
        initView()
        let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        leftBtn.setImage(UIImage.init(named: "return"), forState: UIControlState.Normal)
        leftBtn.addTarget(self, action: #selector(didBack), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    func didBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        startTime = NSDate().timeIntervalSinceNow
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
        let endTime = NSDate().timeIntervalSinceNow
        
        let timeCount = endTime - startTime
        MobClick.event(CommonDefine.BuriedPoint.login, durations:Int32(timeCount))
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func initView() {
//        let bgView = UIImageView()
//        bgView.userInteractionEnabled = true
//        bgView.image = UIImage.init(named: "login-bg")
//        view.addSubview(bgView)
//        bgView.snp_makeConstraints { (make) in
//            make.edges.equalTo(view)
//        }
//        
//        let touch = UITapGestureRecognizer.init(target: self, action: #selector(LoginVC.touchWhiteSpace))
//        touch.numberOfTapsRequired = 1
//        touch.cancelsTouchesInView = false
//        bgView.addGestureRecognizer(touch)
        
//        let blurEffect = UIBlurEffect(style: .Dark)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        bgView.addSubview(blurView)
//        blurView.snp_makeConstraints { (make) in
//            make.edges.equalTo(bgView)
//        }
        
//        let width = UIScreen.mainScreen().bounds.size.width / 3.0
//        let logo = UIImageView()
//        logo.backgroundColor = UIColor.grayColor()
//        logo.layer.cornerRadius = width / 2.0
//        logo.layer.masksToBounds = true
//        logo.image = UIImage.init(named: "logo")
//        view.addSubview(logo)
//        logo.snp_makeConstraints { (make) in
//            make.centerX.equalTo(view)
//            make.top.equalTo(view).offset(100)
//            make.width.equalTo(width)
//            make.height.equalTo(width)
//        }
        view.addSubview(photoNumberView)
        view.addSubview(enterPasswordView)
        photoNumberView.addSubview(photoImage)
        photoNumberView.addSubview(usernameField)
        enterPasswordView.addSubview(passwdField)
        enterPasswordView.addSubview(passwordImage)
        enterPasswordView.addSubview(eyeBtn)
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
            make.width.equalTo(15)
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
        usernameField.keyboardType = .NumberPad
        usernameField.attributedPlaceholder = NSAttributedString.init(string: "请输入手机号", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        usernameField.textColor = UIColor.blackColor()
        usernameField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(photoImage.snp_right).offset(16)
            make.top.equalTo(photoNumberView).offset(0)
            make.right.equalTo(photoNumberView).offset(0)
            make.height.equalTo(51)
        })
        //线
        let fieldUnderLine = UIView()
        fieldUnderLine.tag = tags["fieldUnderLine"]!
        fieldUnderLine.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        photoNumberView.addSubview(fieldUnderLine)
        fieldUnderLine.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(photoNumberView)
            make.right.equalTo(photoNumberView)
            make.bottom.equalTo(photoNumberView.snp_bottom)
            make.height.equalTo(1)
        })
        
        //输入登录密码视图
        enterPasswordView.snp_makeConstraints { (make) in
            make.top.equalTo(photoNumberView.snp_bottom)
            make.right.equalTo(photoNumberView)
            make.left.equalTo(photoNumberView)
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
        
        let loginBtn = UIButton()
        loginBtn.tag = tags["loginBtn"]!
        loginBtn.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        loginBtn.setTitle("确定", forState: .Normal)
        loginBtn.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Normal)
        loginBtn.layer.cornerRadius = 45 / 2.0
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: #selector(LoginVC.login(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(loginBtn)
        loginBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            make.top.equalTo(passwdField.snp_bottom).offset(40)
            make.height.equalTo(45)
        }

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
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
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
    
    func login(sender: UIButton?) {
        currentTextField?.resignFirstResponder()
        MobClick.event(CommonDefine.BuriedPoint.loginAction)

        if sender?.tag == tags["loginWithMSGBtn"]! {
            loginWithMSGVC = LoginWithMSGVC()
            presentViewController(loginWithMSGVC!, animated: false, completion: nil)
            return
        }
        
        if username == nil || username?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入手机号码", ForDuration: 1, completion: nil)
            return
        }
        
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^1[3|4|5|7|8][0-9]\\d{8}$")
        if predicate.evaluateWithObject(username) == false {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入正确的手机号", ForDuration: 1.5, completion: nil)
            return
        }
        
        if passwd == nil || (passwd?.characters.count)! == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入密码", ForDuration: 1, completion: nil)
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: CommonDefine.UserName)
        NSUserDefaults.standardUserDefaults().setObject(passwd, forKey: CommonDefine.Passwd)
        let loginModel = LoginModel()
        APIHelper.userAPI().login(loginModel, complete: { (response) in
            if let user = response as? UserInfoModel {
                CurrentUser = user
                CurrentUser.login_ = true
                self.dismissAll({ () in
                    NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginSuccessed, object: nil, userInfo: nil)
                })
                
            }
        }, error: { (err) in
            NSUserDefaults.standardUserDefaults().removeObjectForKey(CommonDefine.Passwd)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginFailed, object: nil, userInfo: nil)
            XCGLogger.debug(err)
        })
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
    
    //MARK: - UITextField
    func textFieldShouldClear(textField: UITextField) -> Bool {
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        currentTextField = textField
        if range.location > 15 {
            return false
        }
        
        if textField.tag == tags["usernameField"]! {
            username = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
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
    }
    
    
}
