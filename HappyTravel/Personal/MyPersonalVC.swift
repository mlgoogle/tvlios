//
//  SideVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/3.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import SideMenuController
import XCGLogger

public class MyPersonalVC : UIViewController {
    
    var headImageView:UIImageView?

    var nameLabel:UILabel?
    
    class var shareInstance : MyPersonalVC {
        struct Static {
            static let instance:MyPersonalVC = MyPersonalVC()
        }
        return Static.instance
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        registerNotify()
    }
    
    func initView() {
        initPersonalView()
        
        initImportantNav()
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyPersonalVC.loginSuccessed(_:)), name: NotifyDefine.LoginSuccessed, object: nil)
    }
    
    func loginSuccessed(notification: NSNotification?) {
        let data = (notification?.userInfo!["data"])! as! Dictionary<String, AnyObject>
        UserInfo.currentUser.setInfo(.CurrentUser, info: data)
        UserInfo.currentUser.login = true
        initPersonalView()
        SocketManager.sendData(.GetServiceCity, data: nil)
        SocketManager.sendData(.GetServantInfo, data: nil)
    }
    
    func initPersonalView() {
        
        var personalView = view.viewWithTag(1001)
        if personalView == nil {
            personalView = UIView()
            personalView!.tag = 1001
            personalView!.backgroundColor = UIColor.init(red: 20/255.0, green: 31/255.0, blue: 51/255.0, alpha: 1)
            personalView!.userInteractionEnabled = true
            view.addSubview(personalView!)
            personalView!.snp_makeConstraints { (make) in
                make.top.equalTo(view)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(SideMenuController.preferences.drawing.sidePanelWidth / 4.0 * 3)
            }
        }
        
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = 10001
            headImageView!.backgroundColor = .clearColor()
            headImageView!.userInteractionEnabled = true
            headImageView!.contentMode = .ScaleToFill
            headImageView!.layer.masksToBounds = true
            headImageView!.layer.cornerRadius = 40
            headImageView!.layer.borderColor = UIColor.whiteColor().CGColor
            headImageView!.layer.borderWidth = 1
            personalView!.addSubview(headImageView!)
            headImageView!.snp_makeConstraints { (make) in
                make.centerY.equalTo(personalView!.snp_centerY)
                make.left.equalTo(personalView!.snp_left).offset(33)
                make.height.equalTo(80)
                make.width.equalTo(80)
            }
        }
        headImageView!.kf_setImageWithURL(NSURL(string: UserInfo.currentUser.headUrl == nil ? "https://avatars0.githubusercontent.com/u/5572659?v=3&s=460" : UserInfo.currentUser.headUrl!))
        
        if nameLabel == nil {
            nameLabel = UILabel()
            nameLabel!.tag = 10002
            nameLabel!.backgroundColor = .clearColor()
            nameLabel!.userInteractionEnabled = true
            nameLabel!.textAlignment = .Left
            nameLabel!.textColor = .whiteColor()
            nameLabel!.font = .systemFontOfSize(20)
            personalView!.addSubview(nameLabel!)
            nameLabel!.snp_makeConstraints { (make) in
                make.bottom.equalTo(headImageView!.snp_centerY).offset(-2.5)
                make.height.equalTo(20)
                make.left.equalTo(headImageView!.snp_right).offset(15)
                make.right.equalTo(personalView!.snp_right)
            }
        }
        nameLabel!.text = UserInfo.currentUser.nickname!
        
        var starView = personalView!.viewWithTag(10003)
        if starView == nil {
            starView = UIView()
            starView!.tag = 10003
            starView!.backgroundColor = .clearColor()
            personalView!.addSubview(starView!)
            starView!.snp_makeConstraints { (make) in
                make.left.equalTo(nameLabel!)
                make.top.equalTo(nameLabel!.snp_bottom).offset(10)
                make.right.equalTo(personalView!)
                make.height.equalTo(20)
            }
        }
        
        for i in 0...4 {
            var star = starView!.viewWithTag(10003*10 + i) as? UIImageView
            if star == nil {
                star = UIImageView()
                star!.backgroundColor = .clearColor()
                star!.tag = 10003*10 + i
                star!.contentMode = .ScaleAspectFit
                starView!.addSubview(star!)
                star!.snp_makeConstraints(closure: { (make) in
                    if i == 0 {
                        make.left.equalTo(starView!)
                    } else {
                        make.left.equalTo((starView!.viewWithTag(10003 * 10 + i - 1) as? UIImageView)!.snp_right).offset(10)
                    }
                    make.top.equalTo(starView!)
                    make.bottom.equalTo(starView!)
                    make.width.equalTo(17)
                })
            }
            if UserInfo.currentUser.level! / Float(i) >= 1 {
                star!.image = UIImage.init(named: "my-star-fill")
            } else {
                star!.image = UIImage.init(named: "my-star-hollow")
            }
            
        }
    }
    
    func initImportantNav() {
        let personalView = view.viewWithTag(1001)
        
        let importantNavVew = UIImageView()
        importantNavVew.tag = 1002
        importantNavVew.userInteractionEnabled = true
        importantNavVew.image = UIImage.init(named: "side-bg")
        view.addSubview(importantNavVew)
        importantNavVew.snp_makeConstraints { (make) in
            make.left.equalTo((personalView?.snp_left)!)
            make.right.equalTo((personalView?.snp_right)!)
            make.top.equalTo((personalView?.snp_bottom)!)
            make.bottom.equalTo(view)
        }
        
        let itemsTitle = ["钱包", "我的行程", "客服", "设置"]
        let itemsIcon = ["side-wallet", "side-travel", "side-service", "side-settings"]
        for index in 0...3 {
            let itemBtn = UIButton()
            itemBtn.tag = 10001 + index
            itemBtn.backgroundColor = UIColor.clearColor()
            itemBtn.setImage(UIImage.init(named: itemsIcon[index]), forState: UIControlState.Normal)
            itemBtn.setTitle(itemsTitle[index], forState: UIControlState.Normal)
            itemBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            itemBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
            itemBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            itemBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0)
            itemBtn.addTarget(self, action: #selector(MyPersonalVC.importantOptAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            importantNavVew.addSubview(itemBtn)
            itemBtn.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(importantNavVew.snp_left).offset(35)
                make.right.equalTo(importantNavVew.snp_right)
                make.top.equalTo(importantNavVew.snp_top).offset(25 + 50 * index)
                make.height.equalTo(25)
            })

        }
        
        let feedbackBtn = UIButton()
        feedbackBtn.tag = 10011
        feedbackBtn.backgroundColor = UIColor.clearColor()
        feedbackBtn.setImage(UIImage.init(named: "side-complain"), forState: UIControlState.Normal)
        feedbackBtn.setTitle("无情吐槽", forState: UIControlState.Normal)
        feedbackBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        feedbackBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        feedbackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        feedbackBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0)
        feedbackBtn.addTarget(self, action: #selector(MyPersonalVC.feedbackAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        importantNavVew.addSubview(feedbackBtn)
        feedbackBtn.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(importantNavVew.snp_left).offset(35)
            make.right.equalTo(importantNavVew.snp_right)
            make.bottom.equalTo(importantNavVew.snp_bottom).offset(-10)
            make.height.equalTo(20)
        })
        
    }
    
    func importantOptAction(sender: UIButton?) {
        switch sender!.tag {
        case 10001:
            XCGLogger.defaultInstance().debug("钱包")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToWalletVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10002:
            XCGLogger.defaultInstance().debug("我的行程")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToDistanceOfTravelVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10003:
            XCGLogger.defaultInstance().debug("客服")
        case 10004:
            XCGLogger.defaultInstance().debug("设置")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToSettingsVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        default:
            break
        }
    }
    
    func feedbackAction(sender: UIButton?) {
        XCGLogger.debug("无情吐槽")
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

