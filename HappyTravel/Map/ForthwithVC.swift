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


public class ForthwithVC: UIViewController, MAMapViewDelegate, CitysSelectorSheetDelegate, RefreshChatSessionListDelegate {
    
    var titleLab:UILabel?
    var titleBtn:UIButton?
    var msgCountLab:UILabel?
    var segmentSC:UISegmentedControl?
    var mapView:MAMapView?
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    var servantsInfo:Dictionary<Int, UserInfoModel> = [:]
    var annotations:Array<MAPointAnnotation> = []
    var login = false
    
    var serviceCitysModel:CityNameInfoModel?
    
    var citysAlertController:UIAlertController?

    var subscribeServants:Array<UserInfoModel> = []
    var locality:String?
    var location:CLLocation?
    var regOrLoginSelVC:RegOrLoginSelVC? = RegOrLoginSelVC()
    var cityCode = 0
    var firstLanch = true
    let bottomSelector = UISlider()
    let appointmentView = AppointmentView()
    var lastMapCenter: CLLocationCoordinate2D?
    var feedBack: YWFeedbackKit = YWFeedbackKit.init(appKey: "23519848")
    //延时测试用
    var appointment_id_ = 0
    var isShowBaseInfo = false
    var isShowLocationInfo = false
    //服务者类型 0商务，1休闲, 999所有服务者，默认为所有服务者（服务端发送的serviceType_ 0商务，1休闲, 2既是商务又是休闲）
    var serviceType:Int = 999
    //筛选弹框
    var alertCtrl:UIAlertController?
    weak var rightLabel:UILabel?
    
    var forcedUpdate = true
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        initView()
        YD_ContactManager.checkIfUploadContact()
        
