//
//  ResetPasswdVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/8.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD

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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        bgView.isUserInteractionEnabled = true
        bgView.image = UIImage.init(named: "login-bg")
        view.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(ResetPasswdVC.touchWhiteSpace))
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
        
        let passwdField = UITextField()
        passwdField.tag = tags["passwdField"]!
        passwdField.isSecureTextEntry = true
        passwdField.delegate = self
        passwdField.textColor = UIColor.white.withAlphaComponent(0.5)
        passwdField.rightViewMode = .whileEditing
        passwdField.clearButtonMode = .whileEditing
        passwdField.backgroundColor = UIColor.clear
        passwdField.textAlignment = .left
        passwdField.attributedPlaceholder = NSAttributedString.init(string: "请输入密码",
                                                                    attributes: [NSForegroundColorAttributeName: UIColor.gray])
        view.addSubview(passwdField)
        passwdField.snp.makeConstraints({ (make) in
            make.left.equalTo(view).offset(60)
            make.top.equalTo(logo.snp.bottom).offset(60)
            make.right.equalTo(view).offset(-60)
            make.height.equalTo(35)
        })
        
        let reInPasswdField = UITextField()
        reInPasswdField.tag = tags["reInPasswdField"]!
        reInPasswdField.isSecureTextEntry = true
        reInPasswdField.delegate = self
        reInPasswdField.textColor = UIColor.white.withAlphaComponent(0.5)
        reInPasswdField.rightViewMode = .whileEditing
        reInPasswdField.clearButtonMode = .whileEditing
        reInPasswdField.backgroundColor = UIColor.clear
        reInPasswdField.textAlignment = .left
        reInPasswdField.attributedPlaceholder = NSAttributedString.init(string: "请重新输入密码",
                                                                        attributes: [NSForegroundColorAttributeName: UIColor.gray])
        view.addSubview(reInPasswdField)
        reInPasswdField.snp.makeConstraints({ (make) in
            make.left.equalTo(passwdField)
            make.top.equalTo(passwdField.snp.bottom).offset(20)
            make.right.equalTo(passwdField)
            make.height.equalTo(35)
        })
        
        for i in 0...2 {
            let fieldUnderLine = UIView()
            fieldUnderLine.tag = tags["fieldUnderLine"]! + i
            fieldUnderLine.backgroundColor = UIColor.gray
            view.addSubview(fieldUnderLine)
            fieldUnderLine.snp.makeConstraints({ (make) in
                make.left.equalTo(passwdField)
                make.right.equalTo(passwdField)
                make.bottom.equalTo(i == 0 ? passwdField : reInPasswdField).offset(1)
                make.height.equalTo(1)
            })
        }
        
        let sureBtn = UIButton()
        sureBtn.tag = tags["sureBtn"]!
        sureBtn.backgroundColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1)
        sureBtn.setTitle("确认", for: UIControlState())
        sureBtn.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: UIControlState())
        sureBtn.layer.cornerRadius = 45 / 2.0
        sureBtn.layer.masksToBounds = true
        sureBtn.addTarget(self, action: #selector(ResetPasswdVC.sureAction(_:)), for: .touchUpInside)
        view.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.left.equalTo(passwdField)
            make.right.equalTo(passwdField)
            make.top.equalTo(reInPasswdField.snp.bottom).offset(60)
            make.height.equalTo(45)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.tag = tags["sureBtn"]!
        cancelBtn.backgroundColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1)
        cancelBtn.setTitle("上一步", for: UIControlState())
        cancelBtn.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: UIControlState())
        cancelBtn.layer.cornerRadius = 45 / 2.0
        cancelBtn.layer.masksToBounds = true
        cancelBtn.addTarget(self, action: #selector(lastStep), for: .touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(passwdField)
            make.right.equalTo(passwdField)
            make.top.equalTo(sureBtn.snp.bottom).offset(25)
            make.height.equalTo(45)
        }
        
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ResetPasswdVC.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ResetPasswdVC.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ResetPasswdVC.registerAccountReply(_:)),
                                                         name: NSNotification.Name(rawValue: NotifyDefine.RegisterAccountReply),
                                                         object: nil)
    }
    
    func registerAccountReply(_ notification: Notification) {
        
        if let dict = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
            if dict["error_"] != nil {
                let errorCode = dict["error_"] as! Int
                let errorMsg = CommonDefine.errorMsgs[errorCode]
                SVProgressHUD.showErrorMessage(ErrorMessage: errorMsg!, ForDuration: 1, completion: nil)
                return
            }
            SVProgressHUD.dismiss()
            let loginDict = ["phone_num_": username!, "passwd_": passwd!, "user_type_": 1] as [String : Any]
            _ = SocketManager.sendData(.login, data: loginDict as AnyObject?)
            
        }
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
    
    func sureAction(_ sender: UIButton?) {
        if  passwd == nil || passwd?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入密码", ForDuration: 1, completion: nil)
            return
        }
        
        if  repasswd == nil || repasswd?.characters.count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请重新输入密码", ForDuration: 1, completion: nil)
            return
        }
        
        if passwd != repasswd {
            SVProgressHUD.showErrorMessage(ErrorMessage: "两次输入密码不一致", ForDuration: 1, completion: nil)
            return
        }
        
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        
        if token == nil {
          token = ""
        }
        let dict:Dictionary<String, AnyObject>? = ["phone_num_": username! as AnyObject,
                                                   "passwd_": passwd! as AnyObject,
                                                   "user_type_": 1 as AnyObject,
                                                   "timestamp_": verifyCodeTime as AnyObject,
                                                   "verify_code_": verifyCode as AnyObject,
                                                   "token_": token as AnyObject ]
        _ = SocketManager.sendData(.registerAccountRequest, data: dict as AnyObject?)
    
    }
    
    func lastStep() {
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["passwdField"]!:
            passwd = ""
            break
        case tags["reInPasswdField"]!:
            repasswd = ""
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
        if textField.tag == tags["reInPasswdField"]! {
            repasswd = (textField.text! as NSString).replacingCharacters(in: range, with: string)
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
