//
//  SearchListViewController.swift
//  TestAdress
//
//  Created by J-bb on 16/12/30.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import Foundation

protocol SelectPoiDelegate:NSObjectProtocol {
    
    func selectPOI(poi:POIInfoModel)
    
}

class SearchListViewController: UIViewController {
   
    var city:String?
    
    var poiArray = Array<POIInfoModel>()

    weak var delegate:SelectPoiDelegate?
    lazy var searchManager:AMapSearchAPI = {
        let searchAPI = AMapSearchAPI()
        searchAPI.delegate = self
        return searchAPI
    }()
    lazy var tableView:UITableView = {
       
        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self

        return tableView
    }()
    
    func initViews() {
    
        view.addSubview(tableView)
    
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cells")
        tableView.registerClass(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
  
    }
    
    
    func selfDismiss() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func loadView() {
        super.loadView()
        initViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)

    }
}

extension SearchListViewController:UITextFieldDelegate , AMapSearchDelegate{
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
      
        searchWithKeyWords(textField.text)
        textField.resignFirstResponder()
        return true
    }
    
    
    func searchWithKeyWords(keyWords:String?) {
        
        guard keyWords != nil else {return}
        let request = AMapPOIKeywordsSearchRequest()
        if city != nil {
            request.city = city!
        }
        request.keywords = keyWords
        request.types = "风景名胜|公司企业|交通设施服务"
        request.requireExtension = true
        request.cityLimit = true
        request.requireSubPOIs = true
        searchManager.AMapPOIKeywordsSearch(request)
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
        tableView.reloadData()
    }
}

extension SearchListViewController:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SearchHeaderView") as! SearchHeaderView
        searchView.cancelButton.addTarget(self, action: #selector(SearchListViewController.selfDismiss), forControlEvents: .TouchUpInside)
        searchView.textField.delegate = self
        
        return searchView
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cells", forIndexPath: indexPath)
        
        let poiModel = poiArray[indexPath.row]
        cell.textLabel?.text = poiModel.name
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selfDismiss()
        guard delegate != nil else{return}
        
        delegate?.selectPOI(poiArray[indexPath.row])
    }
}