        registerNotify()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotifyDefine.LoginFailed, object: nil)
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginFailed(_:)), name: NotifyDefine.LoginFailed, object: nil)

        if navigationItem.rightBarButtonItem == nil {
            let msgBtn = UIButton.init(frame: CGRectMake(0, 0, 30, 30))
            msgBtn.setImage(UIImage.init(named: "nav-msg"), forState: .Normal)
            msgBtn.backgroundColor = UIColor.clearColor()
            msgBtn.addTarget(self, action: #selector(msgAction(_:)), forControlEvents: .TouchUpInside)
            
            let msgItem = UIBarButtonItem.init(customView: msgBtn)
            navigationItem.rightBarButtonItem = msgItem

            msgCountLab = UILabel()
            msgCountLab!.backgroundColor = UIColor.redColor()
            msgCountLab!.text = ""
            msgCountLab!.textColor = UIColor.whiteColor()
            msgCountLab!.textAlignment = .Center
            msgCountLab!.font = UIFont.systemFontOfSize(S10)
            msgCountLab!.layer.cornerRadius = 18 / 2.0
            msgCountLab!.layer.masksToBounds = true
            msgCountLab!.hidden = true
            msgBtn.addSubview(msgCountLab!)
            msgCountLab!.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(msgBtn).offset(5)
                make.top.equalTo(msgBtn).offset(-2)
                make.width.equalTo(18)
                make.height.equalTo(18)
            })
            
        }
        
        if DataManager.getUnreadMsgCnt(-1) > 0 {
            msgCountLab?.text = "\(DataManager.getUnreadMsgCnt(-1))"
            msgCountLab?.hidden = false
        } else {
            msgCountLab?.hidden = true
        }
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = DataManager.getUnreadMsgCnt(-1)
        if CurrentUser.login_ == false {
            if APIHelper.userAPI().autoLogin() {
                banGesture(true)
            } else {
                self.presentViewController(self.regOrLoginSelVC!, animated: false, completion: nil)
            }

        }

        appointmentView.commitBtn?.enabled = true
        
        if forcedUpdate {
            APIHelper.commonAPI().checkVersion(CheckVersionRequestModel(), complete: { [weak self](response) in
                if let verInfo = response as? [String: AnyObject] {
                    self?.forcedUpdate = verInfo["mustUpdate"] as! Bool
                    UpdateManager.checking4Update(verInfo["newVersion"] as! String, buildVer: verInfo["buildVersion"] as! String, forced: verInfo["mustUpdate"] as! Bool, result: { (gotoUpdate) in
                        if gotoUpdate {
                            UIApplication.sharedApplication().openURL(NSURL.init(string: verInfo["DetailedInfo"] as! String)!)
                        }
                    })
                }
                }, error: { (error) in
                    
            })
        }
        
    }
    
    func banGesture(ban: Bool) {
        view.userInteractionEnabled = !ban
        navigationController?.navigationBar.userInteractionEnabled = !ban
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        appointmentView.nav = navigationController
        checkLocationService()
    }
    
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            
            guard !isShowLocationInfo else {return}
            let alert = UIAlertController.init(title: "提示", message: "定位服务异常：请确定定位服务已开启，并允许优悦出行使用定位服务", preferredStyle: .Alert)
            let goto = UIAlertAction.init(title: "前往设置", style: .Default, handler: { (action) in
                if #available(iOS 10, *) {
                    UIApplication.sharedApplication().openURL(NSURL.init(string: UIApplicationOpenSettingsURLString)!)
                } else {
                    UIApplication.sharedApplication().openURL(NSURL.init(string: "prefs:root=LOCATION_SERVICES")!)
                }
                
            })
            let cancel = UIAlertAction.init(title: "取消", style: .Default, handler: { (action) in
            })
            alert.addAction(goto)
            alert.addAction(cancel)
            presentViewController(alert, animated: true, completion: { 
                self.isShowLocationInfo = true

            })
            
        }
    }
    
    func initView() {
        let width = UIScreen.mainScreen().bounds.width
        let titleView = UIView.init(frame: CGRectMake(0,0,width,40))
        titleView.backgroundColor = .clearColor()
        titleView.userInteractionEnabled = true
        navigationItem.titleView = titleView
      
        titleBtn = UIButton()
        titleBtn!.backgroundColor = .clearColor()
        titleBtn?.setTitle("所有服务者", forState: .Normal)
        titleBtn?.titleLabel?.font = UIFont.systemFontOfSize(16)
        titleBtn?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 115, bottom: 0, right: 0)
        titleBtn!.setImage(UIImage.init(named: "address-selector-normal"), forState: .Normal)
        titleBtn!.setImage(UIImage.init(named: "address-selector-selected"), forState: .Selected)
        titleBtn!.addTarget(self, action: #selector(screenServices(_:)), forControlEvents: .TouchUpInside)
        titleView.addSubview(titleBtn!)
        titleBtn!.snp_makeConstraints { (make) in
            make.width.equalTo(130)
            make.centerX.equalTo(titleView)
            make.centerY.equalTo(titleView)
        }
        
        let bottomView = UIImageView()
        bottomView.userInteractionEnabled = true
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
        bottomSelector.continuous = false
        bottomSelector.addTarget(self, action: #selector(bottomSelectorAction(_:)), forControlEvents: .ValueChanged)
        bottomSelector.setThumbImage(UIImage.init(named: "bottom_selector_selected"), forState: .Normal)
        bottomSelector.tintColor = UIColor.whiteColor()
        bottomSelector.minimumTrackTintColor = UIColor.whiteColor()
        bottomSelector.maximumTrackTintColor = UIColor.whiteColor()
        bottomView.addSubview(bottomSelector)
        bottomSelector.snp_makeConstraints { (make) in
            make.center.equalTo(bottomView)
            make.width.equalTo(ScreenWidth / 2.0)
            make.height.equalTo(65)
        }
        
        let leftTips = UILabel()
        leftTips.backgroundColor = UIColor.clearColor()
        leftTips.textAlignment = NSTextAlignment.Right
        leftTips.text = "现在"
        leftTips.userInteractionEnabled = true
        leftTips.font = UIFont.systemFontOfSize(S13)
        leftTips.textColor = UIColor.whiteColor()
        bottomView.addSubview(leftTips)
        leftTips.snp_makeConstraints { (make) in
            make.left.equalTo(bottomView)
            make.right.equalTo(bottomSelector.snp_left).offset(-10)
            make.top.equalTo(bottomView)
            make.bottom.equalTo(bottomView)
        }
        
        let rightTips = UILabel()
        rightTips.backgroundColor = UIColor.clearColor()
        rightTips.textAlignment = NSTextAlignment.Left
        rightTips.text = "预约"
        rightTips.userInteractionEnabled = true
        rightTips.font = UIFont.systemFontOfSize(S13)
        rightTips.textColor = UIColor.whiteColor()
        bottomView.addSubview(rightTips)
        rightTips.snp_makeConstraints { (make) in
            make.left.equalTo(bottomSelector.snp_right).offset(10)
            make.right.equalTo(bottomView)
            make.top.equalTo(bottomView)
            make.bottom.equalTo(bottomView)
        }
        rightLabel = rightTips
        mapView = MAMapView()
        mapView!.tag = 1002
        mapView!.delegate = self
        mapView!.userTrackingMode = .Follow
        mapView!.setZoomLevel(11, animated: true)
        mapView!.showsUserLocation = true
        mapView!.showsCompass = true
        view.addSubview(mapView!)
        mapView!.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view).offset(0.5)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width - 1)
            make.bottom.equalTo(bottomView.snp_top)
        }

        view.addSubview(appointmentView)
        appointmentView.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(mapView!.snp_right).offset(0.5)
            make.top.equalTo(view)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width - 1)
            make.bottom.equalTo(bottomView.snp_top)
        })
        
        let back2MyLocationBtn = UIButton()
        back2MyLocationBtn.backgroundColor = .clearColor()
        back2MyLocationBtn.setImage(UIImage.init(named: "mine_location"), forState: .Normal)
        back2MyLocationBtn.addTarget(self, action: #selector(ForthwithVC.back2MyLocationAction(_:)), forControlEvents: .TouchUpInside)
        mapView?.addSubview(back2MyLocationBtn)
        back2MyLocationBtn.snp_makeConstraints { (make) in
            make.left.equalTo(mapView!).offset(20)
            make.bottom.equalTo(mapView!).offset(-20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
//        let centurionCardBtn = UIButton()
//        centurionCardBtn.backgroundColor = UIColor.clearColor()
//        centurionCardBtn.setBackgroundImage(UIImage.init(named: "centurion_card_recommon"), forState: .Normal)
//        centurionCardBtn.addTarget(self, action: #selector(jumpToCenturionCardVC(_:)), forControlEvents: .TouchUpInside)
//        mapView?.addSubview(centurionCardBtn)
//        centurionCardBtn.snp_makeConstraints(closure: { (make) in
//            make.right.equalTo(mapView!).offset(-20)
//            make.bottom.equalTo(mapView!).offset(-20)
//            make.width.equalTo(40)
//            make.height.equalTo(40)
//        })
        
        hideKeyboard()
    }
    
    func screenServices(sender:UIButton) {
        sender.selected = true
        alertCtrl = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let nameArray = ["所有服务者", "商务服务者", "休闲服务者", "取消"]
        let typeArray = [999, 0, 1]
        for i in 0..<4 {
            let services = UIAlertAction.init(title: nameArray[i], style: .Default, handler: { (sender: UIAlertAction) in
                if i == 3{
                    self.titleBtn?.selected = false
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
                    self.serviceType = typeArray[i]
                    self.screenAction(nameArray[i])
                }
                
                
            })
            alertCtrl!.addAction(services)
        }
        
        presentViewController(alertCtrl!, animated: true, completion: nil)
    }
    
    func screenAction(title:String) {
        self.titleBtn?.setTitle(title, forState: .Normal)
        self.titleBtn?.selected = false
        let lat = mapView!.centerCoordinate.latitude
        let lon = mapView!.centerCoordinate.longitude
        getServantNearby(lat, lon: lon)

    }
    
    func jumpToCenturionCardVC(sender: UIButton) {
        jumpToCenturionCardCenter()
    }
    
    func back2MyLocationAction(sender: UIButton) {
        checkLocationService()
        if location != nil {
            mapView?.setZoomLevel(11.0, animated: false)
            mapView?.setCenterCoordinate(location!.coordinate, animated: true)
        }
        
    }

    func registerNotify() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(loginSuccessed(_:)), name: NotifyDefine.LoginSuccessed, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToCenturionCardCenter), name: NotifyDefine.JumpToCenturionCardCenter, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToWalletVC), name: NotifyDefine.JumpToWalletVC, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToCompeleteBaseInfoVC), name: NotifyDefine.JumpToCompeleteBaseInfoVC, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToDistanceOfTravelVC), name: NotifyDefine.JumpToDistanceOfTravelVC, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToSettingsVC), name: NotifyDefine.JumpToSettingsVC, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToFeedBackVC), name: NotifyDefine.FeedBackNoticeReply, object: nil)
    }
    
    func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        appointmentView.table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }

    func postNotifi()  {
        
////        let dict = ["servantID":"1,2,3,4,5,6", "msg_time_" : Int(Int64(NSDate().timeIntervalSince1970)), "appointment_id_" : appointment_id_]
//        SocketManager.sendData(.TestPushNotification, data: ["from_uid_" : -1,
//                                                               "to_uid_" : CurrentUser.uid_,
//                                                             "msg_type_" : 2231,
//                                                             "msg_time_" : Int(Int64(NSDate().timeIntervalSince1970)),
//                                                           "servant_id_" : "1,2,3,4,5,6",
//                                                       "appointment_id_" : appointment_id_,
//                                                              "content_" : "您好，为您刚才的预约推荐服务者"])

    }
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        appointmentView.table?.contentInset = inset
        appointmentView.table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        appointmentView.table?.contentInset = inset
        appointmentView.table?.scrollIndicatorInsets =  inset
    }
    
    func loginFailed(notification: NSNotification) {
        presentViewController(regOrLoginSelVC!, animated: false, completion: nil)

    }
    
    func loginSuccessed(notification: NSNotification) {
        banGesture(false)
        YD_NewPersonGuideManager.startGuide()

        if CurrentUser.register_status_ == 0 {
            if !isShowBaseInfo {
                isShowBaseInfo = true
                let completeBaseInfoVC = CompleteBaseInfoVC()
                self.navigationController?.pushViewController(completeBaseInfoVC, animated: true)
            }
        }
        
        YD_NewPersonGuideManager.startGuide()

        APIHelper.commonAPI().cityNameInfo({ (response) in
            if let model = response as? CityNameInfoModel {
                DataManager.insertData(model)
                self.serviceCitysModel = model
                self.appointmentView.serviceCitysModel = self.serviceCitysModel
            }
            }, error: { (err) in
                
        })
        
        if let dt = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.DeviceToken) as? String {
            let req = RegDeviceRequestModel()
            req.device_token_ = dt
            req.uid_ = CurrentUser.uid_
            APIHelper.commonAPI().regDevice(req, complete: nil, error: nil)
        }
        
        let lat = DataManager.curLocation?.coordinate.latitude ?? CurrentUser.latitude_
        let lon = DataManager.curLocation?.coordinate.longitude ?? CurrentUser.longitude_
        getServantNearby(lat, lon: lon)
        
        APIHelper.commonAPI().skills( { (response) in
            if let model = response as? SkillsModel {
                DataManager.insertData(model)
            }
        }, error: nil)
        //初始化 receiveMessageBlock
        ChatMessageHelper.shared.refreshMsgCountDelegate = self
        getUnReadMessage()
    }

    func getUnReadMessage() {
        
        APIHelper.chatAPI().requestUnReadMessage(UnReadMessageRequestModel(), complete: { (response) in
            let messsages = response as? [MessageModel]
            guard messsages?.count > 0 else {return}
            for message in messsages! {
//                DataManager.insertData(message)
                ChatMessageHelper.shared.reveicedMessage(message)
            }
            self.setUnReadCount()
            }) { (error) in
                
        }
    }
    
    func setUnReadCount() {
        
        if DataManager.getUnreadMsgCnt(-1) > 0 {
            msgCountLab?.text = "\(DataManager.getUnreadMsgCnt(-1))"
            msgCountLab?.hidden = false
        }
    }
    
    func refreshChatSeesionList() {
        setUnReadCount()
    }
    
    func getServantNearby(lat: Double, lon:Double) {
        let servantNearbyModel = ServantNearbyModel()
        servantNearbyModel.latitude_ = lat
        servantNearbyModel.longitude_ = lon
        APIHelper.servantAPI().servantNearby(servantNearbyModel, complete: { [weak self](response) in
            if let models = response as? [UserInfoModel] {
                self!.annotations.removeAll()
                for servant in models {
                    self!.servantsInfo[servant.uid_] = servant
                    DataManager.insertData(servant)
                    let latitude = servant.latitude_
                    let longitude = servant.longitude_
                    let point = MAPointAnnotation.init()
                    point.coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    point.title = "\(servant.uid_)"
                    //根据serviceType筛选
                    if self!.serviceType != 999 {
                        //不是默认的所有服务者，进行筛选
                        let type = servant.servicetype_
                        //不是类型2和要筛选的服务者，忽略
                        if  type != self!.serviceType && type != 2 {
                            continue
                        }
                    }
                    self!.annotations.append(point)
                }
                if self!.mapView!.annotations.count > 0{
                    self!.mapView?.removeAnnotations(self!.mapView!.annotations)
                }
                self!.mapView!.addAnnotations(self!.annotations)
            }
            }, error: { (err) in
                print(err)
        })
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
    
    func titleAction(sender: UIButton?) {
        if citysAlertController == nil {
            citysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
            let sheet = CitysSelectorSheet()
            sheet.citysList = self.serviceCitysModel
            sheet.targetCity = self.serviceCitysModel?.service_city_.first
            sheet.delegate = self
            citysAlertController!.view.addSubview(sheet)
            sheet.snp_makeConstraints { (make) in
                make.left.equalTo(citysAlertController!.view).offset(-10)
                make.right.equalTo(citysAlertController!.view).offset(10)
                make.bottom.equalTo(citysAlertController!.view).offset(10)
                make.top.equalTo(citysAlertController!.view).offset(-10)
            }
        }
        
        presentViewController(citysAlertController!, animated: true, completion: nil)
    }
    
    func msgAction(sender: AnyObject?) {
        let msgVC = PushMessageVC()

        if sender?.isKindOfClass(UIButton) == false {
            navigationController?.pushViewController(msgVC, animated: false)
            if let userInfo = sender as? [NSObject: AnyObject] {
                let type = userInfo["type"] as? Int
                if type == PushMessage.MessageType.Chat.rawValue {
                    performSelector(#selector(ForthwithVC.postPushMessageNotify(_:)), withObject: userInfo["data"], afterDelay: 0.5)
                }
            }
            
        } else {
            navigationController?.pushViewController(msgVC, animated: true)
        }
        
    }
    
    func postPushMessageNotify(data: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.PushMessageNotify, object: nil, userInfo: ["data": data!])
    }
    
    func bottomSelectorAction(sender: AnyObject?) {
        let bottomSelector = sender as! UISlider
        if bottomSelector.value > 0.5 {
            bottomSelector.setValue(1, animated: true)
            mapView!.snp_updateConstraints { (make) in
                make.width.equalTo(0)
            }

        } else {
            bottomSelector.setValue(0, animated: false)
            mapView!.snp_updateConstraints { (make) in
                make.width.equalTo(UIScreen.mainScreen().bounds.size.width - 1)
            }
        }
        XCGLogger.defaultInstance().debug("\(bottomSelector.value)")
    }
    
    func segmentChange(sender: AnyObject?) {
        if sender?.selectedSegmentIndex == 0 {
            
        } else if sender?.selectedSegmentIndex == 1 {
            
        }
        
    }
    
    // MARK MAP
    public func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        DataManager.curLocation = userLocation.location
        var latDiffValue = Double(0)
        var lonDiffvalue = Double(0)
        if location == nil {
            location = userLocation.location
            latDiffValue = 720.0
            mapView.setZoomLevel(11, animated: false)
            if location != nil {
                mapView.centerCoordinate = location!.coordinate
            }
        } else {
            latDiffValue = location!.coordinate.latitude - userLocation.coordinate.latitude
            lonDiffvalue = location!.coordinate.longitude - userLocation.coordinate.longitude
        }
        
        if  latDiffValue == 720.0 || latDiffValue >= 0.01 || latDiffValue <= -0.01 || lonDiffvalue >= 0.01 || lonDiffvalue <= -0.01 {
            location = userLocation.location
            let geoCoder = CLGeocoder()
            if userLocation.location != nil {
                geoCoder.reverseGeocodeLocation(userLocation.location) { (placeMarks: [CLPlacemark]?, err: NSError?) in
                    if placeMarks?.count == 1 {
                        self.locality = (placeMarks?[0])!.locality
                        NSUserDefaults.standardUserDefaults().setValue(self.locality ?? "", forKey: UserDefaultKeys.homeLocation)
                        if CurrentUser.login_ {
                            self.getServantNearby(DataManager.curLocation!.coordinate.latitude, lon: DataManager.curLocation!.coordinate.longitude)
                        }
                    }
                }
            }
            
        }
        
    }
    
    public func mapView(mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction == false {
            return
        }
        
        if lastMapCenter != nil {
            if double2((lastMapCenter?.latitude)!) == double2(mapView.centerCoordinate.latitude) &&
                double2((lastMapCenter?.longitude)!) == double2(mapView.centerCoordinate.longitude) &&
                firstLanch == false {
                return
            }
        }
        firstLanch = false
        
        getServantNearby(mapView.centerCoordinate.latitude, lon: mapView.centerCoordinate.longitude)

        lastMapCenter = mapView.centerCoordinate
    }
    
    func double2(let value:Double) -> Double {
        let valueStr = String(format: "%.2f",value)
        return Double(valueStr)!
    }

    

    public func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        var id = ""
        let lat = annotation.coordinate.latitude
        let lng = annotation.coordinate.longitude
        for (_, servantInfo) in servantsInfo {
            if servantInfo.latitude_ == lat && servantInfo.longitude_ == lng {
                if servantInfo.uid_ != CurrentUser.uid_ {
                    id = "Guide"
                    var annotationView:GuideTagCell? = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? GuideTagCell
                    if annotationView == nil{
                        annotationView = GuideTagCell.init(annotation: annotation, reuseIdentifier: id) as GuideTagCell
                    }
                    annotationView!.setInfo(servantInfo)
                    return annotationView
                } /*else if servantInfo.userType == UserInfo.UserType.MeetLocation.rawValue {
                    id = "Meet"
                    var annotationView:MeetTagCell? = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? MeetTagCell
                    if annotationView == nil{
                        annotationView = MeetTagCell.init(annotation: annotation, reuseIdentifier: id) as MeetTagCell
                    }
                    annotationView!.setInfo(servantInfo)
                    return annotationView
                }*/
         
            }
        }
        
        return nil
    }
    
    public func mapView(mapView: MAMapView!, didAddAnnotationViews views: [AnyObject]!) {

    }
    
    public func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        if view.isKindOfClass(GuideTagCell) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            guard checkAuthStaus() else { return }
            guard cashCheck() else { return }

            let servant = UserBaseModel()
            servant.uid_ = (view as! GuideTagCell).userInfo!.uid_
            APIHelper.servantAPI().servantDetail(servant, complete: { [weak self](response) in
                if let model = response as? ServantDetailModel {
                    DataManager.insertData(model)
                    let servantPersonalVC = ServantPersonalVC()
                    servantPersonalVC.personalInfo = DataManager.getData(UserInfoModel.self, filter: "uid_ = \(servant.uid_)")?.first
                    self!.navigationController?.pushViewController(servantPersonalVC, animated: true)
                }
            }, error: nil)
            
        }
                
    }
    
    func cashCheck() -> Bool {
        // 余额限制查看个人信息
        if CurrentUser.has_recharged_ == 0 {
            let alert = UIAlertController.init(title: "余额不足", message: "服务者的最低价格为200元，还需充值200元", preferredStyle: .Alert)
            
            let ok = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                let rechargeVC = RechargeVC()
                self.navigationController?.pushViewController(rechargeVC, animated: true)
                
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
                
            })
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        return true
    }
    
    func checkAuthStaus() -> Bool {
        // 认证状态限制查看个人信息
        if CurrentUser.auth_status_ != 1 {
            APIHelper.userAPI().authStatus({ [weak self](response) in
                if let dict = response as? [String: AnyObject] {
                    if let status = dict["review_status_"] as? Int {
                        CurrentUser.auth_status_ = status
                        if status != 1 {
                            let msgs = [-1: "尊敬的游客，您尚未申请认证，请立即前往认证，成为优悦出行的正式游客",
                                0: "尊敬的游客，您的认证尚未通过审核，在审核成功后将为您开通查看服务者信息的权限",
                                2: "尊敬的游客，您的认证未通过审核，请立即前往认证，成为优悦出行的正式游客"]
                            let alert = UIAlertController.init(title: "查看服务者信息失败", message: msgs[status], preferredStyle: .Alert)
                            let ok = UIAlertAction.init(title: "立即申请", style: .Default, handler: { (action) in
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.3)), dispatch_get_main_queue(), { () in
                                    let controller = IDVerifyVC()  // UploadUserPictureVC()
                                    self!.navigationController!.pushViewController(controller, animated: true)
                                })
                            })
                            alert.view.tintColor = UIColor.grayColor()
                            let cancel = UIAlertAction.init(title: status != 0 ? "算了吧" : "好的", style: .Default, handler: { (action) in
                                
                            })
                            if status != 0{
                                alert.addAction(ok)
                            }
                            alert.addAction(cancel)
                            self!.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            }, error: nil)
            
            return false
        }
        return true
    }
   
    public func mapView(mapView: MAMapView!, didFailToLocateUserWithError error: NSError!) {
        
        switch error.code {
        case 1:
            checkLocationService()
            firstLanch = true
            break
        case 4:
            SVProgressHUD.showWainningMessage(WainningMessage: "网络连接超时", ForDuration: 1.5, completion: nil)

            break
        default:
            break
        }
        
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}


