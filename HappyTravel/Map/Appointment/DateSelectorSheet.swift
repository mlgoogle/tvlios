//
//  DateSelectorSheet.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/19.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

protocol DateSelectorSheetDelegate : NSObjectProtocol {
    
    func cancelAction()
    
    func sureAction(_ tag: Int, date: Date)
    
}

class DateSelectorSheet: UIView {
    
    weak var delegate:DateSelectorSheetDelegate?
    
    var datePicker:UIDatePicker?
    var date:Date?
    
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
        cancelBtn.setTitle("取消", for: UIControlState())
        cancelBtn.backgroundColor = UIColor.clear
        cancelBtn.setTitleColor(UIColor.black, for: UIControlState())
        cancelBtn.addTarget(self, action: #selector(ServiceSheet.cancelAction(_:)), for: .touchUpInside)
        head.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(head)
            make.right.equalTo(head.snp.centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        let sureBtn = UIButton()
        sureBtn.setTitle("确定", for: UIControlState())
        sureBtn.backgroundColor = UIColor.clear
        sureBtn.setTitleColor(UIColor.black, for: UIControlState())
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
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.minimumDate = Date.init(timeIntervalSinceNow: 3600 * 24)
        datePicker?.maximumDate = Date.init(timeIntervalSinceNow: 3600 * 24 * 30)
        body.addSubview(datePicker!)
        datePicker?.snp.makeConstraints { (make) in
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
            make.top.equalTo(datePicker!.snp.bottom)
            make.bottom.equalTo(body)
        }
    }
    
    func cancelAction(_ sender: UIButton?) {
        delegate?.cancelAction()
    }
    
    func sureAction(_ sender: UIButton?) {
        delegate?.sureAction(tag, date: datePicker!.date)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
