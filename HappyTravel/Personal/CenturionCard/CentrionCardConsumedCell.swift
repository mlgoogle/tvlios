//
//  CentrionCardConsumedCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/20.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation


class CentrionCardConsumedCell: UITableViewCell {
    
    var dateFormatter = NSDateFormatter()
    
    let tags = ["headImageView": 1001,
                "serviceTitleLab": 1002,
                "costLab": 1003,
                "timeLab": 1004,
                "bgView": 1005]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
        
        var bgView = contentView.viewWithTag(tags["bgView"]!)
        if bgView == nil {
            bgView = UIView()
            bgView!.tag = tags["bgView"]!
            bgView?.backgroundColor = UIColor.whiteColor()
            bgView?.layer.cornerRadius = 5
            bgView?.layer.masksToBounds = true
            contentView.addSubview(bgView!)
            bgView?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView)
            })
        }
        
        var headImageView = contentView.viewWithTag(tags["headImageView"]!) as? UIImageView
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = tags["headImageView"]!
            headImageView?.layer.cornerRadius = 45 / 2.0
            headImageView?.layer.masksToBounds = true
            headImageView?.layer.borderWidth = 1
            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
            headImageView!.userInteractionEnabled = true
            headImageView!.backgroundColor = UIColor.clearColor()
            contentView.addSubview(headImageView!)
            headImageView!.snp_makeConstraints { (make) in
                make.left.equalTo(bgView!).offset(14)
                make.top.equalTo(bgView!).offset(13)
                make.height.equalTo(45)
                make.width.equalTo(45)
            }
        }
        
        var serviceTitleLab = contentView .viewWithTag(tags["serviceTitleLab"]!) as? UILabel
        if serviceTitleLab == nil {
            serviceTitleLab = UILabel()
            serviceTitleLab?.tag = tags["serviceTitleLab"]!
            serviceTitleLab?.backgroundColor = UIColor.clearColor()
            serviceTitleLab?.textAlignment = .Left
            serviceTitleLab?.textColor = UIColor.blackColor()
            serviceTitleLab?.font = UIFont.systemFontOfSize(15)
            contentView.addSubview(serviceTitleLab!)
            serviceTitleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(headImageView!.snp_right).offset(10)
                make.top.equalTo(headImageView!).offset(10)
            })
        }
        
        var costLab = contentView.viewWithTag(tags["costLab"]!) as? UILabel
        if costLab == nil {
            costLab = UILabel()
            costLab?.tag = tags["costLab"]!
            costLab?.backgroundColor = UIColor.clearColor()
            costLab?.textAlignment = .Right
            costLab?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
            costLab?.font = UIFont.systemFontOfSize(15)
            contentView.addSubview(costLab!)
            costLab?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(contentView).offset(-14)
                make.top.equalTo(serviceTitleLab!)
            })
        }
        
        var timeLab = contentView.viewWithTag(tags["timeLab"]!) as? UILabel
        if timeLab == nil {
            timeLab = UILabel()
            timeLab?.tag = tags["timeLab"]!
            timeLab?.backgroundColor = UIColor.clearColor()
            timeLab?.textAlignment = .Left
            timeLab?.textColor = UIColor.grayColor()
            timeLab?.font = UIFont.systemFontOfSize(13)
            contentView.addSubview(timeLab!)
            timeLab?.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(serviceTitleLab!.snp_bottom).offset(11)
                make.left.equalTo(serviceTitleLab!)
                make.bottom.equalTo(bgView!).offset(-14)
            })
        }
        
    }
    
    func setCenturionCardConsumedInfo(info: CenturionCardConsumedInfo?) {
        if let headImageView = contentView.viewWithTag(tags["headImageView"]!) as? UIImageView {
            headImageView.kf_setImageWithURL(NSURL(string:  info!.privilege_pic_!), placeholderImage: UIImage.init(named: "default-head"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
            
        }
        
        if let serviceTitleLab = contentView.viewWithTag(tags["serviceTitleLab"]!) as? UILabel {
            serviceTitleLab.text = info!.privilege_name_!
        }
        
        if let costLab = contentView.viewWithTag(tags["costLab"]!) as? UILabel {
            costLab.text = "\(info!.privilege_price_)￥"
        }
        
        if let timeLab = contentView.viewWithTag(1005) as? UILabel {
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            timeLab.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(1476955731)))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}