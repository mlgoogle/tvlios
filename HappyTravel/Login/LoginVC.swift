//
//  LoginVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/18.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class LoginVC: UIViewController {
    
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
        bgView.image = UIImage.init(named: "side-bg")
        view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let loginBtn = UIButton()
        loginBtn.tag = 1001
        loginBtn.backgroundColor = .clearColor()
        loginBtn.setTitle("消费者登录", forState: .Normal)
        loginBtn.setTitleColor(UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1), forState: .Normal)
        loginBtn.layer.borderColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1).CGColor
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: #selector(LoginVC.login(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(loginBtn)
        loginBtn.snp_makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        let servantLoginBtn = UIButton()
        servantLoginBtn.tag = 1002
        servantLoginBtn.backgroundColor = .clearColor()
        servantLoginBtn.setTitle("服务者登录", forState: .Normal)
        servantLoginBtn.setTitleColor(UIColor.init(red: 0/255.0, green: 120/255.0, blue: 200/255.0, alpha: 1), forState: .Normal)
        servantLoginBtn.layer.borderColor = UIColor.init(red: 0/255.0, green: 120/255.0, blue: 200/255.0, alpha: 1).CGColor
        servantLoginBtn.layer.borderWidth = 1
        servantLoginBtn.layer.cornerRadius = 5
        servantLoginBtn.layer.masksToBounds = true
        servantLoginBtn.addTarget(self, action: #selector(LoginVC.login(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(servantLoginBtn)
        servantLoginBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(loginBtn.snp_bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.loginResult(_:)), name: NotifyDefine.LoginResult, object: nil)
    }
    
    func login(sender: UIButton?) {
        var dict:Dictionary<String, AnyObject>?
        if sender?.tag == 1001 {
            dict = ["phone_num_": "15157109258", "passwd_": "223456", "user_type_": 1]
        } else {
            dict = ["phone_num_": "15158110001", "passwd_": "123456", "user_type_": 2]
        }
        
        SocketManager.sendData(.Login, data: dict)
        dismissViewControllerAnimated(true, completion: nil)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}
