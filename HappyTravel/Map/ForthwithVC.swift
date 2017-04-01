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
    // 筛选类型
    
    enum FilterType: Int {
        case All = 0
        case Bussiness = 1
        case Leisure = 2
        case Score = 3
        case Follow = 4
    }
    var filterType:FilterType = .All
    //筛选弹框
    var alertCtrl:UIAlertController?
    weak var rightLabel:UILabel?
    
    var forcedUpdate = true
    
    var redDotImage:UIImageView = { () -> (UIImageView)in
        let imageView = UIImageView()
        imageView.image = UIImage.init(named:"redDot")
        imageView.tag = 10
        switch UIScreen.mainScreen().bounds.size.width{
        case 414:
            imageView.frame = CGRect(x: 36, y: 30, width: 5, height: 5)
        break
        default:
            imageView.frame = CGRect(x: 33, y: 30, width: 5, height: 5)
        break
        }
        return imageView
    }()
    var redBool : Bool = true
    var first: Bool = false
    
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
        first = false
    }
    
    func followListAction(sender: UIButton) {
        let vc = FollowListVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginFailed(_:)), name: NotifyDefine.LoginFailed, object: nil)
        //红点
        if redBool {
            redDotImage.removeFromSuperview()
        } else {
            redDotImage.hidden = false
            tabBarController!.view.addSubview(redDotImage)
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
        titleBtn!.setImage(UIImage.init(named: "servant-filter-unselect"), forState: .Normal)
        titleBtn!.setImage(UIImage.init(named: "servant-filter-select"), forState: .Selected)
        titleBtn!.addTarget(self, action: #selector(screenServices(_:)), forControlEvents: .TouchUpInside)
        titleView.addSubview(titleBtn!)
        titleBtn!.snp_makeConstraints { (make) in
            make.width.equalTo(130)
            make.centerX.equalTo(titleView).offset(-30)
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
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }

        let followBtn = UIButton()
        followBtn.setBackgroundImage(UIImage.init(named: "follow-list"), forState: .Normal)
        followBtn.backgroundColor = UIColor.clearColor()
        followBtn.setTitle("关注列表", forState: .Normal)
        followBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        followBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        followBtn.addTarget(self, action: #selector(followListAction(_:)), forControlEvents: .TouchUpInside)
        mapView?.addSubview(followBtn)
        followBtn.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(mapView!)
            make.top.equalTo(mapView!).offset(49)
            make.width.equalTo(91)
            make.height.equalTo(41)
        })
        
        
        let back2MyLocationBtn = UIButton()
        back2MyLocationBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        back2MyLocationBtn.layer.masksToBounds = true
        back2MyLocationBtn.layer.cornerRadius = 3
        back2MyLocationBtn.setImage(UIImage.init(named: "mine_location"), forState: .Normal)
        back2MyLocationBtn.addTarget(self, action: #selector(ForthwithVC.back2MyLocationAction(_:)), forControlEvents: .TouchUpInside)
        mapView?.addSubview(back2MyLocationBtn)
        back2MyLocationBtn.snp_makeConstraints { (make) in
            make.left.equalTo(mapView!).offset(15)
            make.bottom.equalTo(mapView!).offset(-80)
            make.width.equalTo(31)
            make.height.equalTo(31)
        }
        
    }
    
    func screenServices(sender:UIButton) {
        titleBtn?.selected = true
        alertCtrl = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let nameArray = ["所有服务者", "商务服务者", "休闲服务者", "取消"]
        for i in 0..<nameArray.count {
            let services = UIAlertAction.init(title: nameArray[i], style: .Default, handler: { (sender: UIAlertAction) in
                if i == nameArray.count-1 {
                    self.titleBtn?.selected = false
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.filterType = FilterType.init(rawValue: i)!
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
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orderListEvaluate(_:)), name: NotifyDefine.OrderList, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orderListNotEvaluate(_:)), name: NotifyDefine.OrderListNo, object: nil)
    }
    
    func loginFailed(notification: NSNotification) {
        presentViewController(regOrLoginSelVC!, animated: false, completion: nil)

    }
    
    func loginSuccessed(notification: NSNotification) {

        banGesture(false)
        
        if CurrentUser.register_status_ == 0 {
            if !isShowBaseInfo {
                isShowBaseInfo = true
                let completeBaseInfoVC = CompleteBaseInfoVC()
                self.navigationController?.pushViewController(completeBaseInfoVC, animated: true)
            }
        }

        if let dt = NSUserDefaults.standardUserDefaults().objectForKey(CommonDefine.DeviceToken) as? String {
            let req = RegDeviceRequestModel()
            req.device_token_ = dt
            req.uid_ = CurrentUser.uid_
            APIHelper.commonAPI().regDevice(req, complete: nil, error: nil)
        }
        
        let lat = DataManager.curLocation?.coordinate.latitude ?? CurrentUser.latitude_
        let lon = DataManager.curLocation?.coordinate.longitude ?? CurrentUser.longitude_
        getServantNearby(lat, lon: lon)
        
        //登录的时候请求订单数据,红点
        var count = 0
        let req = OrderListRequestModel()
        req.uid_ = CurrentUser.uid_
        APIHelper.consumeAPI().orderList(req, complete: { (response) in
            if let models = response as? [OrderListCellModel]{
                for model in models{
                    if model.is_evaluate_ == 0{
                        count = count + 1
                    }
                    else{
                        continue
                    }
                }
                if count == 0{
                    self.first = false
                    NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.OrderListNo, object: nil, userInfo: nil)
                } else {
                    self.first = true
                    NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.OrderList, object: nil, userInfo: nil)
                }
            } else {
                self.first = false
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.OrderListNo, object: nil, userInfo: nil)
            }
            
            },error:{ (error) in
        })
    }

    func getServantNearby(lat: Double, lon:Double) {
        let servantNearbyModel = ServantNearbyModel()
        servantNearbyModel.latitude_ = lat
        servantNearbyModel.longitude_ = lon
        
        APIHelper.servantAPI().servantNearby(servantNearbyModel, complete: { [weak self](response) in
            if let models = response as? [UserInfoModel] {
                self?.annotations.removeAll()
                for servant in models {
                    print(servant)
                    self?.servantsInfo[servant.uid_] = servant
                    DataManager.insertData(servant)
                    let latitude = servant.latitude_
                    let longitude = servant.longitude_
                    let point = MAPointAnnotation.init()
                    point.coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    point.title = "\(servant.uid_)"
                    
//                    TODO: 根据不同类型的servicetype_区分商务服务者或者休闲服务者
//                    let type = servant.servicetype_
//                    //根据serviceType筛选
//                    switch self!.filterType {
//                    case .All:
//                        break
//                    case .Bussiness:
//                        if type == 1 {
//                            continue
//                        }
//                    case .Leisure:
//                        if type == 0 {
//                            continue
//                        }
//                    case .Score:
//                        
//                        break
//                    case .Follow:
//                        
//                        break
//                    }
                    
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
        
        YD_NewPersonGuideManager.startGuide("map-guide", mainGuideInfos: [["image" :"guide-map-1",
                                                                            "view": nil,
                                                                            "size": CGSizeMake(173, 153),
                                                                            "insets": UIEdgeInsetsMake(8888, 8888, -300, -80)]], secGuideInfos: nil)
        
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
    
    func orderListEvaluate(notification: NSNotification?) {
        redBool = false
        redDotImage.image = UIImage.init(named:"redDot")
        if first{
           viewWillAppear(true)
        }
    }
    
    func orderListNotEvaluate(notification: NSNotification?) {
        redBool = true
        redDotImage.image = nil
        if !first {
            viewWillAppear(true)
        }
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
            
            let servantPersonalVC = ServantPersonalVC()
            servantPersonalVC.servantInfo = (view as! GuideTagCell).userInfo
            self.navigationController?.pushViewController(servantPersonalVC, animated: true)
        }
    }
    
    func cashCheck() -> Bool {
        // 余额限制查看个人信息
        if CurrentUser.has_recharged_ == 0 {
            let alert = UIAlertController.init(title: "余额不足", message: "服务者的最低价格为200元，还需充值200元", preferredStyle: .Alert)
            
            let ok = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                let rechargeVC = RechargeVC()
//                self.redDotImage.image = nil
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


