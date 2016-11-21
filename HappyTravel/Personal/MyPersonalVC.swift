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
    
    var serviceTel = "10086"
    
    var imagePicker:UIImagePickerController? = nil
    
    var headImagePath:String? = DataManager.currentUser?.headUrl
    
    var headImageName:String?
    
    var nickName:String? = DataManager.currentUser?.nickname
    
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
        
//        initImagePick()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyPersonalVC.improveDataSuccessed(_:)), name: NotifyDefine.ImproveDataSuccessed, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyPersonalVC.uploadImageToken(_:)), name: NotifyDefine.UpLoadImageToken, object: nil)

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
        DataManager.currentUser?.authentication = reviewStatus!
    }
    
    func improveDataSuccessed(notification: NSNotification) {
        SVProgressHUD.dismiss()
        if headImagePath != nil {
            headImageView?.setImage(UIImage.init(contentsOfFile: headImagePath!), forState: .Normal)
            DataManager.currentUser?.headUrl = headImagePath
        }
        if nickName != nil {
            nameLabel?.setTitle(nickName!, forState: .Normal)
            DataManager.currentUser?.nickname = nickName
        }
    }
    
    func updateUserInfo() {
        SVProgressHUD.dismiss()
//        headImageView?.setImage(UIImage.init(contentsOfFile: DataManager.currentUser!.headUrl!), forState: .Normal)
        
        headImageView?.kf_setImageWithURL(NSURL.init(string: DataManager.currentUser!.headUrl!), forState: .Normal)
        nameLabel?.setTitle(DataManager.currentUser?.nickname, forState: .Normal)
    }
    
    func loginSuccessed(notification: NSNotification?) {
        let data = (notification?.userInfo!["data"])! as! Dictionary<String, AnyObject>
        DataManager.currentUser!.setInfo(.CurrentUser, info: data)
        DataManager.currentUser!.login = true
        DataManager.setDefaultRealmForUID(DataManager.currentUser!.uid)
        initPersonalView()
        
        SocketManager.sendData(.GetServiceCity, data: nil)
        let dict:Dictionary<String, AnyObject> = ["latitude_": DataManager.currentUser!.gpsLocationLat,
                                                  "longitude_": DataManager.currentUser!.gpsLocationLon,
                                                  "distance_": 20.1]
        SocketManager.sendData(.GetServantInfo, data: dict)
        if let dt = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.DeviceToken) as? String {
            let dict = ["uid_": DataManager.currentUser!.uid,
                        "device_token_": dt]
            SocketManager.sendData(.PutDeviceToken, data: dict)
        }
        SocketManager.sendData(.CenturionCardInfoRequest, data: nil)
        SocketManager.sendData(.UserCenturionCardInfoRequest, data: ["uid_": DataManager.currentUser!.uid])
        SocketManager.sendData(.SkillsInfoRequest, data: nil)
        SocketManager.sendData(.CheckAuthenticateResult, data:["uid_": DataManager.currentUser!.uid])
        SocketManager.sendData(.CheckUserCash, data: ["uid_": DataManager.currentUser!.uid])
    }
    
    func setHeadImage() {
        
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToCompeleteBaseInfoVC, object: nil, userInfo: nil)
        sideMenuController?.toggle()
//        SocketManager.sendData(.UploadImageToken, data: nil)
//        
//        let sheetController = UIAlertController.init(title: "选择图片", message: nil, preferredStyle: .ActionSheet)
//        let cancelAction:UIAlertAction! = UIAlertAction.init(title: "取消", style: .Cancel) { action in
//            
//        }
//        let cameraAction:UIAlertAction! = UIAlertAction.init(title: "相机", style: .Default) { action in
//            self.imagePicker?.sourceType = .Camera
//            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
//        }
//        let labAction:UIAlertAction! = UIAlertAction.init(title: "相册", style: .Default) { action in
//            self.imagePicker?.sourceType = .PhotoLibrary
//            
//            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
//        }
//        sheetController.addAction(cancelAction)
//        sheetController.addAction(cameraAction)
//        sheetController.addAction(labAction)
//        presentViewController(sheetController, animated: true, completion: nil)
    }
    
    func setNickName() {
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToCompeleteBaseInfoVC, object: nil, userInfo: nil)
        sideMenuController?.toggle()
//        let alert = UIAlertController.init(title: "修改昵称", message: nil, preferredStyle: .Alert)
//        alert.addTextFieldWithConfigurationHandler({ (textField) in
//            textField.text = (DataManager.currentUser?.nickname)!
//        })
//        let ok = UIAlertAction.init(title: "修改", style: .Default, handler: { (action) in
//            SVProgressHUD.displayDurationForString("提交修改中，请稍后！")
//            self.nickName = (alert.textFields?.first?.text)!
//            let dict:Dictionary<String, AnyObject> = ["uid_": (DataManager.currentUser?.uid)!,
//                "nickname_": self.nickName!,
//                "gender_": (DataManager.currentUser?.gender)!,
//                "head_url_": (DataManager.currentUser?.headUrl)!,
//                "address_": (DataManager.currentUser?.address)!,
//                "longitude_": (DataManager.currentUser?.gpsLocationLon)!,
//                "latitude_": (DataManager.currentUser?.gpsLocationLat)!]
//            SocketManager.sendData(.SendImproveData, data: dict)
//        })
//        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
//        alert.addAction(ok)
//        alert.addAction(cancel)
//        presentViewController(alert, animated: true, completion: nil)
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
        let url = NSURL(string: DataManager.currentUser!.headUrl == nil ? "https://" : DataManager.currentUser!.headUrl!)
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
//                make.right.equalTo(personalView!.snp_right)
            }
        }
        nameLabel?.setTitle(DataManager.currentUser!.nickname!, forState: .Normal)
        nickName = DataManager.currentUser?.nickname
        
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
        
