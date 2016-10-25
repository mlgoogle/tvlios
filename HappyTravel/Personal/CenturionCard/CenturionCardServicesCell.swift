//
//  CenturionCardServicesCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/13.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift


protocol CenturionCardServicesCellDelegate : NSObjectProtocol {
    
    func serviceTouched(service: CenturionCardServiceInfo)
    
}

class CenturionCardServicesCell : UITableViewCell {
    
    weak var delegate:CenturionCardServicesCellDelegate?
    
    let tags = ["serviceBtn": 1001,
                "buyNowBtn": 1002]
    
    let centurionCardTitle = [0: "初级会员",
                              1: "中级会员",
                              2: "高级会员"]
    
    let centurionCardIcon = [0: [0: "primary-level-disable", 1: "primary-level"],
                             1: [0: "middle-level-disable", 1: "middle-level"],
                             2: [0: "advanced-level-disable", 1: "advanced-level"]]
    
    var servicesViews:Array<UIView> = []
    
    var services:Results<CenturionCardServiceInfo>?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.whiteColor()
        backgroundColor = UIColor.whiteColor()

    }
    
    func setInfo(services: Results<CenturionCardServiceInfo>?) {
        self.services = services
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        for (index, service) in self.services!.enumerate() {
            var serviceBtn = contentView.viewWithTag(tags["serviceBtn"]! * 10 + index) as? UIButton
            if serviceBtn == nil {
                serviceBtn = UIButton()
                serviceBtn?.tag = tags["serviceBtn"]! * 10 + index
                serviceBtn?.backgroundColor = UIColor.clearColor()
                serviceBtn?.addTarget(self, action: #selector(CenturionCardServicesCell.serviceTouched(_:)), forControlEvents: .TouchUpInside)
                contentView.addSubview(serviceBtn!)
                serviceBtn?.snp_makeConstraints(closure: { (make) in
                    if let _ = contentView.viewWithTag(tags["serviceBtn"]! * 10 + index - 1) as? UIButton {
                        if index / 4 == 0 {
                            make.top.equalTo(contentView).offset(20)
                        } else {
                            make.top.equalTo(contentView).offset(20 + (80 + 10) * (CGFloat(index) / 4.0))
                        }
                        if index % 4 == 0 {
                            make.left.equalTo(contentView).offset(40)
                        } else {
                            let space = (UIScreen.mainScreen().bounds.size.width - 60 * 4 - 40 * 2) / 3.0
                            make.left.equalTo(contentView).offset(40 + (60 + space) * (CGFloat(index) % 4))
                        }
                    } else {
                        make.top.equalTo(contentView).offset(20)
                        make.left.equalTo(contentView).offset(40)
                    }
                    make.width.equalTo(60)
                    make.height.equalTo(60)
                    
                })
                
            }
            let url = service.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ? service.privilege_pic_yes_ : service.privilege_pic_no_
            serviceBtn?.kf_setBackgroundImageWithURL(NSURL(string: url!), forState: .Normal, placeholderImage: UIImage.init(named: "face-btn"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
            
            var titleLab = serviceBtn?.viewWithTag(serviceBtn!.tag * 100 + index) as? UILabel
            if titleLab == nil {
                titleLab = UILabel()
                titleLab?.tag = serviceBtn!.tag * 100 + index
                titleLab?.backgroundColor = UIColor.clearColor()
                titleLab?.font = UIFont.systemFontOfSize(16)
                titleLab?.textColor = UIColor.blackColor()
                serviceBtn?.addSubview(titleLab!)
                titleLab?.snp_makeConstraints(closure: { (make) in
                    make.centerX.equalTo(serviceBtn!)
                    make.height.equalTo(20)
                    make.top.equalTo(serviceBtn!.snp_bottom)
                    if index == self.services!.count - 1 && index < DataManager.currentUser!.centurionCardLv {
                        make.bottom.equalTo(contentView).offset(-20)
                    }
                })
            }
            titleLab?.text = service.privilege_name_!
            titleLab?.textColor = service.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ? UIColor.blackColor() : UIColor.grayColor()
            
            if index == self.services!.count - 1 && index >= DataManager.currentUser!.centurionCardLv {
                var buyNowBtn = contentView.viewWithTag(tags["buyNowBtn"]!) as? UIButton
                if buyNowBtn == nil {
                    buyNowBtn = UIButton()
                    buyNowBtn?.tag = tags["buyNowBtn"]! * 10 + index
                    buyNowBtn?.backgroundColor = UIColor.whiteColor()
                    buyNowBtn?.setTitle("购买此服务", forState: .Normal)
                    buyNowBtn?.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), forState: .Normal)
                    buyNowBtn?.layer.masksToBounds = true
                    buyNowBtn?.layer.cornerRadius = 5
                    buyNowBtn?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
                    buyNowBtn?.layer.borderWidth = 1
                    contentView.addSubview(buyNowBtn!)
                    buyNowBtn?.snp_makeConstraints(closure: { (make) in
                        make.centerX.equalTo(contentView)
                        make.top.equalTo(titleLab!.snp_bottom).offset(30)
                        make.bottom.equalTo(contentView).offset(-20)
                        make.width.equalTo(120)
                        make.height.equalTo(40)
                        
                    })
                }
            }
            
        }
    }
    
    func serviceTouched(sender: UIButton) {
        let index = sender.tag - tags["serviceBtn"]! * 10
        delegate?.serviceTouched(services![index])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
