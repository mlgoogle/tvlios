//
//  ForthwithVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import XCGLogger
import RealmSwift

public class ForthwithVC: UIViewController, MAMapViewDelegate, CitysSelectorSheetDelegate {
    
    var titleLab:UILabel?
    var titleBtn:UIButton?
    var msgCountLab:UILabel?
    var segmentSC:UISegmentedControl?
    var mapView:MAMapView?
    var servantsInfo:Dictionary<Int, UserInfo> = [:]
    var annotations:Array<MAPointAnnotation> = []
    var login = false
    var serviceCitys:Dictionary<Int, CityInfo> = [:]
    var citysAlertController:UIAlertController?
    var recommendServants:Array<UserInfo> = []
    var locality:String?
    var location:CLLocation?
    
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
        
        registerNotify()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
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
        
        if PushMessageManager.getUnreadMsgCnt(-1) > 0 {
            msgCountLab?.text = "\(PushMessageManager.getUnreadMsgCnt(-1))"
            msgCountLab?.hidden = false
        } else {
            msgCountLab?.hidden = true
        }
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if login == false {
            let loginVC = LoginVC()
            presentViewController(loginVC, animated: true, completion: nil)
            login = true
        }
        
    }
    
    func initView() {
        let width = UIScreen.mainScreen().bounds.width
        let titleView = UIView()
        titleView.backgroundColor = .clearColor()
        titleView.userInteractionEnabled = true
        navigationItem.titleView = titleView
        titleView.snp_makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(60)
        }
        
        titleLab = UILabel()
        titleLab?.backgroundColor = .clearColor()
        titleLab?.textColor = .whiteColor()
        titleLab?.font = UIFont.systemFontOfSize(18)
        titleLab?.textAlignment = .Center
        titleLab?.userInteractionEnabled = true
        titleView.addSubview(titleLab!)
        titleLab!.snp_makeConstraints { (make) in
            make.centerX.equalTo(titleView.snp_centerX).offset(-10)
            make.top.equalTo(titleView).offset(20)
            make.bottom.equalTo(titleView)
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
            make.top.equalTo(titleView).offset(20)
            make.bottom.equalTo(titleView)
        }
        
        let segmentBGV = UIImageView()
        segmentBGV.image = UIImage.init(named: "head-bg")?.imageWithAlignmentRectInsets(UIEdgeInsetsMake(128, 0, 0, 0))
        view.addSubview(segmentBGV)
        segmentBGV.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(60)
        }
        
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
        
        let bottomSelector = UISlider()
        bottomSelector.minimumValue = 0
        bottomSelector.maximumValue = 1
        bottomSelector.value = 0
        bottomSelector.continuous = false
        bottomSelector.addTarget(self, action: #selector(ForthwithVC.bottomSelectorAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        bottomSelector.setThumbImage(UIImage.init(named: "bottom_selector_selected"), forState: UIControlState.Normal)
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
        mapView!.userTrackingMode = MAUserTrackingMode.Follow
        mapView!.setZoomLevel(12, animated: true)
        mapView!.showsUserLocation = true
        mapView!.showsCompass = true
        view.addSubview(mapView!)
        mapView!.snp_makeConstraints { (make) in
            make.top.equalTo(segmentBGV.snp_bottom)
            make.left.equalTo(view).offset(0.5)
            make.right.equalTo(view).offset(-0.5)
            make.bottom.equalTo(bottomView.snp_top)
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
        
    }
    
    func recommendAction(sender: UIButton?) {
        let recommendVC = RecommendServantsVC()
        recommendVC.servantsInfo = recommendServants
        navigationController?.pushViewController(recommendVC, animated: true)
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.reflushServantInfo(_:)), name: NotifyDefine.ServantInfo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.servantDetailInfo(_:)), name: NotifyDefine.ServantDetailInfo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.jumpToWalletVC), name: NotifyDefine.JumpToWalletVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.serviceCitys(_:)), name: NotifyDefine.ServiceCitys, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.recommendServants(_:)), name: NotifyDefine.RecommendServants, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.jumpToDistanceOfTravelVC), name: NotifyDefine.JumpToDistanceOfTravelVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.jumpToSettingsVC), name: NotifyDefine.JumpToSettingsVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.chatMessage(_:)), name: NotifyDefine.ChatMessgaeNotiy, object: nil)
    }
    
    func chatMessage(notification: NSNotification?) {
        let data = (notification?.userInfo!["data"])! as! Dictionary<String, AnyObject>

        let msg = PushMessage(value: data)

        PushMessageManager.insertMessage(msg)
        if PushMessageManager.getUnreadMsgCnt(-1) > 0 {
            msgCountLab?.text = "\(PushMessageManager.getUnreadMsgCnt(-1))"
            msgCountLab?.hidden = false
            UIApplication.sharedApplication().applicationIconBadgeNumber = PushMessageManager.getUnreadMsgCnt(-1)
        }

        if UserInfoManager.getUserInfo(msg.from_uid_) == nil {
            SocketManager.sendData(.GetUserInfo, data: ["uid_": msg.from_uid_])
        }
        
    }
    
    func recommendServants(notification: NSNotification?) {
        let data = notification?.userInfo!["data"]
        let servants = data!["recommend_guide"] as? Array<Dictionary<String, AnyObject>>
        for servant in servants! {
            let servantInfo = UserInfo()
            servantInfo.setInfo(.Servant, info: servant)
            recommendServants.append(servantInfo)
            UserInfoManager.updateUserInfo(servantInfo)
        }
        if let recommendBtn = mapView!.viewWithTag(2001) as? UIButton {
            recommendBtn.enabled = true
        }
        
    }
    
    func serviceCitys(notification: NSNotification?) {
        let data = notification?.userInfo!["data"]
        let citys = data!["service_city_"] as? Array<Dictionary<String, AnyObject>>
        for city in citys! {
            let cityInfo = CityInfo()
            cityInfo.setInfo(city)
            serviceCitys[cityInfo.cityCode!] = cityInfo
        }
        
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
            XCGLogger.debug("err:\(data!["error_"] as! Int)")
            return
        }
        let servants = data!["result"] as! Array<Dictionary<String, AnyObject>>
        for servant in servants {
            let servantInfo = UserInfo()
            servantInfo.setInfo(.Servant, info: servant)
            servantsInfo[servantInfo.uid] = servantInfo
            UserInfoManager.updateUserInfo(servantInfo)
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
        servantsInfo[data!["uid_"] as! Int]?.setInfo(.Servant, info: data as? Dictionary<String, AnyObject>)
        let user = servantsInfo[data!["uid_"] as! Int]
        UserInfoManager.updateUserInfo(user!)
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = UserInfoManager.getUserInfo(data!["uid_"] as! Int)
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
        XCGLogger.defaultInstance().debug("msg")
        let msgVC = PushMessageVC()
        msgVC.messageInfo = recommendServants
        navigationController?.pushViewController(msgVC, animated: true)
        
    }
    
    func bottomSelectorAction(sender: AnyObject?) {
        let bottomSelector = sender as! UISlider
        if bottomSelector.value > 0.5 {
            bottomSelector.setValue(1, animated: true)
        } else {
            bottomSelector.setValue(0, animated: false)
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
            lonDiffvalue = location!.coordinate.latitude - userLocation.coordinate.latitude
        }
        
        if latDiffValue == 720.0 || latDiffValue >= 0.01 || latDiffValue <= -0.01 || lonDiffvalue >= 0.01 || lonDiffvalue <= -0.01 {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(userLocation.location) { (placeMarks: [CLPlacemark]?, err: NSError?) in
                if placeMarks?.count == 1 {
                    self.locality = (placeMarks?[0])!.locality
                    self.titleLab?.text = self.locality
                    XCGLogger.debug("Update locality: \(self.locality)")
                    self.performSelector(#selector(ForthwithVC.sendLocality), withObject: nil, afterDelay: 1)
                }
            }
        }
        
    }
    
    func sendLocality() {
        if serviceCitys.count > 0 {
            for (cityCode, cityInfo) in serviceCitys {
                if (locality! as NSString).rangeOfString(cityInfo.cityName!).length > 0 {
                    SocketManager.sendData(.GetRecommendServants, data: cityCode)
                    return
                }
            }
        } else {
            performSelector(#selector(ForthwithVC.sendLocality), withObject: nil, afterDelay: 1)
        }
    }
    
    public func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        var id = ""
        let lat = annotation.coordinate.latitude
        let lng = annotation.coordinate.longitude
        XCGLogger.defaultInstance().debug("\(lat)<===>\(lng)")
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
        
        UserInfoManager.currentUser!.gpsLocationLat = 31.20805228400625
        UserInfoManager.currentUser!.gpsLocationLon = 121.60019287100375
        
        return nil
    }
    
    public func mapView(mapView: MAMapView!, didAddAnnotationViews views: [AnyObject]!) {

    }
    
    public func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        if view .isKindOfClass(GuideTagCell) {
            SocketManager.sendData(.GetServantDetailInfo, data: (view as! GuideTagCell).userInfo)
            
        }
                
    }
    
    // MARK: - ServiceSheetDelegate
    func cancelAction(sender: UIButton?) {
        citysAlertController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sureAction(sender: UIButton?, targetCity: CityInfo?) {
        citysAlertController?.dismissViewControllerAnimated(true, completion: nil)
        SocketManager.sendData(.GetRecommendServants, data: targetCity?.cityCode)
    }
    
    deinit {        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
