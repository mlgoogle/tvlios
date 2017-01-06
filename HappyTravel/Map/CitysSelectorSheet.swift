//
//  CitysSelectorSheet.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/23.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

@objc protocol CitysSelectorSheetDelegate : NSObjectProtocol {
    
    optional  func cancelAction(sender: UIButton?)
    
    
    optional  func sureAction(sender: UIButton?, targetCity: CityNameBaseInfo?)
    optional  func daysSureAction(sender:UIButton?, targetDays: Int)
    optional  func daysCancelAction(sender:UIButton?)
}

class CitysSelectorSheet: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate:CitysSelectorSheetDelegate?
//    var citysList:Array<CityInfo>?
    
//    var cityInfoModel:CityNameInfoModel?
    var citysList:CityNameInfoModel?
    var targetCity:CityNameBaseInfo?
    
//    var targetCity:CityInfo?
    
    let pickView = UIPickerView()
    var daysList:Array<Int>?
    var targetDays:Int = 1
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
        let bgView = UIImageView()
        bgView.backgroundColor = UIColor.whiteColor()
        bgView.userInteractionEnabled = true
        addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.left.equalTo(self).offset(-10)
            make.right.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(10)
            make.top.equalTo(self)
        }
        
        let head = UIView()
        head.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        head.userInteractionEnabled = true
        addSubview(head)
        head.snp_makeConstraints { (make) in
            make.left.equalTo(bgView)
            make.right.equalTo(bgView)
            make.top.equalTo(bgView)
            make.height.equalTo(40)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消", forState: .Normal)
        cancelBtn.backgroundColor = UIColor.clearColor()
        cancelBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cancelBtn.addTarget(self, action: #selector(ServiceSheet.cancelAction(_:)), forControlEvents: .TouchUpInside)
        head.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) in
            make.left.equalTo(head)
            make.right.equalTo(head.snp_centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        let sureBtn = UIButton()
        sureBtn.setTitle("确定", forState: .Normal)
        sureBtn.backgroundColor = UIColor.clearColor()
        sureBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        sureBtn.addTarget(self, action: #selector(ServiceSheet.sureAction(_:)), forControlEvents: .TouchUpInside)
        head.addSubview(sureBtn)
        sureBtn.snp_makeConstraints { (make) in
            make.right.equalTo(head)
            make.left.equalTo(head.snp_centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        let body = UIView()
        body.backgroundColor = UIColor.clearColor()
        body.userInteractionEnabled = true
        addSubview(body)
        body.snp_makeConstraints { (make) in
            make.left.equalTo(bgView).offset(48)
            make.right.equalTo(bgView).offset(-48)
            make.top.equalTo(head.snp_bottom).offset(28)
            make.bottom.equalTo(bgView).offset(-38)
        }
        
        pickView.delegate = self
        pickView.dataSource = self
        pickView.backgroundColor = UIColor.clearColor()
        body.addSubview(pickView)
        pickView.snp_makeConstraints { (make) in
            make.left.equalTo(body)
            make.right.equalTo(body)
            make.top.equalTo(body)
            make.height.equalTo(180)
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.clearColor()
        body.addSubview(bottomView)
        bottomView.snp_makeConstraints { (make) in
            make.left.equalTo(body)
            make.right.equalTo(body)
            make.top.equalTo(pickView.snp_bottom)
            make.bottom.equalTo(body)
        }
    }
    
    //MARK: - UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
//        let count = citysList?.count ?? daysList?.count
        let count = citysList!.service_city_.count
        return count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
        if daysList == nil {
            
            let cityInfo = citysList!.service_city_[row]
            
            return cityInfo.cityName
        }
        let daysCount = daysList![row]
        
        return String(daysCount) + "天"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if daysList == nil  {
            
            for (index, city) in citysList!.service_city_.enumerate() {
                if index == row {
                    targetCity = city
                    return
                }
            }
        } else {
            targetDays = daysList![row]
        }
    }
    
    func cancelAction(sender: UIButton?) {
        guard delegate != nil else {
            XCGLogger.error("delegate 为空")
            return
        }
        if daysList == nil  {
            delegate?.cancelAction!(sender)
        }else {
            delegate?.daysCancelAction!(sender)
        }
    }
    
    func sureAction(sender: UIButton?) {
        guard delegate != nil else {
            XCGLogger.error("delegate 为空")
            return
        }
        if daysList == nil {

            
            delegate?.sureAction!(sender, targetCity: targetCity ?? self.citysList!.service_city_[0])
        } else {
        
            
            delegate?.daysSureAction!(sender, targetDays: targetDays)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}