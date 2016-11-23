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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isShow = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isShow = false
    }

    func initView() {
        let bgView = UIImageView()
        bgView.isUserInteractionEnabled = true
        bgView.image = UIImage.init(named: "login-bg")
        view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let loginBtn = UIButton()
        loginBtn.tag = tags["loginBtn"]!
        loginBtn.backgroundColor = UIColor.init(red: 182/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1)
        loginBtn.setTitle("登录", for: UIControlState())
        loginBtn.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: UIControlState())
        loginBtn.layer.cornerRadius = 30 / 2.0
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: #selector(RegOrLoginSelVC.regOrLoginSelAction(_:)), for: .touchUpInside)
        view.addSubview(loginBtn)
        loginBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view).offset(45)
            make.width.equalTo(90)
            make.bottom.equalTo(view).offset(-80)
            make.height.equalTo(30)
        }
        
        let regBtn = UIButton()
        regBtn.tag = tags["regBtn"]!
        regBtn.backgroundColor = UIColor.init(red: 20/255.0, green: 31/255.0, blue: 49/255.0, alpha: 1)
        regBtn.setTitle("注册", for: UIControlState())
        regBtn.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: UIControlState())
        regBtn.layer.cornerRadius = 30 / 2.0
        regBtn.layer.masksToBounds = true
        regBtn.addTarget(self, action: #selector(RegOrLoginSelVC.regOrLoginSelAction(_:)), for: .touchUpInside)
        view.addSubview(regBtn)
        regBtn.snp_makeConstraints { (make) in
            make.right.equalTo(view).offset(-45)
            make.width.equalTo(90)
            make.bottom.equalTo(view).offset(-80)
            make.height.equalTo(30)
        }
        
    }
    
    func regOrLoginSelAction(_ sender: UIButton) {
        if sender.tag == tags["loginBtn"]! {
            loginVC = LoginVC()
            present(loginVC!, animated: false, completion: nil)
        } else if sender.tag == tags["regBtn"]! {
            let regVC = LoginWithMSGVC()
            present(regVC, animated: false, completion: nil)
//            let dict  = ["verify_type_": 0, "phone_num_": "15157109258"]
//            SocketManager.sendData(.SendMessageVerify, data: dict)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
