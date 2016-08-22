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

public class ForthwithVC: UIViewController, MAMapViewDelegate {
    
    var titleLab:UILabel?
    var titleBtn:UIButton?
    var segmentSC:UISegmentedControl?
    var mapView:MAMapView?
    var servantsInfo:Array<UserInfo>? = []
    var annotations:Array<MAPointAnnotation> = []
    var login = false
    
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
            let msgItem = UIBarButtonItem.init(image: UIImage.init(named: "nav-msg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ForthwithVC.msgAction))
            navigationItem.rightBarButtonItem = msgItem
        }
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        mapView!.userTrackingMode = MAUserTrackingMode.Follow
        mapView!.addAnnotations(annotations)
        mapView!.showAnnotations(annotations, animated: true)
        mapView!.setZoomLevel(12, animated: true)
        mapView!.showsUserLocation = true
        mapView!.showsCompass = true
        
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
        
        
        AMapServices.sharedServices().apiKey = "11feec2b7ad127ae156d72aa08f2342e"
        mapView = MAMapView()
        mapView!.tag = 1002
        mapView!.delegate = self
        view.addSubview(mapView!)
        mapView!.snp_makeConstraints { (make) in
            make.top.equalTo(segmentBGV.snp_bottom)
            make.left.equalTo(view).offset(0.5)
            make.right.equalTo(view).offset(-0.5)
            make.bottom.equalTo(bottomView.snp_top)
        }
        
        let recommendBtn = UIButton()
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
    }
    
    func recommendAction(sender: UIButton?) {
        let recommendVC = RecommendServantsVC()
        navigationController?.pushViewController(recommendVC, animated: true)
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.reflushAddress), name: NotifyDefine.ReflushAddress, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForthwithVC.reflushServantInfo(_:)), name: NotifyDefine.ServantInfo, object: nil)
    }
    
    func reflushAddress() {
        titleLab?.text = UserInfo.currentUser.address!
        SocketManager.sendData(.GetServantInfo, data: nil)
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
            servantsInfo?.append(servantInfo)
            let latitude = servantInfo.gpsLocation.latitude
            let longitude = servantInfo.gpsLocation.longitude
            let point = MAPointAnnotation.init()
            point.coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            point.title = "\(servantInfo.uid)"
            annotations.append(point)
        }
        
    }
    
    func titleAction(sender: UIButton?) {
        XCGLogger.debug(sender?.currentTitle)
    }
    
    func msgAction(sender: AnyObject?) {
        XCGLogger.defaultInstance().debug("msg")
        
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
        if updatingLocation {
            
        }
    }
    
    public func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        var id = ""
        let lat = annotation.coordinate.latitude
        let lng = annotation.coordinate.longitude
        XCGLogger.defaultInstance().debug("\(lat)<===>\(lng)")
        for servantInfo in servantsInfo! {
            if servantInfo.gpsLocation.latitude == lat && servantInfo.gpsLocation.longitude == lng {
                if servantInfo.userType == .Servant {
                    id = "Guide"
                    var annotationView:GuideTagCell? = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? GuideTagCell
                    if annotationView == nil{
                        annotationView = GuideTagCell.init(annotation: annotation, reuseIdentifier: id) as GuideTagCell
                    }
                    annotationView!.setInfo(servantInfo)
                    return annotationView
                } else if servantInfo.userType == .MeetLocation {
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
        
        return nil
    }
    
    public func mapView(mapView: MAMapView!, didAddAnnotationViews views: [AnyObject]!) {

    }
    
    public func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        if view .isKindOfClass(GuideTagCell) {
            XCGLogger.debug("LocalGuidePersonal")
            let servantPersonalVC = ServantPersonalVC()
            navigationController?.pushViewController(servantPersonalVC, animated: true)
        }
                
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
