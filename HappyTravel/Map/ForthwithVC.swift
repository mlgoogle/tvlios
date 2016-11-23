//
//  ForthwithVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SnapKit
import XCGLogger
import RealmSwift
import MJRefresh
import SVProgressHUD
open class ForthwithVC: UIViewController, MAMapViewDelegate, CitysSelectorSheetDelegate, ServantIntroCellDelegate {
    
    var titleLab:UILabel?
    var titleBtn:UIButton?
    var msgCountLab:UILabel?
    var segmentSC:UISegmentedControl?
    var mapView:MAMapView?
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    var servantsInfo:Dictionary<Int, UserInfo> = [:]
    var annotations:Array<MAPointAnnotation> = []
    var login = false
    var serviceCitys:Dictionary<Int, CityInfo> = [:]
    var citysAlertController:UIAlertController?
    var recommendServants:Array<UserInfo> = []
    var subscribeServants:Array<UserInfo> = []
    var locality:String?
    var location:CLLocation?
    var regOrLoginSelVC:RegOrLoginSelVC? = RegOrLoginSelVC()
    var cityCode = 0
    var firstLanch = true
    let bottomSelector = UISlider()
    let appointmentView = AppointmentView()
    var feedBack: YWFeedbackKit = YWFeedbackKit.init(appKey: "23519848")
    //延时测试用
    var appointment_id_ = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        firstLanch = true
        
        initView()
        
