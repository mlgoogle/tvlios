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

public class ForthwithVC: UIViewController, MAMapViewDelegate, CitysSelectorSheetDelegate, ServantIntroCellDelegate {
    
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

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        firstLanch = true
        
        initView()
        
        registerNotify()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotifyDefine.ServantDetailInfo, object: nil)
    }
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.servantDetailInfo(_:)), name: NotifyDefine.ServantDetailInfo, object: nil)
        if navigationItem.rightBarButtonItem == nil {
            let msgBtn = UIButton.init(frame: CGRectMake(0, 0, 30, 30))
            msgBtn.setImage(UIImage.init(named: "nav-msg"), forState: .Normal)
            msgBtn.backgroundColor = UIColor.clearColor()
            msgBtn.addTarget(self, action: #selector(ForthwithVC.msgAction(_:)), forControlEvents: .TouchUpInside)
            
            let msgItem = UIBarButtonItem.init(customView: msgBtn)
            navigationItem.rightBarButtonItem = msgItem

            msgCountLab = UILabel()
            msgCountLab!.backgroundColor = UIColor.redColor()
            msgCountLab!.text = ""
            msgCountLab!.textColor = UIColor.whiteColor()
            msgCountLab!.textAlignment = .Center
            msgCountLab!.font = UIFont.systemFontOfSize(10)
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
        
        if DataManager.currentUser?.login == false {
            mapView!.setZoomLevel(11, animated: true)
            if regOrLoginSelVC?.isShow == false {
                presentViewController(regOrLoginSelVC!, animated: true, completion: nil)
            }
        } else {
            if DataManager.currentUser!.registerSstatus == 0 {
                let completeBaseInfoVC = CompleteBaseInfoVC()
                self.navigationController?.pushViewController(completeBaseInfoVC, animated: true)
            }
        }
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        appointmentView.nav = navigationController
    }
    
    func initView() {
        let width = UIScreen.mainScreen().bounds.width
        let titleView = UIView.init(frame: CGRectMake(0,0,width,40))
        titleView.backgroundColor = .clearColor()
        titleView.userInteractionEnabled = true
        navigationItem.titleView = titleView
        
        titleLab = UILabel()
        titleLab?.backgroundColor = .clearColor()
        titleLab?.textColor = .whiteColor()
        titleLab?.font = UIFont.systemFontOfSize(18)
        titleLab?.textAlignment = .Center
        titleLab?.userInteractionEnabled = true
        titleView.addSubview(titleLab!)
        titleLab!.snp_makeConstraints { (make) in
            make.centerX.equalTo(titleView.snp_centerX).offset(-10)
            make.centerY.equalTo(titleView.snp_centerY)
        }
        titleLab?.text = "我的位置"
        
        titleBtn = UIButton()
        titleBtn!.backgroundColor = .clearColor()
        titleBtn!.setImage(UIImage.init(named: "address-selector-normal"), forState: .Normal)
        titleBtn!.setImage(UIImage.init(named: "address-selector-selected"), forState: .Selected)
        titleBtn!.addTarget(self, action: #selector(ForthwithVC.titleAction(_:)), forControlEvents: .TouchUpInside)
        titleView.addSubview(titleBtn!)
        titleBtn!.snp_makeConstraints { (make) in
            make.left.equalTo(titleLab!.snp_right)
            make.width.equalTo(20)
            make.centerY.equalTo(titleLab!.snp_centerY)
        }
        
        let segmentBGV = UIImageView()
        segmentBGV.image = UIImage.init(named: "head-bg")?.imageWithAlignmentRectInsets(UIEdgeInsetsMake(128, 0, 0, 0))
        view.addSubview(segmentBGV)

        let segmentItems = ["商务游", "高端游"]
        segmentSC = UISegmentedControl(items: segmentItems)
        segmentSC!.tag = 1001
        segmentSC!.addTarget(self, action: #selector(ForthwithVC.segmentChange), forControlEvents: UIControlEvents.ValueChanged)
        segmentSC!.selectedSegmentIndex = 0
        segmentSC!.layer.masksToBounds = true
        segmentSC?.layer.cornerRadius = 5
        segmentSC?.backgroundColor = UIColor.clearColor()
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        segmentSC?.tintColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
        view.addSubview(segmentSC!)
        segmentSC!.snp_makeConstraints { (make) in
            make.center.equalTo(segmentBGV)
            make.height.equalTo(30)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0)
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
        bottomSelector.addTarget(self, action: #selector(ForthwithVC.bottomSelectorAction(_:)), forControlEvents: .ValueChanged)
        bottomSelector.setThumbImage(UIImage.init(named: "bottom_selector_selected"), forState: .Normal)
        bottomSelector.tintColor = UIColor.whiteColor()
        bottomSelector.minimumTrackTintColor = UIColor.whiteColor()
        bottomSelector.maximumTrackTintColor = UIColor.whiteColor()
        bottomView.addSubview(bottomSelector)
        bottomSelector.snp_makeConstraints { (make) in
            make.center.equalTo(bottomView)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0)
            make.height.equalTo(65)
        }
        
        let leftTips = UILabel()
        leftTips.backgroundColor = UIColor.clearColor()
        leftTips.textAlignment = NSTextAlignment.Right
        leftTips.text = "现在"
        leftTips.userInteractionEnabled = true
        leftTips.font = UIFont.systemFontOfSize(13)
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
        rightTips.font = UIFont.systemFontOfSize(13)
        rightTips.textColor = UIColor.whiteColor()
        bottomView.addSubview(rightTips)
        rightTips.snp_makeConstraints { (make) in
            make.left.equalTo(bottomSelector.snp_right).offset(10)
            make.right.equalTo(bottomView)
            make.top.equalTo(bottomView)
            make.bottom.equalTo(bottomView)
        }
        
        AMapServices.sharedServices().apiKey = "50bb1e806f1d2c1a797e6e789563e334"
        mapView = MAMapView()
        mapView!.tag = 1002
        mapView!.delegate = self
        mapView!.userTrackingMode = .Follow
        mapView!.setZoomLevel(11, animated: true)
        mapView!.showsUserLocation = true
        mapView!.showsCompass = true
        view.addSubview(mapView!)
        mapView!.snp_makeConstraints { (make) in
            make.top.equalTo(segmentBGV.snp_bottom)
            make.left.equalTo(view).offset(0.5)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width - 1)
            make.bottom.equalTo(bottomView.snp_top)
        }
        segmentBGV.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(mapView!).offset(0.5)
            make.height.equalTo(60)
        }
        
        let recommendBtn = UIButton()
        recommendBtn.tag = 2001
        recommendBtn.backgroundColor = .clearColor()
        recommendBtn.setImage(UIImage.init(named: "recommend"), forState: .Normal)
        recommendBtn.addTarget(self, action: #selector(ForthwithVC.recommendAction(_:)), forControlEvents: .TouchUpInside)
        mapView?.addSubview(recommendBtn)
        recommendBtn.snp_makeConstraints { (make) in
            make.left.equalTo(mapView!).offset(20)
            make.top.equalTo(mapView!).offset(20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        recommendBtn.enabled = false
        
        view.addSubview(appointmentView)
        appointmentView.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(mapView!.snp_right).offset(0.5)
            make.top.equalTo(view)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width - 1)
            make.bottom.equalTo(bottomView.snp_top)
        })
        
        let back2MyLocationBtn = UIButton()
        back2MyLocationBtn.backgroundColor = .clearColor()
        back2MyLocationBtn.setImage(UIImage.init(named: "recommend"), forState: .Normal)
        back2MyLocationBtn.addTarget(self, action: #selector(ForthwithVC.back2MyLocationAction(_:)), forControlEvents: .TouchUpInside)
        mapView?.addSubview(back2MyLocationBtn)
        back2MyLocationBtn.snp_makeConstraints { (make) in
            make.left.equalTo(mapView!).offset(20)
            make.bottom.equalTo(mapView!).offset(-20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        hideKeyboard()
    }
    
    func back2MyLocationAction(sender: UIButton) {
        mapView?.setCenterCoordinate(location!.coordinate, animated: true)
    }
    
    func recommendAction(sender: UIButton?) {
        let recommendVC = RecommendServantsVC()
        recommendVC.servantsInfo = recommendServants
        navigationController?.pushViewController(recommendVC, animated: true)
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.loginResult(_:)), name: NotifyDefine.LoginResult, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.reflushServantInfo(_:)), name: NotifyDefine.ServantInfo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.jumpToCenturionCardCenter), name: NotifyDefine.JumpToCenturionCardCenter, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.jumpToWalletVC), name: NotifyDefine.JumpToWalletVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.serviceCitys(_:)), name: NotifyDefine.ServiceCitys, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.recommendServants(_:)), name: NotifyDefine.RecommendServants, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.jumpToDistanceOfTravelVC), name: NotifyDefine.JumpToDistanceOfTravelVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.jumpToSettingsVC), name: NotifyDefine.JumpToSettingsVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.chatMessage(_:)), name: NotifyDefine.ChatMessgaeNotiy, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.appointmentReply(_:)), name: NotifyDefine.AppointmentReply, object: nil)
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
    
    func appointmentReply(notification: NSNotification) {
        let alert = UIAlertController.init(title: "成功", message: "预约已成功，请保持开机！祝您生活愉快！谢谢！", preferredStyle: .Alert)
        let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action) in
            
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
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
    
    func loginResult(notification: NSNotification?) {
        let data = notification?.userInfo!["data"]
        let err = data!.allKeys!.contains({ (key) -> Bool in
            return key as! String == "error_" ? true : false
        })
        if !err {
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.LoginSuccessed, object: nil, userInfo: ["data": data!])
        }
        
    }
    
    func chatMessage(notification: NSNotification?) {
        let msg = (notification?.userInfo!["data"])! as! PushMessage

        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.UpdateChatVC, object: nil, userInfo: ["data": msg])
        
        if DataManager.getUnreadMsgCnt(-1) > 0 {
            msgCountLab?.text = "\(DataManager.getUnreadMsgCnt(-1))"
            msgCountLab?.hidden = false
        }

        if DataManager.getUserInfo(msg.from_uid_) == nil {
            //TUDO
            SocketManager.sendData(.GetUserInfo, data: ["uid_str_": "\(msg.from_uid_)"])
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.PushMessageNotify, object: nil, userInfo: ["data": msg])
    }
    
    func recommendServants(notification: NSNotification?) {
        if let data = notification?.userInfo!["data"] as? Dictionary<String, AnyObject> {
            let servants = data["recommend_guide"] as? Array<Dictionary<String, AnyObject>>
            let type = data["recommend_type"] as! Int
            var uid_str = ""
            if type == 1 {
                for servant in servants! {
                    let servantInfo = UserInfo()
                    servantInfo.setInfo(.Servant, info: servant)
                    recommendServants.append(servantInfo)
                    DataManager.updateUserInfo(servantInfo)
                    uid_str += "\(servantInfo.uid),"
                }
                if let recommendBtn = mapView!.viewWithTag(2001) as? UIButton {
                    recommendBtn.enabled = true
                }
            } else if type == 2 {
                for servant in servants! {
                    let servantInfo = UserInfo()
                    servantInfo.setInfo(.Servant, info: servant)
                    subscribeServants.append(servantInfo)
                    DataManager.updateUserInfo(servantInfo)
                    uid_str += "\(servantInfo.uid),"
                }
                if header.state == .Refreshing {
                    header.endRefreshing()
                }
                
            }
            uid_str.removeAtIndex(uid_str.endIndex.predecessor())
            let dict:Dictionary<String, AnyObject> = ["uid_str_": uid_str]
            SocketManager.sendData(.GetUserInfo, data: dict)
        }
        
    }
    
    func serviceCitys(notification: NSNotification?) {
        if let data = notification?.userInfo!["data"] {
            if let citys = data["service_city_"] as? Array<Dictionary<String, AnyObject>> {
                for city in citys {
                    let cityInfo = CityInfo()
                    cityInfo.setInfo(city)
                    serviceCitys[cityInfo.cityCode!] = cityInfo
                }
            }
            
        }
        appointmentView.serviceCitys = serviceCitys
        
        regOrLoginSelVC!.dismissViewControllerAnimated(false) {
            self.regOrLoginSelVC?.dismissViewControllerAnimated(false) {
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
    
    func jumpToDistanceOfTravelVC() {
        let distanceOfTravelVC = DistanceOfTravelVC()
        navigationController?.pushViewController(distanceOfTravelVC, animated: true)
    }
    
    func jumpToSettingsVC() {
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func reflushServantInfo(notification: NSNotification?) {
        let data = notification?.userInfo!["data"]
        let err = data!.allKeys!.contains({ (key) -> Bool in
            return key as! String == "error_" ? true : false
        })
        if err {
            XCGLogger.error("err:\(data!["error_"] as! Int)")
            return
        }
        let servants = data!["result"] as! Array<Dictionary<String, AnyObject>>
        for servant in servants {
            let servantInfo = UserInfo()
            servantInfo.setInfo(.Servant, info: servant)
            servantsInfo[servantInfo.uid] = servantInfo
            DataManager.updateUserInfo(servantInfo)
            let latitude = servantInfo.gpsLocationLat
            let longitude = servantInfo.gpsLocationLon
            let point = MAPointAnnotation.init()
            point.coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            point.title = "\(servantInfo.uid)"
            annotations.append(point)
        }
        mapView!.addAnnotations(annotations)
        mapView!.showAnnotations(annotations, animated: true)
        
    }
    
    func servantDetailInfo(notification: NSNotification?) {
        let data = notification?.userInfo!["data"]
        if data!["error_"]! != nil {
            XCGLogger.error("Get UserInfo Error:\(data!["error_"])")
            return
        }
        servantsInfo[data!["uid_"] as! Int]?.setInfo(.Servant, info: data as? Dictionary<String, AnyObject>)
        let user = servantsInfo[data!["uid_"] as! Int]
        DataManager.updateUserInfo(user!)
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data!["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
        
    }
    
    func titleAction(sender: UIButton?) {
        XCGLogger.debug(sender?.currentTitle)
        
        if citysAlertController == nil {
            citysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
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
     
        
        var latDiffValue = Double(0)
        var lonDiffvalue = Double(0)
        if location == nil {
            location = userLocation.location
            latDiffValue = 720.0
        } else {
            latDiffValue = location!.coordinate.latitude - userLocation.coordinate.latitude
            lonDiffvalue = location!.coordinate.longitude - userLocation.coordinate.longitude
        }
        
        if latDiffValue == 720.0 || latDiffValue >= 0.01 || latDiffValue <= -0.01 || lonDiffvalue >= 0.01 || lonDiffvalue <= -0.01 {
            let geoCoder = CLGeocoder()
            if userLocation.location != nil {
                geoCoder.reverseGeocodeLocation(userLocation.location) { (placeMarks: [CLPlacemark]?, err: NSError?) in
                    if placeMarks?.count == 1 {
                        self.locality = (placeMarks?[0])!.locality
                        self.titleLab?.text = self.locality
                        XCGLogger.debug("Update locality: \(self.locality!)")
                        DataManager.currentUser!.gpsLocationLat = userLocation.coordinate.latitude
                        DataManager.currentUser!.gpsLocationLon = userLocation.coordinate.longitude
                        self.performSelector(#selector(ForthwithVC.sendLocality), withObject: nil, afterDelay: 1)
                        SocketManager.sendData(.GetServantInfo, data: nil)
                    }
                }
            }
            
        }
        
       
        
    }
    
    func sendLocality() {
        mapView!.setZoomLevel(11, animated: true)
        if serviceCitys.count > 0 {
            for (cityCode, cityInfo) in serviceCitys {
                if (locality! as NSString).rangeOfString(cityInfo.cityName!).length > 0 {
                    var dict = ["city_code_": cityCode, "recommend_type_": 1]
                    SocketManager.sendData(.GetRecommendServants, data: dict)
                    dict["recommend_type_"] = 2
                    SocketManager.sendData(.GetRecommendServants, data: dict)
                    return
                }
            }
            
            if firstLanch {
                mapView!.centerCoordinate = location!.coordinate
                firstLanch = false
            }
        } else {
            performSelector(#selector(ForthwithVC.sendLocality), withObject: nil, afterDelay: 1)
        }
        
        
    }
    
    public func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        var id = ""
        let lat = annotation.coordinate.latitude
        let lng = annotation.coordinate.longitude
        for (_, servantInfo) in servantsInfo {
            if servantInfo.gpsLocationLat == lat && servantInfo.gpsLocationLon == lng {
                if servantInfo.userType == UserInfo.UserType.Servant.rawValue {
                    id = "Guide"
                    var annotationView:GuideTagCell? = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? GuideTagCell
                    if annotationView == nil{
                        annotationView = GuideTagCell.init(annotation: annotation, reuseIdentifier: id) as GuideTagCell
                    }
                    annotationView!.setInfo(servantInfo)
                    return annotationView
                } else if servantInfo.userType == UserInfo.UserType.MeetLocation.rawValue {
                    id = "Meet"
                    var annotationView:MeetTagCell? = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? MeetTagCell
                    if annotationView == nil{
                        annotationView = MeetTagCell.init(annotation: annotation, reuseIdentifier: id) as MeetTagCell
                    }
                    annotationView!.setInfo(servantInfo)
                    return annotationView
                }
         
            }
        }
        
//        DataManager.currentUser!.gpsLocationLat = 31.20805228400625
//        DataManager.currentUser!.gpsLocationLon = 121.60019287100375
        
        return nil
    }
    
    public func mapView(mapView: MAMapView!, didAddAnnotationViews views: [AnyObject]!) {

    }
    
    public func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        if view.isKindOfClass(GuideTagCell) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            if DataManager.currentUser!.certification == false {
                let alert = UIAlertController.init(title: "尚未申请认证", message: "尊敬的游客，您尚未申请认证，请立即前往认证，成为V领队的正式游客", preferredStyle: .Alert)
                let ok = UIAlertAction.init(title: "立即申请", style: .Default, handler: { (action) in
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.3)), dispatch_get_main_queue(), { () in
                        let controller = UploadUserPictureVC()
                        self.navigationController!.pushViewController(controller, animated: true)
                        DataManager.currentUser?.certification = true
                    })
                })
                alert.view.tintColor = UIColor.grayColor()
                let cancel = UIAlertAction.init(title: "算了吧", style: .Default, handler: nil)
                alert.addAction(ok)
                alert.addAction(cancel)
                presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            SocketManager.sendData(.GetServantDetailInfo, data: (view as! GuideTagCell).userInfo)
            
        }
                
    }
   
    
    // MARK: - ServiceSheetDelegate
    func cancelAction(sender: UIButton?) {
        citysAlertController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sureAction(sender: UIButton?, targetCity: CityInfo?) {
        guard targetCity != nil else { return }
        recommendServants.removeAll()
        citysAlertController?.dismissViewControllerAnimated(true, completion: nil)
        let dict:Dictionary<String, AnyObject> = ["city_code_": (targetCity?.cityCode)!, "recommend_type_": 1]
        SocketManager.sendData(.GetRecommendServants, data: dict)
    }
    
    func headerRefresh() {
        let dict = ["city_code_": cityCode, "recommend_type_": 2]
        SocketManager.sendData(.GetRecommendServants, data: dict)
    }
    
    //MARK: - ServantIntroCellDeleagte
    func chatAction(servantInfo: UserInfo?) {
        SocketManager.sendData(.GetServantDetailInfo, data: servantInfo)

    }
    
    deinit {        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}


