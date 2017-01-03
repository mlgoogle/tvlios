//
//  ShowMapHeaderView.swift
//  TestAdress
//
//  Created by J-bb on 16/12/28.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import UIKit
import MapKit
protocol ShowSearchVCDelegate:NSObjectProtocol {
    
    func showSearchVC()
}

class ShowMapHeaderView: UITableViewHeaderFooterView {

    var delegate:ShowSearchVCDelegate?
    
    
    lazy var mapView:MAMapView = {
        
        let mapView = MAMapView()
        mapView.userTrackingMode = .Follow
        
        mapView.showsUserLocation = true
        mapView.setZoomLevel(12, animated: true)
        mapView.showsCompass = true
        return mapView
    }()
    
    lazy var searchView:UIView = {
       
        let view = UIView()
        
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()

    lazy var searchButton:UIButton = {
       
        let button = UIButton(type: .Custom)
        button.backgroundColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setTitle("搜索", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor( UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0), forState: .Normal)
        button.setImage(UIImage.init(named: "fangda"), forState: .Normal)
        return button
    }()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(mapView)

        addSubview(searchView)
        
        searchView.addSubview(searchButton)
        
        
        searchView.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(44)
        }
        
        searchButton.snp_makeConstraints { (make) in
            make.top.equalTo(5)
            make.right.equalTo(-15)
            make.left.equalTo(15)
            make.bottom.equalTo(-5)
        }
        
        mapView.snp_makeConstraints { (make) in
            make.top.equalTo(searchView.snp_bottom).offset(0)
            make.right.equalTo(searchView)
            make.left.equalTo(searchView)
            make.bottom.equalTo(self)
        }
        
        searchButton.addTarget(self, action: #selector(ShowMapHeaderView.showSearchAction), forControlEvents: .TouchUpInside)
    }
    
    func showSearchAction() {
        guard delegate != nil else {return}
        delegate?.showSearchVC()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

