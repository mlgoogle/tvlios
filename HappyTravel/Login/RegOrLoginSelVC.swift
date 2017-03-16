//
//  RegOrLoginSelVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/9.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation


class RegOrLoginSelVC: UIViewController {
    
    let tags = ["loginBtn": 1001,
                "regBtn": 1002]
    
    var loginVC:LoginVC?
    
    var isShow:Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        isShow = true
    }
 
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        isShow = false
    }
    
    func loginSuccessed(notification: NSNotification) {
        dismissViewControllerAnimated(false, completion: nil)
        
    }

    func initView() {
        let bgView = UIImageView()
        bgView.userInteractionEnabled = true
        bgView.image = UIImage.init(named: "background_bg")
        view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let loginBtn = UIButton()
        loginBtn.tag = tags["loginBtn"]!
        loginBtn.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        loginBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        loginBtn.setTitle("登录", forState: .Normal)
        loginBtn.setTitleColor(UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1).colorWithAlphaComponent(0.8), forState: .Normal)
        loginBtn.layer.cornerRadius = 45 / 2.0
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: #selector(RegOrLoginSelVC.regOrLoginSelAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(loginBtn)
        
        let regBtn = UIButton()
        regBtn.tag = tags["regBtn"]!
        regBtn.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        regBtn.setTitle("注册", forState: .Normal)
        regBtn.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Normal)
        regBtn.layer.cornerRadius = 45 / 2.0
        regBtn.layer.masksToBounds = true
        regBtn.addTarget(self, action: #selector(RegOrLoginSelVC.regOrLoginSelAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(regBtn)
        
        loginBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(regBtn.snp_left).offset(-20)
            make.height.equalTo(45)
            make.bottom.equalTo(view).offset(-50)
            make.width.equalTo(regBtn.snp_width)
        }

        regBtn.snp_makeConstraints { (make) in
            make.left.equalTo(loginBtn.snp_right).offset(20)
            make.right.equalTo(view).offset(-30)
            make.height.equalTo(45)
            make.bottom.equalTo(loginBtn.snp_bottom)
            make.width.equalTo(loginBtn.snp_width)
        }
        
    }
    
    func regOrLoginSelAction(sender: UIButton) {
//        YD_ContactManager.checkIfUploadContact()
        if sender.tag == tags["loginBtn"]! {
            loginVC = LoginVC()
            MobClick.event(CommonDefine.BuriedPoint.loginBtn)
            let navController = UINavigationController.init(rootViewController: loginVC!)
            presentViewController(navController, animated: false, completion: nil)
            
        } else if sender.tag == tags["regBtn"]! {
            let vc = LoginWithMSGVC()
            vc.title = "注册"
            MobClick.event(CommonDefine.BuriedPoint.rechargeBtn)
            let navController = UINavigationController.init(rootViewController: vc)
            presentViewController(navController, animated: false, completion: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
