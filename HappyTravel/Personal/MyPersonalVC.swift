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

open class MyPersonalVC : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initPersonalView()
        
//        initImagePick()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        registerNotify()
    }
    
    func initView() {
        initPersonalView()
        
        initImportantNav()
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(MyPersonalVC.loginSuccessed(_:)), name: NSNotification.Name(rawValue: NotifyDefine.LoginSuccessed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyPersonalVC.improveDataSuccessed(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ImproveDataSuccessed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyPersonalVC.uploadImageToken(_:)), name: NSNotification.Name(rawValue: NotifyDefine.UpLoadImageToken), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: NSNotification.Name(rawValue: NotifyDefine.ImproveDataNoticeToOthers), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthResult(_:)), name: NSNotification.Name(rawValue: NotifyDefine.CheckAuthenticateResult), object: nil)
    }
    
    //查询认证状态
    func checkAuthResult(_ notice: Notification) {
        let data = notice.userInfo!["data"] as! [String : AnyObject]
        let failedReson = data["failed_reason_"] as? NSString
        let reviewStatus = data["review_status_"] as! Int
        if reviewStatus == -1 {
            return
        }
        if failedReson != "" {
            return
        }
        DataManager.currentUser?.authentication = reviewStatus
    }
    
    func improveDataSuccessed(_ notification: Notification) {
        SVProgressHUD.dismiss()
        if headImagePath != nil {
            headImageView?.setImage(UIImage.init(contentsOfFile: headImagePath!), for: UIControlState())
            DataManager.currentUser?.headUrl = headImagePath
        }
        if nickName != nil {
            nameLabel?.setTitle(nickName!, for: UIControlState())
            DataManager.currentUser?.nickname = nickName
        }
    }
    
    func updateUserInfo() {
        SVProgressHUD.dismiss()
//        headImageView?.setImage(UIImage.init(contentsOfFile: DataManager.currentUser!.headUrl!), forState: .Normal)
        headImageView?.kf.setImage(with: URL.init(string: DataManager.currentUser!.headUrl!), for: .normal)
//        headImageView?.kf.setImageWithURL(URL.init(string: DataManager.currentUser!.headUrl!), forState: .Normal)
        nameLabel?.setTitle(DataManager.currentUser?.nickname, for: UIControlState())
    }
    
    func loginSuccessed(_ notification: Notification?) {
        let data = (notification?.userInfo!["data"])! as! Dictionary<String, AnyObject>
        DataManager.currentUser!.setInfo(.currentUser, info: data)
        DataManager.currentUser!.login = true
        DataManager.setDefaultRealmForUID(DataManager.currentUser!.uid)
        initPersonalView()
        
        _ = SocketManager.sendData(.getServiceCity, data: nil)
        let dict:Dictionary<String, AnyObject> = ["latitude_": DataManager.currentUser!.gpsLocationLat as AnyObject,
                                                  "longitude_": DataManager.currentUser!.gpsLocationLon as AnyObject,
                                                  "distance_": 20.1 as AnyObject]
        _ = SocketManager.sendData(.getServantInfo, data: dict as AnyObject?)
        if let dt = UserDefaults.standard.object(forKey: CommonDefine.DeviceToken) as? String {
            let dict = ["uid_": DataManager.currentUser!.uid,
                        "device_token_": dt] as [String : Any]
            _ = SocketManager.sendData(.putDeviceToken, data: dict as AnyObject?)
        }
        _ = SocketManager.sendData(.centurionCardInfoRequest, data: nil)
        _ = SocketManager.sendData(.centurionVIPPriceRequest, data: nil)
        _ = SocketManager.sendData(.userCenturionCardInfoRequest, data: ["uid_": DataManager.currentUser!.uid])
        _ = SocketManager.sendData(.skillsInfoRequest, data: nil)
        _ = SocketManager.sendData(.checkAuthenticateResult, data:["uid_": DataManager.currentUser!.uid])
        _ = SocketManager.sendData(.checkUserCash, data: ["uid_": DataManager.currentUser!.uid])

    }
    
    
    func setHeadImage() {
        
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.JumpToCompeleteBaseInfoVC), object: nil, userInfo: nil)
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
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.JumpToCompeleteBaseInfoVC), object: nil, userInfo: nil)
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
            personalView!.isUserInteractionEnabled = true
            view.addSubview(personalView!)
            personalView!.snp.makeConstraints { (make) in
                make.top.equalTo(view)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(SideMenuController.preferences.drawing.sidePanelWidth / 4.0 * 3)
            }
        }
        
        if headImageView == nil {
            headImageView = UIButton()
            headImageView!.tag = 10001
            headImageView!.backgroundColor = .clear
            headImageView!.layer.masksToBounds = true
            headImageView!.layer.cornerRadius = 40
            headImageView!.layer.borderColor = UIColor.white.cgColor
            headImageView!.layer.borderWidth = 1
            headImageView?.addTarget(self, action: #selector(MyPersonalVC.setHeadImage), for: .touchUpInside)
            personalView!.addSubview(headImageView!)
            headImageView!.snp.makeConstraints { (make) in
                make.centerY.equalTo(personalView!.snp.centerY)
                make.left.equalTo(personalView!.snp.left).offset(33)
                make.height.equalTo(80)
                make.width.equalTo(80)
            }
        }
        let url = URL(string: DataManager.currentUser!.headUrl == nil ? "https://" : DataManager.currentUser!.headUrl!)
        headImageView?.kf.setImage(with: url, for: .normal, placeholder: Image.init(named: "default-head"), options: nil, progressBlock: nil, completionHandler: nil)
//        headImageView?.kf_setImageWithURL(url, forState: .Normal, placeholderImage: Image.init(named: "default-head"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        
        if nameLabel == nil {
            nameLabel = UIButton()
            nameLabel!.tag = 10002
            nameLabel!.backgroundColor = .clear
            nameLabel!.titleLabel?.textAlignment = .left
            nameLabel!.titleLabel?.textColor = .white
            nameLabel!.titleLabel?.font = .systemFont(ofSize: AtapteWidthValue(20))
            nameLabel?.addTarget(self, action: #selector(MyPersonalVC.setNickName), for: .touchUpInside)
            personalView!.addSubview(nameLabel!)
            nameLabel!.snp.makeConstraints { (make) in
                make.bottom.equalTo(headImageView!.snp.centerY).offset(-2.5)
                make.height.equalTo(20)
                make.left.equalTo(headImageView!.snp.right).offset(15)
//                make.right.equalTo(personalView!.snp.right)
            }
        }
        nameLabel?.setTitle(DataManager.currentUser!.nickname!, for: UIControlState())
        nickName = DataManager.currentUser?.nickname
        
        var starView = personalView!.viewWithTag(10003)
        if starView == nil {
            starView = UIView()
            starView!.tag = 10003
            starView!.backgroundColor = .clear
            personalView!.addSubview(starView!)
            starView!.snp.makeConstraints { (make) in
                make.left.equalTo(nameLabel!)
                make.top.equalTo(nameLabel!.snp.bottom).offset(10)
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
//                star!.snp.makeConstraints(closure: { (make) in
//                    if i == 0 {
//                        make.left.equalTo(starView!)
//                    } else {
//                        make.left.equalTo((starView!.viewWithTag(10003 * 10 + i - 1) as? UIImageView)!.snp.right).offset(10)
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
            levelIcon!.backgroundColor = UIColor.clear
            levelIcon!.tag = 100030
            levelIcon?.contentMode = .scaleAspectFit
            starView!.addSubview(levelIcon!)
            levelIcon?.snp.makeConstraints({ (make) in
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
        importantNavVew.isUserInteractionEnabled = true
        importantNavVew.image = UIImage.init(named: "side-bg")
        view.addSubview(importantNavVew)
        importantNavVew.snp.makeConstraints { (make) in
            make.left.equalTo((personalView?.snp.left)!)
            make.right.equalTo((personalView?.snp.right)!)
            make.top.equalTo((personalView?.snp.bottom)!)
            make.bottom.equalTo(view)
        }
        
        let itemsTitle = ["黑卡会员", "钱包", "我的消费", "客服", "设置"]
        let itemsIcon = ["side-wallet", "side-wallet", "side-travel", "side-service", "side-settings"]
        for index in 0...itemsTitle.count - 1 {
            let itemBtn = UIButton()
            itemBtn.tag = 10000 + index
            itemBtn.backgroundColor = UIColor.clear
            itemBtn.setImage(UIImage.init(named: itemsIcon[index]), for: UIControlState())
            itemBtn.setTitle(itemsTitle[index], for: UIControlState())
            itemBtn.setTitleColor(UIColor.white, for: UIControlState())
            itemBtn.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
            itemBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            itemBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0)
            itemBtn.addTarget(self, action: #selector(MyPersonalVC.importantOptAction(_:)), for: UIControlEvents.touchUpInside)
            importantNavVew.addSubview(itemBtn)
            itemBtn.snp.makeConstraints({ (make) in
                make.left.equalTo(importantNavVew.snp.left).offset(35)
                make.right.equalTo(importantNavVew.snp.right)
                make.top.equalTo(importantNavVew.snp.top).offset(25 + 50 * index)
                make.height.equalTo(25)
            })

        }
        
        let feedbackBtn = UIButton()
        feedbackBtn.tag = 10011
        feedbackBtn.backgroundColor = UIColor.clear
        feedbackBtn.setImage(UIImage.init(named: "side-complain"), for: UIControlState())
        feedbackBtn.setTitle("无情吐槽", for: UIControlState())
        feedbackBtn.setTitleColor(UIColor.white, for: UIControlState())
        feedbackBtn.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        feedbackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        feedbackBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0)
        feedbackBtn.addTarget(self, action: #selector(MyPersonalVC.feedbackAction(_:)), for: UIControlEvents.touchUpInside)
        importantNavVew.addSubview(feedbackBtn)
        feedbackBtn.snp.makeConstraints({ (make) in
            make.left.equalTo(importantNavVew.snp.left).offset(35)
            make.right.equalTo(importantNavVew.snp.right)
            make.bottom.equalTo(importantNavVew.snp.bottom).offset(-10)
            make.height.equalTo(20)
        })
        
    }
    
    func importantOptAction(_ sender: UIButton?) {
        switch sender!.tag {
        case 10000:
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.JumpToCenturionCardCenter), object: nil, userInfo: nil)
            sideMenuController?.toggle()

        case 10001:
            XCGLogger.default.debug("钱包")
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.JumpToWalletVC), object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10002:
            XCGLogger.default.debug("我的行程")
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.JumpToDistanceOfTravelVC), object: nil, userInfo: nil)
            sideMenuController?.toggle()
        case 10003:
            XCGLogger.default.debug("客服")
            callSrevant()
        case 10004:
            XCGLogger.default.debug("设置")
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.JumpToSettingsVC), object: nil, userInfo: nil)
            sideMenuController?.toggle()
        default:
            break
        }
    }
    
    func callSrevant() {
        let alert = UIAlertController.init(title: "呼叫", message: serviceTel, preferredStyle: .alert)
        let ensure = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
            UIApplication.shared.openURL(URL(string: "tel://\(self.serviceTel)")!)
        })
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(ensure)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    func feedbackAction(_ sender: UIButton?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.FeedBackNoticeReply), object: nil, userInfo: nil)
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
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        headImageView?.setImage(image.reSizeImage(CGSize(width: 100, height: 100)), for: UIControlState())
        
        imagePicker?.dismiss(animated: true, completion: nil)
        
        //先把图片转成NSData
        let data = UIImageJPEGRepresentation(image, 0.5)
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        
        //Home目录
        let homeDirectory = NSHomeDirectory()
        let documentPath = homeDirectory + "/Documents"
        //文件管理器
        let fileManager: FileManager = FileManager.default
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        do {
            try fileManager.createDirectory(atPath: documentPath, withIntermediateDirectories: true, attributes: nil)
            
        }
        catch _ {
        }
        let timestemp:Int = Int(Date().timeIntervalSince1970)
        let fileName = "/\(DataManager.currentUser!.uid)_\(timestemp).png"
        headImageName = fileName
        fileManager.createFile(atPath: documentPath + fileName, contents: data, attributes: nil)
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
            
            qnManager?.putFile(headImagePath!, key: "user_center/head\(headImageName!)", token: token!, complete: { (info, key, resp) -> Void in
                
                if info?.statusCode != 200 || resp == nil {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    SVProgressHUD.showErrorMessage(ErrorMessage: "提交失败，请稍后再试！", ForDuration: 1, completion: nil)
                    return
                }
                
                if (info?.statusCode == 200 ){
                    let respDic: NSDictionary? = resp as NSDictionary?
                    let value:String? = respDic!.value(forKey: "key") as? String
                    let url = qiniuHost + value!
                    
                    let addr = "http://restapi.amap.com/v3/geocode/geo?key=389880a06e3f893ea46036f030c94700&s=rsv3&city=35&address=%E6%9D%AD%E5%B7%9E"
                    Alamofire.request(addr).responseJSON(completionHandler: { (response) in
                        
                        let geocodes = ((response.result.value as? Dictionary<String, AnyObject>)!["geocodes"] as! Array<Dictionary<String, AnyObject>>).first
                        
                        let location = (geocodes!["location"] as! String).components(separatedBy: ",")
                        XCGLogger.debug("\(location)")
                        
                        let dict:Dictionary<String, AnyObject> = ["uid_": (DataManager.currentUser?.uid)! as AnyObject,
                                                                  "nickname_": (DataManager.currentUser?.nickname)! as AnyObject,
                                                                  "gender_": (DataManager.currentUser?.gender)! as AnyObject,
                                                                  "head_url_": url as AnyObject,
                                                                  "address_": (DataManager.currentUser?.address)! as AnyObject,
                                                                  "longitude_": (DataManager.currentUser?.gpsLocationLon)! as AnyObject,
                                                                  "latitude_": (DataManager.currentUser?.gpsLocationLat)! as AnyObject]
                       _ = SocketManager.sendData(.sendImproveData, data: dict)

                    })
//                    Alamofire.request(.GET, addr).responseJSON() { response in
//                        let geocodes = ((response.result.value as? Dictionary<String, AnyObject>)!["geocodes"] as! Array<Dictionary<String, AnyObject>>).first
//                        let location = (geocodes!["location"] as! String).componentsSeparatedByString(",")
//                        XCGLogger.debug("\(location)")
//                        
//                        let dict:Dictionary<String, AnyObject> = ["uid_": (DataManager.currentUser?.uid)!,
//                            "nickname_": (DataManager.currentUser?.nickname)!,
//                            "gender_": (DataManager.currentUser?.gender)!,
//                            "head_url_": url,
//                            "address_": (DataManager.currentUser?.address)!,
//                            "longitude_": (DataManager.currentUser?.gpsLocationLon)!,
//                            "latitude_": (DataManager.currentUser?.gpsLocationLat)!]
//                        SocketManager.sendData(.SendImproveData, data: dict)
//                        
//                        
//                    }
                }
                
            }, option: nil)
        } else {
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法提交，请稍后再试", ForDuration: 1, completion: {
                _ = SocketManager.sendData(.uploadImageToken, data: nil)
            })
        }
        
    }
    //MARK: --
    
    //上传图片Token
    func uploadImageToken(_ notice: Notification?) {
        let data = notice?.userInfo!["data"] as! NSDictionary
        let code = data.value(forKey: "code")
        if (code as AnyObject).int32Value == 0 {
            unowned let weakSelf = self
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法验证，请稍后再试", ForDuration: 1, completion: {
               _ =  weakSelf.navigationController?.popViewController(animated: true)
            })
            return
        }

        token = data.value(forKey: "img_token_") as? String
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

