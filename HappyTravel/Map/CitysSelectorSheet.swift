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
    
    @objc optional  func cancelAction(sender: UIButton?)
    
    
    @objc optional  func sureAction(sender: UIButton?, targetCity: CityInfo?)
    @objc optional  func daysSureAction(sender:UIButton?, targetDays: Int)
    @objc optional  func daysCancelAction(sender:UIButton?)

}

class CitysSelectorSheet: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate:CitysSelectorSheetDelegate?
    var citysList:Array<CityInfo>?
    var targetCity:CityInfo?
    
    let pickView = UIPickerView()
    var daysList:Array<Int>?
    var targetDays:Int = 1
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
        let bgView = UIImageView()
        bgView.backgroundColor = UIColor.white
        bgView.isUserInteractionEnabled = true
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(-10)
            make.right.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(10)
            make.top.equalTo(self)
        }
        
        let head = UIView()
        head.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        head.isUserInteractionEnabled = true
        addSubview(head)
        head.snp.makeConstraints { (make) in
            make.left.equalTo(bgView)
            make.right.equalTo(bgView)
            make.top.equalTo(bgView)
            make.height.equalTo(40)
        }
        
        let cancelBtn = UIButton()

        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.backgroundColor = UIColor.clear
        cancelBtn.setTitleColor(UIColor.black
            , for: .normal)
        cancelBtn.addTarget(self, action: #selector(ServiceSheet.cancelAction(_:)), for: .TouchUpInside)
        head.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(head)
            make.right.equalTo(head.snp.centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        let sureBtn = UIButton()
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.backgroundColor = UIColor.clear
        sureBtn.setTitleColor(UIColor.black, for: .normal)
        sureBtn.addTarget(self, action: #selector(ServiceSheet.sureAction(_:)), for: .touchUpInside)
        head.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalTo(head)
            make.left.equalTo(head.snp.centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        let body = UIView()
        body.backgroundColor = UIColor.clear
        body.isUserInteractionEnabled = true
        addSubview(body)
        body.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(48)
            make.right.equalTo(bgView).offset(-48)
            make.top.equalTo(head.snp.bottom).offset(28)
            make.bottom.equalTo(bgView).offset(-38)
        }
        
        pickView.delegate = self
        pickView.dataSource = self
        pickView.backgroundColor = UIColor.clear
        body.addSubview(pickView)
        pickView.snp.makeConstraints { (make) in
            make.left.equalTo(body)
            make.right.equalTo(body)
            make.top.equalTo(body)
            make.height.equalTo(180)
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.clear
        body.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.equalTo(body)
            make.right.equalTo(body)
            make.top.equalTo(pickView.snp.bottom)
            make.bottom.equalTo(body)
        }
    }
    
    //MARK: - UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let count = citysList == nil ? daysList?.count : citysList?.count
        return count!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
        if daysList == nil {
            
            let cityInfo = citysList![row]
            
            return cityInfo.cityName
        }
        let daysCount = daysList![row]
        
        return String(daysCount) + "天"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if daysList == nil  {
            
            for (index, city) in citysList!.enumerated() {
                if index == row {
                    targetCity = city
                    return
                }
            }
        } else {
            targetDays = daysList![row]
        }
    }
    
    func cancelAction(_ sender: UIButton?) {
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
    
    func sureAction(_ sender: UIButton?) {
        guard delegate != nil else {
            XCGLogger.error("delegate 为空")
            return
        }
        if daysList == nil {

            
            delegate?.sureAction!(sender, targetCity: targetCity == nil ? self.citysList![0] : targetCity)
        } else {
        
            
            delegate?.daysSureAction!(sender, targetDays: targetDays)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
