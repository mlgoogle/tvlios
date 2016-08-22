//
//  ServiceSheet.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/16.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

protocol ServiceSheetDelegate : NSObjectProtocol {
    
    func cancelAction(sender: UIButton?)
    
    func sureAction(sender: UIButton?)
    
}

class ServiceSheet: UIView {
    
    weak var delegate:ServiceSheetDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
        let bgView = UIView()
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
        
        for i in 0...3 {
            let btn = UIButton()
            btn.tag = 1001 + i
            btn.setBackgroundImage(UIImage.init(named: "service-unselect"), forState: .Normal)
            btn.setBackgroundImage(UIImage.init(named: "service-selected"), forState: .Selected)
            btn.backgroundColor = UIColor.clearColor()
            body.addSubview(btn)
            btn.snp_makeConstraints { (make) in
                make.left.equalTo(body)
                if i == 0 {
                    make.top.equalTo(body)
                    btn.selected = true
                } else {
                    make.top.equalTo((body.viewWithTag(1001 + i - 1) as? UIButton)!.snp_bottom).offset(30)
                }
                if i == 3 - 1 {
                    make.bottom.equalTo(body)
                } else {
                    make.height.equalTo(20)
                }
                make.width.equalTo(20)
            }
            
            let pay = UILabel()
            pay.backgroundColor = UIColor.clearColor()
            pay.textAlignment = .Right
            pay.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            pay.font = UIFont.systemFontOfSize(15)
            body.addSubview(pay)
            pay.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(body)
                make.top.equalTo(btn)
                make.bottom.equalTo(btn)
            })
            pay.text = "1200元"
            
            let time = UILabel()
            time.backgroundColor = UIColor.clearColor()
            time.textAlignment = .Left
            time.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            time.font = UIFont.systemFontOfSize(15)
            body.addSubview(time)
            time.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(btn.snp_right).offset(37)
                make.right.equalTo(pay.snp_left)
                make.top.equalTo(btn)
                make.bottom.equalTo(btn)
            })
            time.text = "全天     08:00-24:00"
        }
    }
    
    func cancelAction(sender: UIButton?) {
        delegate?.cancelAction(sender)
    }
    
    func sureAction(sender: UIButton?) {
        delegate?.sureAction(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
