//
//  DistanceOfTravelCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/25.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class DistanceOfTravelCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
        
        var view = contentView.viewWithTag(101)
        if view == nil {
            view = UIView()
            view!.tag = 101
            view?.backgroundColor = UIColor.whiteColor()
            view?.layer.cornerRadius = 5
            view?.layer.masksToBounds = true
            contentView.addSubview(view!)
            view?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView)
            })
        }
        
        var headImageView = view?.viewWithTag(1001) as? UIImageView
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = 1001
            headImageView?.layer.cornerRadius = 45 / 2.0
            headImageView?.layer.masksToBounds = true
            headImageView?.layer.borderWidth = 1
            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
            headImageView!.userInteractionEnabled = true
            headImageView!.backgroundColor = UIColor.clearColor()
            view!.addSubview(headImageView!)
            headImageView!.snp_makeConstraints { (make) in
                make.left.equalTo(view!).offset(14)
                make.top.equalTo(view!).offset(13)
                make.height.equalTo(45)
                make.width.equalTo(45)
            }
        }
        
        var nickNameLab = view?.viewWithTag(1002) as? UILabel
        if nickNameLab == nil {
            nickNameLab = UILabel()
            nickNameLab?.tag = 1002
            nickNameLab?.backgroundColor = UIColor.clearColor()
            nickNameLab?.textAlignment = .Left
            nickNameLab?.font = UIFont.systemFontOfSize(15)
            view?.addSubview(nickNameLab!)
            nickNameLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(headImageView!.snp_right).offset(10)
                make.top.equalTo(view!).offset(16)
            })
        }
        
        var serviceTitleLab = view? .viewWithTag(1003) as? UILabel
        if serviceTitleLab == nil {
            serviceTitleLab = UILabel()
            serviceTitleLab?.tag = 1003
            serviceTitleLab?.backgroundColor = UIColor.clearColor()
            serviceTitleLab?.textAlignment = .Left
            serviceTitleLab?.textColor = UIColor.blackColor()
            serviceTitleLab?.font = UIFont.systemFontOfSize(15)
            view?.addSubview(serviceTitleLab!)
            serviceTitleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(nickNameLab!)
                make.top.equalTo(nickNameLab!.snp_bottom).offset(9)
            })
        }
        
        var payLab = view? .viewWithTag(1004) as? UILabel
        if payLab == nil {
            payLab = UILabel()
            payLab?.tag = 1004
            payLab?.backgroundColor = UIColor.clearColor()
            payLab?.textAlignment = .Right
            payLab?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
            payLab?.font = UIFont.systemFontOfSize(15)
            view?.addSubview(payLab!)
            payLab?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(view!).offset(-14)
                make.top.equalTo(serviceTitleLab!)
            })
        }
        
        var timeLab = view?.viewWithTag(1005) as? UILabel
        if timeLab == nil {
            timeLab = UILabel()
            timeLab?.tag = 1005
            timeLab?.backgroundColor = UIColor.clearColor()
            timeLab?.textAlignment = .Left
            timeLab?.textColor = UIColor.grayColor()
            timeLab?.font = UIFont.systemFontOfSize(13)
            view?.addSubview(timeLab!)
            timeLab?.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(serviceTitleLab!.snp_bottom).offset(11)
                make.left.equalTo(nickNameLab!)
                make.bottom.equalTo(view!).offset(-14)
            })
        }
        
        var statusLab = view? .viewWithTag(1006) as? UILabel
        if statusLab == nil {
            statusLab = UILabel()
            statusLab?.tag = 1006
            statusLab?.backgroundColor = UIColor.clearColor()
            statusLab?.textAlignment = .Right
            statusLab?.textColor = UIColor.init(red: 245/255.0, green: 146/255.0, blue: 49/255.0, alpha: 1)
            statusLab?.font = UIFont.systemFontOfSize(15)
            view?.addSubview(statusLab!)
            statusLab?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(payLab!)
                make.top.equalTo(timeLab!)
            })
        }
        
    }
    
    func setInfo(userInfo: UserInfo?) {
        let view = contentView.viewWithTag(101)
        if let headView = view!.viewWithTag(1001) as? UIImageView {
            headView.kf_setImageWithURL(NSURL(string: "http://www.mmonly.cc/gqbz/dmbz/11072_2.html"), placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                
            }
        }
        
        if let nickNameLab = view!.viewWithTag(1002) as? UILabel {
            nickNameLab.text = "PAPI酱"
        }
        
        if let serviceTitleLab = view!.viewWithTag(1003) as? UILabel {
            serviceTitleLab.text = "【全天服务】"
        }
        
        if let payLab = view!.viewWithTag(1004) as? UILabel {
            payLab.text = "1024.00"
        }
        
        if let timeLab = view!.viewWithTag(1005) as? UILabel {
            timeLab.text = "11:11"
        }
        
        if let statusLab = view!.viewWithTag(1006) as? UILabel {
            statusLab.text = "已接单"
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
