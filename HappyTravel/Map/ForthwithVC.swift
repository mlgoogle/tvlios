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


public class ForthwithVC: UIViewController, MAMapViewDelegate {
    
    var titleLab:UILabel?
    var titleBtn:UIButton?
    var msgCountLab:UILabel?
    var mapView:MAMapView?
    var servantsInfo:Dictionary<Int, UserInfoModel> = [:]
    var annotations:Array<MAPointAnnotation> = []
    var login = false
    
    var subscribeServants:Array<UserInfoModel> = []
    var locality:String?
    var location:CLLocation?
    var regOrLoginSelVC:RegOrLoginSelVC? = RegOrLoginSelVC()
    var cityCode = 0
    var firstLanch = true
    var lastMapCenter: CLLocationCoordinate2D?
    var feedBack: YWFeedbackKit = YWFeedbackKit.init(appKey: "23519848")
    //延时测试用
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
//        YD_ContactManager.checkIfUploadContact()  // 暂时取消
        
        registerNotify()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotifyDefine.LoginFailed, object: nil)
        
    }
    
    func followListAction(sender: UIButton) {
        let vc = FollowListVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginFailed(_:)), name: NotifyDefine.LoginFailed, object: nil)

        if navigationItem.rightBarButtonItem == nil {
            let followBtn = UIButton.init(frame: CGRectMake(0, 0, 30, 30))
            followBtn.setImage(UIImage.init(named: "nav-personal"), forState: .Normal)
            followBtn.backgroundColor = UIColor.clearColor()
            followBtn.addTarget(self, action: #selector(followListAction(_:)), forControlEvents: .TouchUpInside)
            
            let followItem = UIBarButtonItem.init(customView: followBtn)
            navigationItem.rightBarButtonItem = followItem
            
            msgCountLab = UILabel()
            msgCountLab!.backgroundColor = UIColor.redColor()
            msgCountLab!.text = ""
            msgCountLab!.textColor = UIColor.whiteColor()
            msgCountLab!.textAlignment = .Center
            msgCountLab!.font = UIFont.systemFontOfSize(S10)
            msgCountLab!.layer.cornerRadius = 18 / 2.0
            msgCountLab!.layer.masksToBounds = true
            msgCountLab!.hidden = true
            followBtn.addSubview(msgCountLab!)
            msgCountLab!.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(followBtn).offset(5)
                make.top.equalTo(followBtn).offset(-2)
                make.width.equalTo(18)
                make.height.equalTo(18)
            })
        }
        
        if CurrentUser.login_ == false {
            if APIHelper.userAPI().autoLogin() {
                banGesture(true)
            } else {
                self.presentViewController(self.regOrLoginSelVC!, animated: false, completion: nil)
            }

        }

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
        titleBtn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
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
        
        mapView = MAMapView()
        mapView!.tag = 1002
        mapView!.delegate = self
        mapView!.userTrackingMode = .Follow
        mapView!.setZoomLevel(13, animated: true)
        mapView!.showsUserLocation = true
        mapView!.showsCompass = true
        view.addSubview(mapView!)
        mapView!.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view).offset(0.5)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width - 1)
            make.bottom.equalTo(view)
        }

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
    
    func back2MyLocationAction(sender: UIButton) {
        checkLocationService()
        if location != nil {
            mapView?.setCenterCoordinate(location!.coordinate, animated: true)
        }
        
    }

    func registerNotify() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(loginSuccessed(_:)), name: NotifyDefine.LoginSuccessed, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToWalletVC), name: NotifyDefine.JumpToWalletVC, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToMessageCenter), name: NotifyDefine.JumpToMessageCenter, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToCompeleteBaseInfoVC), name: NotifyDefine.JumpToCompeleteBaseInfoVC, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToSettingsVC), name: NotifyDefine.JumpToSettingsVC, object: nil)
        notificationCenter.addObserver(self, selector: #selector(jumpToFeedBackVC), name: NotifyDefine.FeedBackNoticeReply, object: nil)
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

        if let dt = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.DeviceToken) as? String {
            let req = RegDeviceRequestModel()
            req.device_token_ = dt
            req.uid_ = CurrentUser.uid_
            APIHelper.commonAPI().regDevice(req, complete: nil, error: nil)
        }
        
        let lat = DataManager.curLocation?.coordinate.latitude ?? CurrentUser.latitude_
        let lon = DataManager.curLocation?.coordinate.longitude ?? CurrentUser.longitude_
        getServantNearby(lat, lon: lon)
        
    }

    func getServantNearby(lat: Double, lon:Double) {
        let servantNearbyModel = ServantNearbyModel()
        servantNearbyModel.latitude_ = lat
        servantNearbyModel.longitude_ = lon
        APIHelper.servantAPI().servantNearby(servantNearbyModel, complete: { [weak self](response) in
            if let models = response as? [UserInfoModel] {
                self?.annotations.removeAll()
                for servant in models {
                    self?.servantsInfo[servant.uid_] = servant
                    DataManager.insertData(servant)
                    let latitude = servant.latitude_
                    let longitude = servant.longitude_
                    let point = MAPointAnnotation.init()
                    point.coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    point.title = "\(servant.uid_)"
                    //根据serviceType筛选
                    if self?.serviceType != 999 {
                        //不是默认的所有服务者，进行筛选
                        let type = servant.servicetype_
                        //不是类型2和要筛选的服务者，忽略
                        if  type != self?.serviceType && type != 2 {
                            continue
                        }
                    }
                    self?.annotations.append(point)
                }
                if self?.mapView!.annotations.count > 0{
                    self?.mapView?.removeAnnotations(self?.mapView!.annotations)
                }
                self?.mapView!.addAnnotations(self?.annotations)
            }
            }, error: { (err) in
                print(err)
        })
    }
    
    func jumpToWalletVC() {
        let walletVC = WalletVC()
        navigationController?.pushViewController(walletVC, animated: true)
    }
    
    func jumpToMessageCenter() {
        let msgVC = PushMessageVC()
        navigationController?.pushViewController(msgVC, animated: true)
    }
    
    func jumpToCompeleteBaseInfoVC() {
        let completeBaseInfoVC = CompleteBaseInfoVC()
        navigationController?.pushViewController(completeBaseInfoVC, animated: true)

    }
    
    func jumpToSettingsVC() {
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func postPushMessageNotify(data: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.PushMessageNotify, object: nil, userInfo: ["data": data!])
    }
    
    // MARK MAP
    public func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        DataManager.curLocation = userLocation.location
        var latDiffValue = Double(0)
        var lonDiffvalue = Double(0)
        if location == nil {
            location = userLocation.location
            latDiffValue = 720.0
            mapView.setZoomLevel(13, animated: false)
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
                }
            }
        }
        
        return nil
    }
    
    public func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        if view.isKindOfClass(GuideTagCell) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            
            let servant = UserBaseModel()
            servant.uid_ = (view as! GuideTagCell).userInfo!.uid_
            APIHelper.servantAPI().servantDetail(servant, complete: { [weak self](response) in
                if let model = response as? ServantDetailModel {
                    DataManager.insertData(model)
                    let servantPersonalVC = ServantPersonalVC()
                    servantPersonalVC.personalInfo = DataManager.getData(UserInfoModel.self, filter: "uid_ = \(servant.uid_)")?.first
                    self?.navigationController?.pushViewController(servantPersonalVC, animated: true)
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


