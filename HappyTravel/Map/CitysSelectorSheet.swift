//
//  CitysSelectorSheet.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/23.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

protocol CitysSelectorSheetDelegate : NSObjectProtocol {
    
    func cancelAction(sender: UIButton?)
    
    func sureAction(sender: UIButton?, targetCity: CityInfo?)
    
}

class CitysSelectorSheet: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate:CitysSelectorSheetDelegate?
    var citysList:Array<CityInfo>?
    var targetCity:CityInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
        let bgView = UIImageView()
        bgView.backgroundColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
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
        
        let pickView = UIPickerView()
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
        return citysList!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let cityInfo = citysList![row]
        
        return cityInfo.cityName
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        for (index, city) in citysList!.enumerate() {
            if index == row {
                targetCity = city
                return
            }
        }
    }
    
    func cancelAction(sender: UIButton?) {
        delegate?.cancelAction(sender)
    }
    
    func sureAction(sender: UIButton?) {
        delegate?.sureAction(sender, targetCity: targetCity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}