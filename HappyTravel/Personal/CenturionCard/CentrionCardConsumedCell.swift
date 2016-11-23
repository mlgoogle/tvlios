//
//  CentrionCardConsumedCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/20.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation


class CentrionCardConsumedCell: UITableViewCell {
    
    var dateFormatter = DateFormatter()
    
    let tags = ["headImageView": 1001,
                "serviceTitleLab": 1002,
                "costLab": 1003,
                "timeLab": 1004,
                "bgView": 1005,
                "subTitle": 1006]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        var bgView = contentView.viewWithTag(tags["bgView"]!)
        if bgView == nil {
            bgView = UIView()
            bgView!.tag = tags["bgView"]!
            bgView?.backgroundColor = UIColor.white
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
            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            headImageView!.isUserInteractionEnabled = true
            headImageView!.backgroundColor = UIColor.clear
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
            serviceTitleLab?.backgroundColor = UIColor.clear
            serviceTitleLab?.textAlignment = .left
            serviceTitleLab?.textColor = UIColor.black
            serviceTitleLab?.font = UIFont.systemFont(ofSize: S15)
            contentView.addSubview(serviceTitleLab!)
            serviceTitleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(headImageView!.snp_right).offset(10)
                make.top.equalTo(headImageView!)
            })
        }
        
        var costLab = contentView.viewWithTag(tags["costLab"]!) as? UILabel
        if costLab == nil {
            costLab = UILabel()
            costLab?.tag = tags["costLab"]!
            costLab?.backgroundColor = UIColor.clear
            costLab?.textAlignment = .right
            costLab?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
            costLab?.font = UIFont.systemFont(ofSize: S15)
            contentView.addSubview(costLab!)
            costLab?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(contentView).offset(-14)
                make.center.equalTo(contentView)
            })
        }
        
        var subTitleLab = contentView.viewWithTag(tags["subTitle"]!) as? UILabel
        if subTitleLab == nil {
            subTitleLab = UILabel()
            subTitleLab?.tag = tags["subTitle"]!
            subTitleLab?.backgroundColor = UIColor.clear
            subTitleLab?.textAlignment = .left
            subTitleLab?.textColor = UIColor.gray
            subTitleLab?.font = UIFont.systemFont(ofSize: S13)
            subTitleLab?.text = "二星会员"
            contentView.addSubview(subTitleLab!)
            subTitleLab?.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(serviceTitleLab!.snp_bottom).offset(8)
                make.left.equalTo(serviceTitleLab!)
                make.height.equalTo(S13)
            })
        }
        
        var timeLab = contentView.viewWithTag(tags["timeLab"]!) as? UILabel
        if timeLab == nil {
            timeLab = UILabel()
            timeLab?.tag = tags["timeLab"]!
            timeLab?.backgroundColor = UIColor.clear
            timeLab?.textAlignment = .left
            timeLab?.textColor = UIColor.gray
//            timeLab?.text = "2016-11-11"
            timeLab?.font = UIFont.systemFont(ofSize: S13)
            contentView.addSubview(timeLab!)
            timeLab?.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(subTitleLab!.snp_bottom).offset(4)
                make.left.equalTo(serviceTitleLab!)
                make.bottom.equalTo(bgView!).offset(-14)
            })
        }
        
    }
    
    func setCenturionCardConsumedInfo(_ info: CenturionCardConsumedInfo?) {
        if let headImageView = contentView.viewWithTag(tags["headImageView"]!) as? UIImageView {
            headImageView.kf_setImageWithURL(URL(string:  info!.privilege_pic_!), placeholderImage: UIImage.init(named: "default-head"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
            
        }
        
        if let serviceTitleLab = contentView.viewWithTag(tags["serviceTitleLab"]!) as? UILabel {
            serviceTitleLab.text = info!.privilege_name_!
        }
        
        if let costLab = contentView.viewWithTag(tags["costLab"]!) as? UILabel {
            costLab.text = "\(Double(info!.privilege_price_) / 100)￥"
        }
        
        if let subTitle = contentView.viewWithTag(tags["subTitle"]!) as? UILabel {
            let formatter = NumberFormatter.init()
            formatter.roundingMode = .halfDown
            formatter.numberStyle = .spellOut
            let lvNum = NSNumber.init(value: info!.privilege_lv_ as Int)
            let lvStr = formatter.string(from: lvNum)
            subTitle.text = "\(lvStr!)星黑卡消费"
        }
        
        if let timeLab = contentView.viewWithTag(tags["timeLab"]!) as? UILabel {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            timeLab.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(info!.order_time_)))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
