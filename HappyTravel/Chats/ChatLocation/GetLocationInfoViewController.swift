//
//  GetLocationInfoViewController.swift
//  TestAdress
//
//  Created by J-bb on 16/12/28.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import UIKit
protocol SendLocationMessageDelegate:NSObjectProtocol {
    func sendLocation(poiModel:POIInfoModel?)
}

class GetLocationInfoViewController: UIViewController {

    var isFirst = true
    
    var annotation:MAPointAnnotation?
    
    var poiArray = Array<POIInfoModel>()
    
    var selectIndex = 0
    
    var centerPOIModel:POIInfoModel?
    var city:String?
    weak var delegate:SendLocationMessageDelegate?
    
    weak var mapView:MAMapView?
    lazy var searchManager:AMapSearchAPI = {
       let searchAPI = AMapSearchAPI()
        searchAPI.delegate = self
        return searchAPI
    }()
    lazy var geocoder:CLGeocoder = {
    
        let geocoder = CLGeocoder()
        
        return geocoder
    }()
    
    lazy var tableView:UITableView = {
        
        
        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "位置"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: .Done, target: self, action: #selector(GetLocationInfoViewController.sendLocation))
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        tableView.backgroundColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
        tableView.registerClass(ChatLocationAnotherCell.self, forCellReuseIdentifier: "POIInfoCell")
        tableView.registerClass(ChatLocationMeCell.self, forCellReuseIdentifier: "meCell")
        
        tableView.registerClass(POIInfoCell.self, forCellReuseIdentifier: "poi")
        tableView.registerClass(ShowMapHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    
    
    func sendLocation() {
        navigationController?.popViewControllerAnimated(true)
        guard delegate != nil else {return}
        delegate?.sendLocation(centerPOIModel)
        
    }
}


extension GetLocationInfoViewController:UITableViewDataSource, UITableViewDelegate,ShowSearchVCDelegate, SelectPoiDelegate{
 
    
    func selectPOI(poi: POIInfoModel) {
        
        mapView?.removeAnnotation(annotation)
        let coordinate = CLLocationCoordinate2D(latitude: poi.latiude, longitude: poi.longtiude)
        addAnnotationWithCoordinate(coordinate)
        mapView?.centerCoordinate = coordinate
        getInfoWithLocation(CLLocation(latitude: poi.latiude, longitude: poi.longtiude))


    }
    
    func showSearchVC() {
        let searchVC = SearchListViewController()
        searchVC.delegate = self
        searchVC.city = city
        searchVC.modalTransitionStyle = .CrossDissolve
        presentViewController(searchVC, animated: true, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectModel = poiArray[selectIndex]
        selectModel.isSelect = false
        let willSelectModel = poiArray[indexPath.row]
        willSelectModel.isSelect = true
        tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: selectIndex, inSection: 0), NSIndexPath.init(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        selectIndex = indexPath.row
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! ShowMapHeaderView
        mapView = headerView.mapView
        mapView?.delegate = self
        headerView.delegate = self
        return headerView
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 255
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = poiArray[indexPath.row]
        let poiCell = tableView.dequeueReusableCellWithIdentifier("poi", forIndexPath: indexPath) as! POIInfoCell
        poiCell.setDataWithModel(model)
        return poiCell
    }
}

extension GetLocationInfoViewController:MAMapViewDelegate, AMapSearchDelegate{
    
    func addCenterAnnotation() {
        selectIndex = 0
        mapView!.removeAnnotation(annotation)
        addAnnotationWithCoordinate(mapView!.centerCoordinate)
    }
    
    func addAnnotationWithCoordinate(coordinate:CLLocationCoordinate2D) {
        annotation = MAPointAnnotation()
        annotation!.coordinate = coordinate
        mapView!.addAnnotations([annotation!])
    }
     func mapView(mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        
        guard wasUserAction == true else {return}
        
        addCenterAnnotation()
        
        getInfoWithLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
    }
    
     func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {

        if annotation.coordinate.latitude == mapView.centerCoordinate.latitude && annotation.coordinate.longitude == mapView.centerCoordinate.longitude {
            let identifier = "center"
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView.image = UIImage(named: "datou")
            return annotationView
        }
        return nil
    }

   internal func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if userLocation.location != nil {
            if isFirst {
                mapView?.setZoomLevel(12, animated: true)
                mapView.centerCoordinate =  userLocation.coordinate
                addCenterAnnotation()

                getInfoWithLocation(userLocation.location)
                isFirst = false
            }
        }
    }
    
    func getLocationWithCoordinate(coordinate:CLLocationCoordinate2D) -> CLLocation? {
        
        return nil
    }
    
    func getInfoWithLocation(location:CLLocation) {

        geocoder.reverseGeocodeLocation(location) { (placeMarks: [CLPlacemark]?, err: NSError?) in
            guard placeMarks?.count > 0 else {return}
            for placeMark in placeMarks! {
                
                print("name == \(placeMark.name)\n")

                self.city = placeMark.locality
                let poiModel = POIInfoModel()
                poiModel.latiude = location.coordinate.latitude
                poiModel.longtiude = location.coordinate.longitude
                poiModel.name = placeMark.name
                poiModel.isSelect = true
                poiModel.detail = placeMark.locality! + placeMark.name!
                self.centerPOIModel = poiModel
                self.getPOIInfosWithLocation(location)
            }
            
        }
    }

    func getPOIInfosWithLocation(location:CLLocation){
        
        let request = AMapPOIAroundSearchRequest()
        let currentLocation = AMapGeoPoint()
        currentLocation.latitude = CGFloat(location.coordinate.latitude)
        currentLocation.longitude = CGFloat(location.coordinate.longitude)
        request.location = currentLocation
        request.radius = 500
        request.types = "风景名胜|公司企业|交通设施服务"
        searchManager.AMapPOIAroundSearch(request)
        
    }
    func AMapSearchRequest(request: AnyObject!, didFailWithError error: NSError!) {
        //搜索附近POI出错
    }
    func onPOISearchDone(request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
     
        poiArray.removeAll()
        for poi in response.pois {
            let poiModel = POIInfoModel()
            poiModel.name = poi.name
            poiModel.detail = poi.address
            poiModel.latiude = Double(poi.location.latitude)
            poiModel.longtiude = Double(poi.location.longitude)
            poiArray.append(poiModel)
        }
        poiArray.insert(centerPOIModel!, atIndex: 0)
        tableView.reloadData()
    }
}
