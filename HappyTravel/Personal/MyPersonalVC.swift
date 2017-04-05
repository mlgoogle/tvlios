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
import RealmSwift
import Qiniu
import SVProgressHUD
import Alamofire

public class MyPersonalVC : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var starView:UIImageView?
    
    var headImageView:UIButton?

    var nameLabel:UIButton?
    
    var imagePicker:UIImagePickerController? = nil
    
    var headImagePath:String? = CurrentUser.head_url_
    
    var headImageName:String?
    
    var nickName:String? = CurrentUser.nickname_
    
    var token:String?
    
    var consumeBtn: UIButton = UIButton()

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
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        initPersonalView()
    }
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        consumeBtn.setImage(nil, forState: UIControlState.Normal)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        initView()
        
        registerNotify()
    }
    
    func initView() {
        initPersonalView()
        
        initImportantNav()
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccessed(_:)), name: NotifyDefine.LoginSuccessed, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUserInfo), name: NotifyDefine.ImproveDataNoticeToOthers, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orderListNotEvaluate(_:)), name: NotifyDefine.OrderList, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orderListEvaluate(_:)), name: NotifyDefine.OrderListNo, object: nil)
    }
    //通知实现
    func orderListEvaluate(notification: NSNotification?) {
        consumeBtn.setImage(nil, forState: UIControlState.Normal)
    }
    
    func orderListNotEvaluate(notification: NSNotification?) {
        consumeBtn.setImage(UIImage.init(named: "redDot"), forState: UIControlState.Normal)
    }
    
    func updateUserInfo() {
        SVProgressHUD.dismiss()
        headImageView?.kf_setImageWithURL(NSURL.init(string: CurrentUser.head_url_!), forState: .Normal)
        nameLabel?.setTitle(CurrentUser.nickname_, forState: .Normal)
    }
    
    func loginSuccessed(notification: NSNotification?) {
        DataManager.setDefaultRealmForUID(CurrentUser.uid_)
        initPersonalView()
        APIHelper.userAPI().cash({ (response) in
            if let dict = response as? [String: AnyObject] {
                if let cash = dict["user_cash_"] as? Int {
                    CurrentUser.user_cash_ = cash
                }
                if let hasPasswd = dict["has_passwd_"] as? Int {
                    CurrentUser.has_passwd_ = hasPasswd
                }
            }
        }, error: nil)
    }
    
    
    func setHeadImage() {
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToCompeleteBaseInfoVC, object: nil, userInfo: nil)
        sideMenuController?.toggle()

    }
    
    func setNickName() {
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToCompeleteBaseInfoVC, object: nil, userInfo: nil)
        sideMenuController?.toggle()

    }
    
    func initPersonalView() {
        if starView == nil {
            starView = UIImageView()
            starView!.tag = 10003
            starView?.image = UIImage.init(named: "side-headBase")
            view.addSubview(starView!)
            starView!.snp_makeConstraints { (make) in
                make.centerX.equalTo(view)
                make.top.equalTo(view).offset(74)
                make.height.equalTo(77)
                make.width.equalTo(77)
            }
        }
        
        if headImageView == nil {
            headImageView = UIButton()
            headImageView!.tag = 10001
            headImageView!.backgroundColor = .clearColor()
            headImageView!.layer.masksToBounds = true
            headImageView!.layer.cornerRadius = 67 / 2
            headImageView?.addTarget(self, action: #selector(MyPersonalVC.setHeadImage), forControlEvents: .TouchUpInside)
            view.addSubview(headImageView!)
            headImageView!.snp_makeConstraints { (make) in
                make.center.equalTo(starView!)
                make.height.equalTo(67)
                make.width.equalTo(67)
            }
        }
        
        let url = NSURL(string: CurrentUser.head_url_ ?? "https://")
        headImageView?.kf_setImageWithURL(url, forState: .Normal, placeholderImage: Image.init(named: "defaultIcon"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        
        if nameLabel == nil {
            nameLabel = UIButton()
            nameLabel!.tag = 10002
            nameLabel!.backgroundColor = UIColor.clearColor()
            nameLabel!.titleLabel?.textAlignment = .Center
            nameLabel?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            nameLabel!.titleLabel?.font = UIFont.systemFontOfSize(16)
            nameLabel?.addTarget(self, action: #selector(MyPersonalVC.setNickName), forControlEvents: .TouchUpInside)
            view.addSubview(nameLabel!)
            nameLabel!.snp_makeConstraints { (make) in
                make.top.equalTo((headImageView?.snp_bottom)!).offset(15)
                make.centerX.equalTo(headImageView!)
                make.height.equalTo(16)
            }
        }
        nameLabel?.setTitle(CurrentUser.nickname_ ?? "未登录", forState: .Normal)
        nickName = CurrentUser.nickname_
    }
    
    func initImportantNav() {
        let itemsTitle = ["我的钱包", "我的消费", "客服", "设置"]
        let itemsIcon = ["side-wallet", "side-travel", "side-service", "side-settings"]
        
        for index in 0..<itemsTitle.count {
            let itemBtn = UIButton()
            let iconView = UIImageView()
            iconView.image = UIImage.init(named: itemsIcon[index])
  
            itemBtn.tag = 10000 + index
            itemBtn.backgroundColor = UIColor.clearColor()
            itemBtn.titleLabel?.textAlignment = .Center
            itemBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
            itemBtn.setTitle(itemsTitle[index], forState: UIControlState.Normal)
            itemBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            itemBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
            itemBtn.addTarget(self, action: #selector(importantOptAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            itemBtn.contentHorizontalAlignment = .Left
            if itemBtn.tag == 10001 {
                consumeBtn = itemBtn
                itemBtn.imageEdgeInsets = UIEdgeInsets(top: -12, left: 70, bottom: 0, right: 0) // 6/6s
                itemBtn.setImage(UIImage.init(named: "redDot"), forState: UIControlState.Normal)
            }
            view.addSubview(itemBtn)
            view.addSubview(iconView)
            
            iconView.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(view).offset(30)
                make.height.equalTo(18)
                make.width.equalTo(18)
                make.top.equalTo((nameLabel?.snp_bottom)!).offset(56 + 47 * index)
            })
            itemBtn.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(iconView.snp_right).offset(10)
                make.right.equalTo(view.snp_right)
                make.centerY.equalTo(iconView)
                make.height.equalTo(16)
            })
        }
        
        let feedbackBtn = UIButton()
        feedbackBtn.tag = 10011
        feedbackBtn.backgroundColor = UIColor.clearColor()
        feedbackBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        feedbackBtn.setTitle("无情吐槽", forState: UIControlState.Normal)
        feedbackBtn.setTitleColor(UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1), forState: .Normal)
        feedbackBtn.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        feedbackBtn.addTarget(self, action: #selector(feedbackAction(_:)), forControlEvents: .TouchUpInside)
        feedbackBtn.setImage(UIImage.init(named: "side-spitIcon"), forState: UIControlState.Normal)
        feedbackBtn.contentHorizontalAlignment = .Left
        
        feedbackBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left:57, bottom: 0, right: 0)
        feedbackBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        
        view.addSubview(feedbackBtn)
        feedbackBtn.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view).offset(-31)
            make.height.equalTo(51)
        })
        
    }
    
    func importantOptAction(sender: UIButton?) {
        switch sender!.tag {
        case 10000:
            MobClick.event(CommonDefine.BuriedPoint.walletbtn)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToWalletVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10001:
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToMessageCenter, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10002:
            callSrevant()
        case 10003:
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToSettingsVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        default:
            break
        }
    }
    
    func callSrevant() {
        let serviceWeChat = "yundian2016"
        let alert = UIAlertController.init(title: "优悦出行客服微信号", message: serviceWeChat, preferredStyle: .Alert)
        let ensure = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
        })
        let cancel = UIAlertAction.init(title: "复制微信号", style: .Default, handler: { (action: UIAlertAction) in
            UIPasteboard.generalPasteboard().string = serviceWeChat
            SVProgressHUD.showSuccessMessage(SuccessMessage: "复制成功", ForDuration: 1.0   , completion: {
                SVProgressHUD.dismiss()
            })
        })
        alert.addAction(cancel)
        alert.addAction(ensure)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func feedbackAction(sender: UIButton?) {
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.FeedBackNoticeReply, object: nil, userInfo: nil)
        sideMenuController?.toggle()
        XCGLogger.debug("无情吐槽")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