        registerNotify()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotifyDefine.ServantDetailInfo), object: nil)
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ForthwithVC.servantDetailInfo(_:)),
                                                         name: NSNotification.Name(rawValue: NotifyDefine.ServantDetailInfo),
                                                         object: nil)

        if navigationItem.rightBarButtonItem == nil {
            let msgBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            msgBtn.setImage(UIImage.init(named: "nav-msg"), for: UIControlState())
            msgBtn.backgroundColor = UIColor.clear
            msgBtn.addTarget(self, action: #selector(ForthwithVC.msgAction(_:)), for: .touchUpInside)
            
            let msgItem = UIBarButtonItem.init(customView: msgBtn)
            navigationItem.rightBarButtonItem = msgItem

            msgCountLab = UILabel()
            msgCountLab!.backgroundColor = UIColor.red
            msgCountLab!.text = ""
            msgCountLab!.textColor = UIColor.white
            msgCountLab!.textAlignment = .center
            msgCountLab!.font = UIFont.systemFont(ofSize: S10)
            msgCountLab!.layer.cornerRadius = 18 / 2.0
            msgCountLab!.layer.masksToBounds = true
            msgCountLab!.isHidden = true
            msgBtn.addSubview(msgCountLab!)
            msgCountLab!.snp_makeConstraints({ (make) in
                make.right.equalTo(msgBtn).offset(5)
                make.top.equalTo(msgBtn).offset(-2)
                make.width.equalTo(18)
                make.height.equalTo(18)
            })
            
        }
        
        if DataManager.getUnreadMsgCnt(-1) > 0 {
            msgCountLab?.text = "\(DataManager.getUnreadMsgCnt(-1))"
            msgCountLab?.isHidden = false
        } else {
            msgCountLab?.isHidden = true
        }
        
        if DataManager.currentUser?.login == false {
            mapView!.setZoomLevel(11, animated: true)
            if regOrLoginSelVC?.isShow == false {
                present(regOrLoginSelVC!, animated: true, completion: nil)
            }
        } else {
            if DataManager.currentUser!.registerSstatus == 0 {
                let completeBaseInfoVC = CompleteBaseInfoVC()
                self.navigationController?.pushViewController(completeBaseInfoVC, animated: true)
            }
        }
        
        appointmentView.commitBtn?.isEnabled = true
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        appointmentView.nav = navigationController
        checkLocationService()
    }
    
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            let alert = UIAlertController.init(title: "提示", message: "定位服务异常：请确定定位服务已开启，并允许V领队使用定位服务", preferredStyle: .alert)
            let goto = UIAlertAction.init(title: "前往设置", style: .default, handler: { (action) in
                if #available(iOS 10, *) {
                    UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
                } else {
                    UIApplication.shared.openURL(URL.init(string: "prefs:root=LOCATION_SERVICES")!)
                }
                
            })
            let cancel = UIAlertAction.init(title: "取消", style: .default, handler: nil)
            alert.addAction(goto)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func initView() {
        let width = UIScreen.main.bounds.width
        let titleView = UIView.init(frame: CGRect(x: 0,y: 0,width: width,height: 40))
        titleView.backgroundColor = .clear
        titleView.isUserInteractionEnabled = true
        navigationItem.titleView = titleView
        
        titleLab = UILabel()
        titleLab?.backgroundColor = .clear
        titleLab?.textColor = .white
        titleLab?.font = UIFont.systemFont(ofSize: S18)
        titleLab?.textAlignment = .center
        titleLab?.isUserInteractionEnabled = true
        titleView.addSubview(titleLab!)
        titleLab!.snp_makeConstraints { (make) in
            make.centerX.equalTo(titleView.snp_centerX).offset(-10)
            make.centerY.equalTo(titleView.snp_centerY)
        }
        titleLab?.text = "我的位置"
        
        titleBtn = UIButton()
        titleBtn!.backgroundColor = .clear
        titleBtn!.setImage(UIImage.init(named: "address-selector-normal"), for: UIControlState())
        titleBtn!.setImage(UIImage.init(named: "address-selector-selected"), for: .selected)
        titleBtn!.addTarget(self, action: #selector(ForthwithVC.titleAction(_:)), for: .touchUpInside)
        titleView.addSubview(titleBtn!)
        titleBtn!.snp_makeConstraints { (make) in
            make.left.equalTo(titleLab!.snp_right)
            make.width.equalTo(20)
            make.centerY.equalTo(titleLab!.snp_centerY)
        }
        
//        let segmentBGV = UIImageView()
//        segmentBGV.image = UIImage.init(named: "head-bg")?.imageWithAlignmentRectInsets(UIEdgeInsetsMake(128, 0, 0, 0))
//        view.addSubview(segmentBGV)
//
//        let segmentItems = ["商务游", "高端游"]
//        segmentSC = UISegmentedControl(items: segmentItems)
//        segmentSC!.tag = 1001
//        segmentSC!.addTarget(self, action: #selector(ForthwithVC.segmentChange), forControlEvents: UIControlEvents.ValueChanged)
//        segmentSC!.selectedSegmentIndex = 0
//        segmentSC!.layer.masksToBounds = true
//        segmentSC?.layer.cornerRadius = 5
//        segmentSC?.backgroundColor = UIColor.clearColor()
//        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
//        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
//        segmentSC?.tintColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
//        view.addSubview(segmentSC!)
//        segmentSC!.snp_makeConstraints { (make) in
//            make.center.equalTo(segmentBGV)
//            make.height.equalTo(30)
//            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0)
//        }
        
        let bottomView = UIImageView()
        bottomView.isUserInteractionEnabled = true
        bottomView.image = UIImage.init(named: "bottom-selector-bg")
        view.addSubview(bottomView)
        bottomView.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.bottom.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(65)
        }
        
        bottomSelector.minimumValue = 0
        bottomSelector.maximumValue = 1
        bottomSelector.value = 0
        bottomSelector.isContinuous = false
        bottomSelector.addTarget(self, action: #selector(ForthwithVC.bottomSelectorAction(_:)), for: .valueChanged)
        bottomSelector.setThumbImage(UIImage.init(named: "bottom_selector_selected"), for: UIControlState())
        bottomSelector.tintColor = UIColor.white
        bottomSelector.minimumTrackTintColor = UIColor.white
        bottomSelector.maximumTrackTintColor = UIColor.white
        bottomView.addSubview(bottomSelector)
        bottomSelector.snp_makeConstraints { (make) in
            make.center.equalTo(bottomView)
            make.width.equalTo(ScreenWidth / 2.0)
            make.height.equalTo(65)
        }
        
        let leftTips = UILabel()
        leftTips.backgroundColor = UIColor.clear
        leftTips.textAlignment = NSTextAlignment.right
        leftTips.text = "现在"
        leftTips.isUserInteractionEnabled = true
        leftTips.font = UIFont.systemFont(ofSize: S13)
        leftTips.textColor = UIColor.white
        bottomView.addSubview(leftTips)
        leftTips.snp_makeConstraints { (make) in
            make.left.equalTo(bottomView)
            make.right.equalTo(bottomSelector.snp_left).offset(-10)
            make.top.equalTo(bottomView)
            make.bottom.equalTo(bottomView)
        }
        
        let rightTips = UILabel()
        rightTips.backgroundColor = UIColor.clear
        rightTips.textAlignment = NSTextAlignment.left
        rightTips.text = "预约"
        rightTips.isUserInteractionEnabled = true
        rightTips.font = UIFont.systemFont(ofSize: S13)
        rightTips.textColor = UIColor.white
        bottomView.addSubview(rightTips)
        rightTips.snp_makeConstraints { (make) in
            make.left.equalTo(bottomSelector.snp_right).offset(10)
            make.right.equalTo(bottomView)
            make.top.equalTo(bottomView)
            make.bottom.equalTo(bottomView)
        }
        
        mapView = MAMapView()
        mapView!.tag = 1002
        mapView!.delegate = self
        mapView!.userTrackingMode = .follow
        mapView!.setZoomLevel(11, animated: true)
        mapView!.isShowsUserLocation = true
        mapView!.showsCompass = true
        view.addSubview(mapView!)
        mapView!.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view).offset(0.5)
            make.width.equalTo(UIScreen.main.bounds.size.width - 1)
            make.bottom.equalTo(bottomView.snp_top)
        }
