//
//  CenturionCardBaseInfoCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/13.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class CenturionCardBaseInfoCell : UITableViewCell {
    
    
    let tags = ["bgView": 1001,
                "headView": 1002,
                "levelLabel": 1003,
                "nicknameLabel": 1004]
    
    let centurionCardLv = [0: "未开通",
                           1: "一星会员",
                           2: "二星会员",
                           3: "三星会员"]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        
        var bgView = contentView.viewWithTag(tags["bgView"]!) as? UIImageView
        if bgView == nil {
            bgView = UIImageView()
            bgView!.tag = tags["bgView"]!
            bgView!.backgroundColor = UIColor.clearColor()
            bgView!.userInteractionEnabled = true
            bgView!.image = UIImage.init(named: "bg-baseinfo")
            contentView.addSubview(bgView!)
            bgView!.snp_makeConstraints { (make) in
                make.top.equalTo(contentView)
                make.left.equalTo(contentView)
                make.right.equalTo(contentView)
                make.bottom.equalTo(contentView)
            }
        }
        
        var headView = bgView?.viewWithTag(tags["headView"]!) as? UIImageView
        if headView == nil {
            headView = UIImageView()
            headView!.tag = tags["headView"]!
            headView?.layer.cornerRadius = AtapteWidthValue(80) / 2.0
            headView?.layer.masksToBounds = true
            headView?.layer.borderWidth = 1
            headView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 43/255.0, blue: 30/255.0, alpha: 1).CGColor
            headView!.userInteractionEnabled = true
            headView!.backgroundColor = UIColor.clearColor()
            bgView!.addSubview(headView!)
            headView!.snp_makeConstraints { (make) in
                make.top.equalTo(bgView!).offset(AtapteWidthValue(36))
                make.centerX.equalTo(bgView!)
                make.height.equalTo(AtapteWidthValue(80))
                make.width.equalTo(AtapteWidthValue(80))
            }
        }
        headView?.image = UIImage.init(named: "default-head")
        
        var levelLabel = bgView?.viewWithTag(tags["levelLabel"]!) as? UILabel
        if levelLabel == nil {
            levelLabel = UILabel()
            levelLabel?.tag = tags["levelLabel"]!
            levelLabel?.backgroundColor = UIColor.clearColor()
            levelLabel?.textAlignment = .Center
            levelLabel?.textColor = UIColor.whiteColor()
            levelLabel?.font = UIFont.boldSystemFontOfSize(S15)
            bgView?.addSubview(levelLabel!)
            levelLabel?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(bgView!)
                make.top.equalTo(headView!.snp_bottom).offset(AtapteHeightValue(19))
            })
        }
        levelLabel?.text = "会员卡等级"
        
        var nicknameLabel = bgView?.viewWithTag(tags["nicknameLabel"]!) as? UILabel
        if nicknameLabel == nil {
            nicknameLabel = UILabel()
            nicknameLabel?.tag = tags["nicknameLabel"]!
            nicknameLabel?.backgroundColor = UIColor.clearColor()
            nicknameLabel?.textAlignment = .Center
            nicknameLabel?.textColor = .whiteColor()
            nicknameLabel?.font = UIFont.boldSystemFontOfSize(S15)
            bgView?.addSubview(nicknameLabel!)
            nicknameLabel?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(bgView!)
                make.top.equalTo(levelLabel!.snp_bottom).offset(AtapteHeightValue(7))
            })
        }
        nicknameLabel?.text = "用户昵称"
        
    }
    
    func setInfo(userInfo: UserInfo?) {
        if let bgView = contentView.viewWithTag(tags["bgView"]!) {
            if let headView: UIImageView = bgView.viewWithTag(tags["headView"]!) as? UIImageView {
                if let photoUrl = NSURL(string: (userInfo?.headUrl!)! == nil ? "" : (userInfo?.headUrl!)!) {
                    headView.kf_setImageWithURL(photoUrl, placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                        
                    }
                }
                
            }
            
            if let levelLabel = bgView.viewWithTag(tags["levelLabel"]!) as? UILabel {
                levelLabel.text = centurionCardLv[userInfo!.centurionCardLv]
            }
            
            if let nicknameLabel = bgView.viewWithTag(tags["nicknameLabel"]!) as? UILabel {
                nicknameLabel.text = userInfo?.nickname!
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
