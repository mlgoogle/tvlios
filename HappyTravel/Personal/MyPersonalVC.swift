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
    
    var headImageView:UIButton?

    var nameLabel:UIButton?
    
    var serviceTel = "0571-87611687"
    
    var imagePicker:UIImagePickerController? = nil
    
    var headImagePath:String? = CurrentUser.head_url_
    
    var headImageName:String?
    
    var nickName:String? = CurrentUser.nickname_
    
    var token:String?
    

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccessed(_:)), name: NotifyDefine.LoginSuccessed, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUserInfo), name: NotifyDefine.ImproveDataNoticeToOthers, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkAuthResult(_:)), name: NotifyDefine.CheckAuthenticateResult, object: nil)
    }
    
    //查询认证状态
    func checkAuthResult(notice: NSNotification) {
        let data = notice.userInfo!["data"] as! NSDictionary
        let failedReson = data["failed_reason_"] as? NSString
        let reviewStatus = data.valueForKey("review_status_")?.integerValue
        if reviewStatus == -1 {
            return
        }
        if failedReson != "" {
            return
        }
//        DataManager.currentUser?.authentication = reviewStatus!
    }
    
    func updateUserInfo() {
        SVProgressHUD.dismiss()
        headImageView?.kf_setImageWithURL(NSURL.init(string: CurrentUser.head_url_!), forState: .Normal)
        nameLabel?.setTitle(CurrentUser.nickname_, forState: .Normal)
    }
    
    func loginSuccessed(notification: NSNotification?) {
        DataManager.setDefaultRealmForUID(CurrentUser.uid_)
        
        initPersonalView()
        
//        APIHelper.commonAPI().centurionCardBaseInfo({ (response) in
//            if let model = response as? CenturionCardBaseInfosModel {
//                DataManager.insertData(model)
//            }
//        }, error: { (err) in
//        
//        })
        
//        APIHelper.commonAPI().centurionCardPriceInfo({ (response) in
//            if let model = response as? CenturionCardPriceInfosModel {
//                DataManager.insertData(model)
//            }
//        }, error: { (err) in
//            
//        })
//        
//        let user = UserBaseModel()
//        user.uid_ = CurrentUser.uid_
//        APIHelper.userAPI().userCenturionCardInfo(user, complete: { (response) in
//            if let model = response as? UserCenturionCardInfoModel {
//                DataManager.insertData(model)
//                UserCenturionCardInfo = model
//            }
//        }, error: { (err) in
//        
//        })
        
        APIHelper.userAPI().authStatus({ (response) in
            if let dict = response as? [String: AnyObject] {
                if let status = dict["review_status_"] as? Int {
                    CurrentUser.auth_status_ = status
                }
            }
        }, error: nil)
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
            headImageView = UIButton()
            headImageView!.tag = 10001
            headImageView!.backgroundColor = .clearColor()
            headImageView!.layer.masksToBounds = true
            headImageView!.layer.cornerRadius = 40
            headImageView!.layer.borderColor = UIColor.whiteColor().CGColor
            headImageView!.layer.borderWidth = 1
            headImageView?.addTarget(self, action: #selector(MyPersonalVC.setHeadImage), forControlEvents: .TouchUpInside)
            personalView!.addSubview(headImageView!)
            headImageView!.snp_makeConstraints { (make) in
                make.centerY.equalTo(personalView!.snp_centerY)
                make.left.equalTo(personalView!.snp_left).offset(33)
                make.height.equalTo(80)
                make.width.equalTo(80)
            }
        }
        
        let url = NSURL(string: CurrentUser.head_url_ ?? "https://")
        headImageView?.kf_setImageWithURL(url, forState: .Normal, placeholderImage: Image.init(named: "default-head"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        
        if nameLabel == nil {
            nameLabel = UIButton()
            nameLabel!.tag = 10002
            nameLabel!.backgroundColor = .clearColor()
            nameLabel!.titleLabel?.textAlignment = .Left
            nameLabel!.titleLabel?.textColor = .whiteColor()
            nameLabel!.titleLabel?.font = .systemFontOfSize(AtapteWidthValue(20))
            nameLabel?.addTarget(self, action: #selector(MyPersonalVC.setNickName), forControlEvents: .TouchUpInside)
            personalView!.addSubview(nameLabel!)
            nameLabel!.snp_makeConstraints { (make) in
                make.bottom.equalTo(headImageView!.snp_centerY).offset(-2.5)
                make.height.equalTo(20)
                make.left.equalTo(headImageView!.snp_right).offset(15)
            }
        }

        nameLabel?.setTitle(CurrentUser.nickname_ ?? "未登录", forState: .Normal)
        nickName = CurrentUser.nickname_
        
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
                make.height.equalTo(AtapteWidthValue(24))
            }
        }
        
        var levelIcon = starView!.viewWithTag(100030) as? UIImageView
        if levelIcon == nil {
            levelIcon = UIImageView()
            levelIcon!.backgroundColor = UIColor.clearColor()
            levelIcon!.tag = 100030
            levelIcon?.contentMode = .ScaleAspectFit
            starView!.addSubview(levelIcon!)
            levelIcon?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(starView!)
                make.top.equalTo(starView!)
                make.bottom.equalTo(starView!)
                make.width.equalTo(AtapteWidthValue(24))
            })
        }
        
        let imageName = "lv" + "\(Int(CurrentUser.levle_))"
        levelIcon!.image = UIImage.init(named:imageName)
        
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
        
        let itemsTitle = ["钱包", "我的消费", "客服", "设置"] // "黑卡会员", 
        let itemsIcon = ["side-wallet", "side-wallet", "side-travel", "side-service", "side-settings"]
        for index in 0...itemsTitle.count - 1 {
            let itemBtn = UIButton()
            itemBtn.tag = 10000 + index
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
//        case 10000:
//            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToCenturionCardCenter, object: nil, userInfo: nil)
//            sideMenuController?.toggle()

        case 10000:
            XCGLogger.defaultInstance().debug("钱包")
             MobClick.event(CommonDefine.BuriedPoint.walletbtn)
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToWalletVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10001:
            XCGLogger.defaultInstance().debug("我的行程")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToDistanceOfTravelVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10002:
            XCGLogger.defaultInstance().debug("客服")
            callSrevant()
        case 10003:
            XCGLogger.defaultInstance().debug("设置")
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToSettingsVC, object: nil, userInfo: nil)
            sideMenuController?.toggle()
        default:
            break
        }
    }
    
    func callSrevant() {
        let alert = UIAlertController.init(title: "呼叫", message: serviceTel, preferredStyle: .Alert)
        let ensure = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.serviceTel)")!)
        })
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(ensure)
        alert.addAction(cancel)
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