//        segmentBGV.snp_makeConstraints { (make) in
//            make.top.equalTo(view)
//            make.left.equalTo(view)
//            make.right.equalTo(mapView!).offset(0.5)
//            make.height.equalTo(60)
//        }
        
        let recommendBtn = UIButton()
        recommendBtn.tag = 2001
        recommendBtn.backgroundColor = .clear
        recommendBtn.setImage(UIImage.init(named: "tuijian"), for: UIControlState())
        recommendBtn.addTarget(self, action: #selector(ForthwithVC.recommendAction(_:)), for: .touchUpInside)
        mapView?.addSubview(recommendBtn)
        recommendBtn.snp_makeConstraints { (make) in
            make.left.equalTo(mapView!).offset(20)
            make.top.equalTo(mapView!).offset(20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        recommendBtn.isEnabled = false
        
        view.addSubview(appointmentView)
        appointmentView.snp_makeConstraints({ (make) in
            make.left.equalTo(mapView!.snp_right).offset(0.5)
            make.top.equalTo(view)
            make.width.equalTo(UIScreen.main.bounds.size.width - 1)
            make.bottom.equalTo(bottomView.snp_top)
        })
        
        let back2MyLocationBtn = UIButton()
        back2MyLocationBtn.backgroundColor = .clear
        back2MyLocationBtn.setImage(UIImage.init(named: "mine_location"), for: UIControlState())
        back2MyLocationBtn.addTarget(self, action: #selector(ForthwithVC.back2MyLocationAction(_:)), for: .touchUpInside)
        mapView?.addSubview(back2MyLocationBtn)
        back2MyLocationBtn.snp_makeConstraints { (make) in
            make.left.equalTo(mapView!).offset(20)
            make.bottom.equalTo(mapView!).offset(-20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        hideKeyboard()
    }
    
    func back2MyLocationAction(_ sender: UIButton) {
        checkLocationService()
        firstLanch = true
        if location != nil {
            mapView?.setCenter(location!.coordinate, animated: true)
        }
        
    }
    
    func recommendAction(_ sender: UIButton?) {
        let recommendVC = RecommendServantsVC()
        recommendVC.servantsInfo = recommendServants
        navigationController?.pushViewController(recommendVC, animated: true)
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginResult(_:)), name: NSNotification.Name(rawValue: NotifyDefine.LoginResult), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reflushServantInfo(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ServantInfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jumpToCenturionCardCenter), name: NSNotification.Name(rawValue: NotifyDefine.JumpToCenturionCardCenter), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jumpToWalletVC), name: NSNotification.Name(rawValue: NotifyDefine.JumpToWalletVC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ForthwithVC.jumpToCompeleteBaseInfoVC), name: NSNotification.Name(rawValue: NotifyDefine.JumpToCompeleteBaseInfoVC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serviceCitys(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ServiceCitys), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recommendServants(_:)), name: NSNotification.Name(rawValue: NotifyDefine.RecommendServants), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jumpToDistanceOfTravelVC), name: NSNotification.Name(rawValue: NotifyDefine.JumpToDistanceOfTravelVC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jumpToSettingsVC), name: NSNotification.Name(rawValue: NotifyDefine.JumpToSettingsVC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(chatMessage(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ChatMessgaeNotiy), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appointmentReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AppointmentReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jumpToFeedBackVC), name: NSNotification.Name(rawValue: NotifyDefine.FeedBackNoticeReply), object: nil)
    }
    
    func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(AppointmentVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        appointmentView.table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func appointmentReply(_ notification: Notification) {
        

        unowned let weakSelf = self
        SVProgressHUD.showSuccessMessage(SuccessMessage: "预约已成功，请保持开机！祝您生活愉快！谢谢！", ForDuration: 1.5) {
            let vc = DistanceOfTravelVC()
            vc.segmentIndex = 1
            weakSelf.navigationController?.pushViewController(vc, animated: true)

        }
        appointment_id_ = notification.userInfo!["appointment_id_"] as! Int
        perform(#selector(ForthwithVC.postNotifi), with: nil, afterDelay: 5)
//        postNotifi()
    }
    func postNotifi()  {
//        let appointment_id_ = notification.userInfo!["appointment_id_"] as! Int
        
        let dict = ["servantID":"1,2,3,4,5,6", "msg_time_" : Int(Int64(Date().timeIntervalSince1970)), "appointment_id_" : appointment_id_] as [String : Any]
        SocketManager.sendData(.testPushNotification, data: ["from_uid_" : -1,
                                                               "to_uid_" : DataManager.currentUser!.uid,
                                                             "msg_type_" : 2231,
                                                             "msg_body_" : dict,
                                                               "content_":"您好，为您刚才的预约推荐服务者"])

    }
    func keyboardWillShow(_ notification: Notification?) {
        let frame = (notification!.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let inset = UIEdgeInsetsMake(0, 0, (frame?.size.height)!, 0)
        appointmentView.table?.contentInset = inset
        appointmentView.table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        appointmentView.table?.contentInset = inset
        appointmentView.table?.scrollIndicatorInsets =  inset
    }
    
    func loginResult(_ notification: Notification?) {
        let data = notification?.userInfo!["data"]
        let err = (data! as AnyObject).allKeys!.contains(where: { (key) -> Bool in
            return key as! String == "error_" ? true : false
        })
        if !err {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.LoginSuccessed), object: nil, userInfo: ["data": data!])
        }
        
    }
    
    func chatMessage(_ notification: Notification?) {
        let msg = (notification?.userInfo!["data"])! as! PushMessage

        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.UpdateChatVC), object: nil, userInfo: ["data": msg])
        
        if DataManager.getUnreadMsgCnt(-1) > 0 {
            msgCountLab?.text = "\(DataManager.getUnreadMsgCnt(-1))"
            msgCountLab?.isHidden = false
        }

        if DataManager.getUserInfo(msg.from_uid_) == nil {
            //TUDO
            SocketManager.sendData(.getUserInfo, data: ["uid_str_": "\(msg.from_uid_)"])
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.PushMessageNotify), object: nil, userInfo: ["data": msg])
    }
    
    func recommendServants(_ notification: Notification?) {
        if let data = notification?.userInfo!["data"] as? Dictionary<String, AnyObject> {
            let servants = data["recommend_guide"] as? Array<Dictionary<String, AnyObject>>
            let type = data["recommend_type"] as! Int
            var uid_str = ""
            if type == 1 {
                for servant in servants! {
                    let servantInfo = UserInfo()
                    servantInfo.setInfo(.servant, info: servant)
                    recommendServants.append(servantInfo)
                    DataManager.updateUserInfo(servantInfo)
                    uid_str += "\(servantInfo.uid),"
                }
                if let recommendBtn = mapView!.viewWithTag(2001) as? UIButton {
                    recommendBtn.isEnabled = true
                }
            } else if type == 2 {
                for servant in servants! {
                    let servantInfo = UserInfo()
                    servantInfo.setInfo(.servant, info: servant)
                    subscribeServants.append(servantInfo)
                    DataManager.updateUserInfo(servantInfo)
                    uid_str += "\(servantInfo.uid),"
                }
                if header.state == .refreshing {
                    header.endRefreshing()
                }
                
            }
            uid_str.remove(at: uid_str.characters.index(before: uid_str.endIndex))
            let dict:Dictionary<String, AnyObject> = ["uid_str_": uid_str as AnyObject]
            SocketManager.sendData(.getUserInfo, data: dict as AnyObject?)
        }
        
    }
    
    func serviceCitys(_ notification: Notification?) {
        
        if let data = notification?.userInfo!["data"] as? [String: AnyObject] {
            if let citys = data["service_city_"] as? Array<Dictionary<String, AnyObject>> {
                for city in citys {
                    let cityInfo = CityInfo()
                    cityInfo.setInfo(city)
                    serviceCitys[cityInfo.cityCode] = cityInfo
                    DataManager.insertData(CityInfo.self, data: cityInfo)
                }
            }
            
        }
        appointmentView.serviceCitys = serviceCitys
        
        regOrLoginSelVC!.dismiss(animated: false) {
            self.regOrLoginSelVC?.dismiss(animated: false) {
                if DataManager.currentUser!.registerSstatus == 0 {
                    let completeBaseInfoVC = CompleteBaseInfoVC()
                    self.navigationController?.pushViewController(completeBaseInfoVC, animated: true)
                }
                
            }
        }
        
    }
    
    func jumpToCenturionCardCenter() {
        let centurionCardCenter = CenturionCardVC()
        navigationController?.pushViewController(centurionCardCenter, animated: true)
    }
    
    func jumpToWalletVC() {
        let walletVC = WalletVC()
        navigationController?.pushViewController(walletVC, animated: true)
    }
    func jumpToCompeleteBaseInfoVC() {
        let completeBaseInfoVC = CompleteBaseInfoVC()
        navigationController?.pushViewController(completeBaseInfoVC, animated: true)

    }
    
    func jumpToDistanceOfTravelVC() {
        let distanceOfTravelVC = DistanceOfTravelVC()
        navigationController?.pushViewController(distanceOfTravelVC, animated: true)
    }
    
    func jumpToSettingsVC() {
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func reflushServantInfo(_ notification: Notification?) {
        let data = notification?.userInfo!["data"]
        let err = (data! as AnyObject).allKeys!.contains(where: { (key) -> Bool in
            return key as! String == "error_" ? true : false
        })
        if err {
            XCGLogger.error("err:\(data!["error_"] as! Int)")
            return
        }
        let servants = data!["result"] as! Array<Dictionary<String, AnyObject>>
        for servant in servants {
            let servantInfo = UserInfo()
            servantInfo.setInfo(.servant, info: servant)
            servantsInfo[servantInfo.uid] = servantInfo
            DataManager.updateUserInfo(servantInfo)
            let latitude = servantInfo.gpsLocationLat
            let longitude = servantInfo.gpsLocationLon
            let point = MAPointAnnotation.init()
            point.coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            point.title = "\(servantInfo.uid)"
            annotations.append(point)
        }
        if mapView!.annotations.count > 0{
            mapView?.removeAnnotations(mapView!.annotations)
        }
        mapView!.addAnnotations(annotations)
        mapView!.showAnnotations(annotations, animated: true)
        
        
    }
    
    func servantDetailInfo(_ notification: Notification?) {
        let data = notification?.userInfo!["data"]
        if data!["error_"]! != nil {
            XCGLogger.error("Get UserInfo Error:\(data!["error_"])")
            return
        }
        servantsInfo[data!["uid_"] as! Int]?.setInfo(.servant, info: data as? Dictionary<String, AnyObject>)
        let user = servantsInfo[data!["uid_"] as! Int]
        DataManager.updateUserInfo(user!)
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data!["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
        
    }
    
    func titleAction(_ sender: UIButton?) {
        XCGLogger.debug(sender?.currentTitle)
        
        if citysAlertController == nil {
            citysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
            let sheet = CitysSelectorSheet()
            let citys = NSDictionary.init(dictionary: serviceCitys)
            sheet.citysList = citys.allValues as? Array<CityInfo>
            sheet.delegate = self
            citysAlertController!.view.addSubview(sheet)
            sheet.snp_makeConstraints { (make) in
                make.left.equalTo(citysAlertController!.view).offset(-10)
                make.right.equalTo(citysAlertController!.view).offset(10)
                make.bottom.equalTo(citysAlertController!.view).offset(10)
                make.top.equalTo(citysAlertController!.view).offset(-10)
            }
        }
        
        present(citysAlertController!, animated: true, completion: nil)
    }
    
    func msgAction(_ sender: AnyObject?) {
        let msgVC = PushMessageVC()

        if sender?.isKind(of: UIButton) == false {
            navigationController?.pushViewController(msgVC, animated: false)
            if let userInfo = sender as? [AnyHashable: Any] {
                let type = userInfo["type"] as? Int
                if type == PushMessage.MessageType.chat.rawValue {
                    perform(#selector(ForthwithVC.postPushMessageNotify(_:)), with: userInfo["data"], afterDelay: 0.5)
                }
            }
            
        } else {
            navigationController?.pushViewController(msgVC, animated: true)
        }
        
    }
    
    func postPushMessageNotify(_ data: AnyObject?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.PushMessageNotify), object: nil, userInfo: ["data": data!])
    }
    
    func bottomSelectorAction(_ sender: AnyObject?) {
        let bottomSelector = sender as! UISlider
        if bottomSelector.value > 0.5 {
            bottomSelector.setValue(1, animated: true)
            mapView!.snp_updateConstraints { (make) in
                make.width.equalTo(0)
            }

        } else {
            bottomSelector.setValue(0, animated: false)
            mapView!.snp_updateConstraints { (make) in
                make.width.equalTo(UIScreen.main.bounds.size.width - 1)
            }
        }
        XCGLogger.defaultInstance().debug("\(bottomSelector.value)")
    }
    
    func segmentChange(_ sender: AnyObject?) {
        if sender?.selectedSegmentIndex == 0 {
            
        } else if sender?.selectedSegmentIndex == 1 {
            
        }
        
    }
    
    // MARK MAP
    open func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        var latDiffValue = Double(0)
        var lonDiffvalue = Double(0)
        if location == nil {
            location = userLocation.location
            latDiffValue = 720.0
        } else {
            latDiffValue = location!.coordinate.latitude - userLocation.coordinate.latitude
            lonDiffvalue = location!.coordinate.longitude - userLocation.coordinate.longitude
        }
        
        
        if  latDiffValue == 720.0 || latDiffValue >= 0.01 || latDiffValue <= -0.01 || lonDiffvalue >= 0.01 || lonDiffvalue <= -0.01 {
            
            let geoCoder = CLGeocoder()
            if userLocation.location != nil {
                geoCoder.reverseGeocodeLocation(userLocation.location) { (placeMarks: [CLPlacemark]?, err: NSError?) in
                    if placeMarks?.count == 1 {
                        self.locality = (placeMarks?[0])!.locality
                        self.titleLab?.text = self.locality
                        XCGLogger.debug("Update locality: \(self.locality!)")
                        DataManager.currentUser!.gpsLocationLat = userLocation.coordinate.latitude
                        DataManager.currentUser!.gpsLocationLon = userLocation.coordinate.longitude
                        self.perform(#selector(ForthwithVC.sendLocality), with: nil, afterDelay: 1)

                        if DataManager.currentUser!.login {
                            let dict:Dictionary<String, AnyObject> = ["latitude_": DataManager.currentUser!.gpsLocationLat,
                                                                      "longitude_": DataManager.currentUser!.gpsLocationLon,
                                                                      "distance_": 20.1]
                            SocketManager.sendData(.getServantInfo, data: dict)
                        }
                    }
                } as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler
            }
            
        }
        
    }
    
    func sendLocality() {
        mapView!.setZoomLevel(11, animated: true)
        if serviceCitys.count > 0 {
            for (cityCode, cityInfo) in serviceCitys {
                if (locality! as NSString).range(of: cityInfo.cityName!).length > 0 {
                    var dict = ["city_code_": cityCode, "recommend_type_": 1]
                    SocketManager.sendData(.getRecommendServants, data: dict as AnyObject?)
                    dict["recommend_type_"] = 2
                    SocketManager.sendData(.getRecommendServants, data: dict as AnyObject?)
                    return
                }
            }
            
            if firstLanch {
                UserDefaults.standard.setValue(locality == nil ? "" : locality, forKey: UserDefaultKeys.homeLocation)
                mapView!.centerCoordinate = location!.coordinate
                firstLanch = false
            }
        } else {
            perform(#selector(ForthwithVC.sendLocality), with: nil, afterDelay: 1)
        }
        
        
    }
    
    open func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        var id = ""
        let lat = annotation.coordinate.latitude
        let lng = annotation.coordinate.longitude
        for (_, servantInfo) in servantsInfo {
            if servantInfo.gpsLocationLat == lat && servantInfo.gpsLocationLon == lng {
                if servantInfo.userType == UserInfo.UserType.servant.rawValue {
                    id = "Guide"
                    var annotationView:GuideTagCell? = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? GuideTagCell
                    if annotationView == nil{
                        annotationView = GuideTagCell.init(annotation: annotation, reuseIdentifier: id) as GuideTagCell
                    }
                    annotationView!.setInfo(servantInfo)
                    return annotationView
                } else if servantInfo.userType == UserInfo.UserType.meetLocation.rawValue {
                    id = "Meet"
                    var annotationView:MeetTagCell? = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MeetTagCell
                    if annotationView == nil{
                        annotationView = MeetTagCell.init(annotation: annotation, reuseIdentifier: id) as MeetTagCell
                    }
                    annotationView!.setInfo(servantInfo)
                    return annotationView
                }
         
            }
        }
        
        return nil
    }
    
    open func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [AnyObject]!) {

    }
    
    open func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        if view.isKind(of: GuideTagCell.self) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            // 认证状态限制查看个人信息
            let auth = (DataManager.currentUser?.authentication)!
            if auth != 1 {
                let msgs = [-1: "尊敬的游客，您尚未申请认证，请立即前往认证，成为V领队的正式游客",
                            0: "尊敬的游客，您的认证尚未通过审核，在审核成功后将为您开通查看服务者信息的权限",
                            2: "尊敬的游客，您的认证未通过审核，请立即前往认证，成为V领队的正式游客"]
                let alert = UIAlertController.init(title: "查看服务者信息失败", message: msgs[auth], preferredStyle: .alert)
                let ok = UIAlertAction.init(title: "立即申请", style: .default, handler: { (action) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 0.3)) / Double(NSEC_PER_SEC), execute: { () in
                        let controller = UploadUserPictureVC()
                        self.navigationController!.pushViewController(controller, animated: true)
                        DataManager.currentUser?.authentication = 1   // 测试
                    })
                })
                alert.view.tintColor = UIColor.gray
                let cancel = UIAlertAction.init(title: auth != 0 ? "算了吧" : "好的", style: .default, handler: { (action) in
                    if auth == 0 {
                        DataManager.currentUser?.authentication = 1 // 测试
                    }
                })
                if auth != 0{
                    alert.addAction(ok)
                }
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
                
                return
            }
            // 余额限制查看个人信息
