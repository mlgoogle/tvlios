//
//  ShowLocationDetailViewController.swift
//  TestAdress
//
//  Created by J-bb on 16/12/30.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import UIKit
import MapKit

class ShowLocationDetailViewController: UIViewController {
    lazy var mapView:MAMapView = {
        
        let mapView = MAMapView()
        
        return mapView
    }()
    var isFirst = true
    var poiModel:POIInfoModel?
    lazy var geocoder:CLGeocoder = {
        
        let geocoder = CLGeocoder()
        
        return geocoder
    }()


    
    func initViews() {
        
        view.addSubview(mapView)
        
        mapView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        mapView.userTrackingMode = .Follow
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setZoomLevel(12, animated: true)
        mapView.showsCompass = true
    }
    override func loadView() {
        super.loadView()
        
        title = "位置信息"
        initViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard poiModel != nil else {return}
        

    }

    func addCenterAnnotation() {
        let annotation = MAPointAnnotation()
        annotation.coordinate = mapView.centerCoordinate
        annotation.subtitle = poiModel?.detail
        annotation.title = poiModel?.name
        mapView.addAnnotations([annotation])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ShowLocationDetailViewController:MAMapViewDelegate, OpenMapDelegate{
    
    internal func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if userLocation.location != nil {
            if isFirst {
                mapView?.setZoomLevel(12, animated: true)
                isFirst = false
                
                mapView.centerCoordinate = CLLocationCoordinate2D(latitude: poiModel!.latiude, longitude: poiModel!.longtiude)
                addCenterAnnotation()
            }
        }
    }

    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.coordinate.latitude == mapView.centerCoordinate.latitude && annotation.coordinate.longitude == mapView.centerCoordinate.longitude {
            let identifier = "center"
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? YD_AnnotationView
            if annotationView == nil {
                annotationView = YD_AnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.nameLabel.text = poiModel?.name
            annotationView?.adressLabel.text = poiModel?.detail
            annotationView!.image = UIImage(named: "chat_location")
            annotationView?.delegate = self
            return annotationView
        }
        return nil
    }

    func openMap(annomationView: YD_AnnotationView) {
        reverseGeocodeWithLocation(CLLocation(latitude: Double(poiModel!.latiude), longitude: Double(poiModel!.longtiude)))
    }
    
    func AMapSearchRequest(request: AnyObject!, didFailWithError error: NSError!) {
        //失败
    }
    func onRouteSearchDone(request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
      
        
        
        if response.route == nil {
            return
        }
        

    }

    func reverseGeocodeWithLocation(location:CLLocation) {
        geocoder.reverseGeocodeLocation(location) { (placeMarks: [CLPlacemark]?, err: NSError?) in
            guard placeMarks?.count > 0 else{return}
            let sourcepm = MKPlacemark(placemark: (placeMarks?.first)!)
            self.openMapWithMKPlacemark(sourcepm)
        }
    }
    
    func openMapWithMKPlacemark(mkPlacemark:MKPlacemark) {
        
        let mkMapItem = MKMapItem(placemark: mkPlacemark)
        let array = [mkMapItem]
        
        var options:Dictionary<String,AnyObject> = [:]
        
        options[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving;
        
        options[MKLaunchOptionsShowsTrafficKey] = true;
        
        MKMapItem.openMapsWithItems(array, launchOptions: options)
    }
}