//        for i in 0...4 {
//            var star = starView!.viewWithTag(10003*10 + i) as? UIImageView
//            if star == nil {
//                star = UIImageView()
//                star!.backgroundColor = .clearColor()
//                star!.tag = 10003*10 + i
//                star!.contentMode = .ScaleAspectFit
//                starView!.addSubview(star!)
//                star!.snp_makeConstraints(closure: { (make) in
//                    if i == 0 {
//                        make.left.equalTo(starView!)
//                    } else {
//                        make.left.equalTo((starView!.viewWithTag(10003 * 10 + i - 1) as? UIImageView)!.snp_right).offset(10)
//                    }
//                    make.top.equalTo(starView!)
//                    make.bottom.equalTo(starView!)
//                    make.width.equalTo(17)
//                })
//            }
//            if DataManager.currentUser!.level / Float(i) >= 1 {
//                star!.image = UIImage.init(named: "my-star-fill")
//            } else {
//                star!.image = UIImage.init(named: "my-star-hollow")
//            }
//            
//        }
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
        
        let imageName = "lv" + "\(Int(DataManager.currentUser!.level))"
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
        
        let itemsTitle = ["黑卡会员", "钱包", "我的消费", "客服", "设置"]
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
        case 10000:
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.JumpToCenturionCardCenter, object: nil, userInfo: nil)
            sideMenuController?.toggle()

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
            callSrevant()
        case 10004:
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
    
    
    // MARK: - UIImagePickreControllerDelegate
    func initImagePick() {
        if imagePicker == nil {
            imagePicker = UIImagePickerController()
            imagePicker?.delegate = self
            imagePicker?.allowsEditing = true
        }
        
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        headImageView?.setImage(image.reSizeImage(CGSizeMake(100, 100)), forState: .Normal)
        
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        
        //先把图片转成NSData
        let data = UIImageJPEGRepresentation(image, 0.5)
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        
        //Home目录
        let homeDirectory = NSHomeDirectory()
        let documentPath = homeDirectory + "/Documents"
        //文件管理器
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        do {
            try fileManager.createDirectoryAtPath(documentPath, withIntermediateDirectories: true, attributes: nil)
            
        }
        catch _ {
        }
        let timestemp:Int = Int(NSDate().timeIntervalSince1970)
        let fileName = "/\(DataManager.currentUser!.uid)_\(timestemp).png"
        headImageName = fileName
        fileManager.createFileAtPath(documentPath.stringByAppendingString(fileName), contents: data, attributes: nil)
        //得到选择后沙盒中图片的完整路径
        let filePath: String = String(format: "%@%@", documentPath, fileName)
        headImagePath = filePath
        updateHeadImage()
    }
    
    func updateHeadImage() {
        if token != nil {
            let qiniuHost = "http://ofr5nvpm7.bkt.clouddn.com/"
            let qnManager = QNUploadManager()
            SVProgressHUD.showProgressMessage(ProgressMessage: "提交中...")
            
            qnManager.putFile(headImagePath!, key: "user_center/head\(headImageName!)", token: token!, complete: { (info, key, resp) -> Void in
                
                if info.statusCode != 200 || resp == nil {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    SVProgressHUD.showErrorMessage(ErrorMessage: "提交失败，请稍后再试！", ForDuration: 1, completion: nil)
                    return
                }
                
                if (info.statusCode == 200 ){
                    let respDic: NSDictionary? = resp
                    let value:String? = respDic!.valueForKey("key") as? String
                    let url = qiniuHost + value!
                    
                    let addr = "http://restapi.amap.com/v3/geocode/geo?key=389880a06e3f893ea46036f030c94700&s=rsv3&city=35&address=%E6%9D%AD%E5%B7%9E"
                    Alamofire.request(.GET, addr).responseJSON() { response in
                        let geocodes = ((response.result.value as? Dictionary<String, AnyObject>)!["geocodes"] as! Array<Dictionary<String, AnyObject>>).first
                        let location = (geocodes!["location"] as! String).componentsSeparatedByString(",")
                        XCGLogger.debug("\(location)")
                        
                        let dict:Dictionary<String, AnyObject> = ["uid_": (DataManager.currentUser?.uid)!,
                            "nickname_": (DataManager.currentUser?.nickname)!,
                            "gender_": (DataManager.currentUser?.gender)!,
                            "head_url_": url,
                            "address_": (DataManager.currentUser?.address)!,
                            "longitude_": (DataManager.currentUser?.gpsLocationLon)!,
                            "latitude_": (DataManager.currentUser?.gpsLocationLat)!]
                        SocketManager.sendData(.SendImproveData, data: dict)
                        
                        
                    }
                }
                
            }, option: nil)
        } else {
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法提交，请稍后再试", ForDuration: 1, completion: {
                SocketManager.sendData(.UploadImageToken, data: nil)
            })
        }
        
    }
    //MARK: --
    
    //上传图片Token
    func uploadImageToken(notice: NSNotification?) {
        let data = notice?.userInfo!["data"] as! NSDictionary
        let code = data.valueForKey("code")
        if code?.intValue == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法验证，请稍后再试", ForDuration: 1, completion: {
                self.navigationController?.popViewControllerAnimated(true)
            })
            return
        }

        token = data.valueForKey("img_token_") as? String
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