//            DataManager.currentUser?.has_recharged_ = 1 // MARK:测试后去掉
            if DataManager.currentUser?.has_recharged_ == 0 {
                let alert = UIAlertController.init(title: "余额不足", message: "服务者的最低价格为1000元，还需充值200元", preferredStyle: .alert)
                
                let ok = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
                    XCGLogger.debug("去充值")
                    
                    let rechargeVC = RechargeVC()
                    self.navigationController?.pushViewController(rechargeVC, animated: true)
                    DataManager.currentUser?.cash = 10
                    
                })
                
                let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction) in
                    
                })
                
                alert.addAction(ok)
                alert.addAction(cancel)
                
                present(alert, animated: true, completion: {
                    
                })
                
                return
            }

            let dict:Dictionary<String, AnyObject> = ["uid_": (view as! GuideTagCell).userInfo!.uid as AnyObject]
            SocketManager.sendData(.getServantDetailInfo, data: dict as AnyObject?)
            
        }
                
    }
   
    open func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: NSError!) {
        
        switch error.code {
        case 1:
            checkLocationService()
//            SVProgressHUD.showWainningMessage(WainningMessage: "请在设置中设置允许V领队定位，我们才能为您推荐服务者", ForDuration: 1.5, completion: nil)
            firstLanch = true
            break
        case 4:
            SVProgressHUD.showWainningMessage(WainningMessage: "网络连接超时", ForDuration: 1.5, completion: nil)

            break
        default:
            break
        }
        
        
    }
    // MARK: - ServiceSheetDelegate
    func cancelAction(_ sender: UIButton?) {
        citysAlertController?.dismiss(animated: true, completion: nil)
    }
    
    func sureAction(_ sender: UIButton?, targetCity: CityInfo?) {
        guard targetCity != nil else { return }
        recommendServants.removeAll()
        citysAlertController?.dismiss(animated: true, completion: nil)
        let dict:Dictionary<String, AnyObject> = ["city_code_": (targetCity?.cityCode)! as AnyObject, "recommend_type_": 1 as AnyObject]
        SocketManager.sendData(.getRecommendServants, data: dict as AnyObject?)
    }
    
    func headerRefresh() {
        let dict = ["city_code_": cityCode, "recommend_type_": 2]
        SocketManager.sendData(.getRecommendServants, data: dict as AnyObject?)
    }
    
    //MARK: - ServantIntroCellDeleagte
    func chatAction(_ servantInfo: UserInfo?) {
        let dict:Dictionary<String, AnyObject> = ["uid_": servantInfo!.uid as AnyObject]
        SocketManager.sendData(.getServantDetailInfo, data: dict as AnyObject?)

    }
    
    deinit {        
        NotificationCenter.default.removeObserver(self)
    }
    
}


