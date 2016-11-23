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
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        
        var bgView = contentView.viewWithTag(tags["bgView"]!) as? UIImageView
        if bgView == nil {
            bgView = UIImageView()
            bgView!.tag = tags["bgView"]!
            bgView!.backgroundColor = UIColor.clear
            bgView!.isUserInteractionEnabled = true
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
            headView?.layer.cornerRadius = 80 / 2.0
            headView?.layer.masksToBounds = true
            headView?.layer.borderWidth = 1
            headView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 43/255.0, blue: 30/255.0, alpha: 1).cgColor
            headView!.isUserInteractionEnabled = true
            headView!.backgroundColor = UIColor.clear
            bgView!.addSubview(headView!)
            headView!.snp_makeConstraints { (make) in
                make.top.equalTo(bgView!).offset(36)
                make.centerX.equalTo(bgView!)
                make.height.equalTo(80)
                make.width.equalTo(80)
            }
        }
        headView?.image = UIImage.init(named: "default-head")
        
        var levelLabel = bgView?.viewWithTag(tags["levelLabel"]!) as? UILabel
        if levelLabel == nil {
            levelLabel = UILabel()
            levelLabel?.tag = tags["levelLabel"]!
            levelLabel?.backgroundColor = UIColor.clear
            levelLabel?.textAlignment = .center
            levelLabel?.textColor = UIColor.white
            levelLabel?.font = UIFont.boldSystemFont(ofSize: S15)
            bgView?.addSubview(levelLabel!)
            levelLabel?.snp_makeConstraints({ (make) in
                make.centerX.equalTo(bgView!)
                make.top.equalTo(headView!.snp_bottom).offset(19)
            })
        }
        levelLabel?.text = "会员卡等级"
        
        var nicknameLabel = bgView?.viewWithTag(tags["nicknameLabel"]!) as? UILabel
        if nicknameLabel == nil {
            nicknameLabel = UILabel()
            nicknameLabel?.tag = tags["nicknameLabel"]!
            nicknameLabel?.backgroundColor = UIColor.clear
            nicknameLabel?.textAlignment = .center
            nicknameLabel?.textColor = .white
            nicknameLabel?.font = UIFont.boldSystemFont(ofSize: S15)
            bgView?.addSubview(nicknameLabel!)
            nicknameLabel?.snp_makeConstraints({ (make) in
                make.centerX.equalTo(bgView!)
                make.top.equalTo(levelLabel!.snp_bottom).offset(7)
                make.bottom.equalTo(bgView!).offset(-33)
            })
        }
        nicknameLabel?.text = "用户昵称"
        
    }
    
    func setInfo(_ userInfo: UserInfo?) {
        if let bgView = contentView.viewWithTag(tags["bgView"]!) {
            if let headView: UIImageView = bgView.viewWithTag(tags["headView"]!) as? UIImageView {
                if let photoUrl = URL(string: (userInfo?.headUrl!)! == nil ? "" : (userInfo?.headUrl!)!) {
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
