//
//  ServantIntroCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/22.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class ServantIntroCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        
        let width = UIScreen.mainScreen().bounds.size.width
        
        var view = contentView.viewWithTag(101)
        if view == nil {
            view = UIView()
            view!.tag = 101
            contentView.addSubview(view!)
            view?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView)
                make.top.equalTo(contentView)
                make.right.equalTo(contentView)
                make.bottom.equalTo(contentView)
            })
        }
        
        var personalView = view?.viewWithTag(1001) as? UIImageView
        if personalView == nil {
            personalView = UIImageView()
            personalView!.tag = 1001
            personalView!.backgroundColor = UIColor.redColor()
            personalView!.userInteractionEnabled = true
            view!.addSubview(personalView!)
            personalView!.snp_makeConstraints { (make) in
                make.top.equalTo(view!)
                make.left.equalTo(view!)
                make.width.equalTo(width)
                make.height.equalTo(width / 3.0 * 2.0)
            }
        }
        
        var headImageView = personalView?.viewWithTag(10001) as? UIImageView
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = 10001
            headImageView?.layer.cornerRadius = width / 7.0
            headImageView?.layer.masksToBounds = true
            headImageView?.layer.borderWidth = 1
            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
            headImageView!.userInteractionEnabled = true
            headImageView!.backgroundColor = UIColor.clearColor()
            personalView!.addSubview(headImageView!)
            headImageView!.snp_makeConstraints { (make) in
                make.left.equalTo(personalView!).offset(25)
                make.centerY.equalTo(personalView!)
                make.height.equalTo(width / 7.0 * 2.0)
                make.width.equalTo(width / 7.0 * 2.0)
            }
        }
        
        var starLevelView = personalView?.viewWithTag(10002)
        if starLevelView == nil {
            starLevelView = UIView()
            starLevelView!.tag = 10002
            starLevelView?.backgroundColor = UIColor.clearColor()
            personalView!.addSubview(starLevelView!)
            starLevelView?.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(headImageView!.snp_bottom).offset(20)
                make.centerX.equalTo(headImageView!).offset(10)
                make.width.equalTo(width / 3.0 + 20)
                make.height.equalTo(20)
            })
            for i in 0...4 {
                var star = starLevelView?.viewWithTag(starLevelView!.tag * 10 + i) as? UIImageView
                if star == nil {
                    star = UIImageView()
                    star?.tag = starLevelView!.tag * 10 + i
                    star?.backgroundColor = UIColor.clearColor()
                    starLevelView?.addSubview(star!)
                    star?.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(starLevelView!.snp_left).offset(((width / 3.0 + 20) / 5.0) * CGFloat(i))
                        make.centerY.equalTo(starLevelView!)
                        make.width.equalTo(20)
                        make.height.equalTo(20)
                        
                    })
                    star?.image = UIImage.init(named: i > 3 ? "guide-star-hollow": "guide-star-fill")
                }
            }
        }
        
        var officialAuth = personalView?.viewWithTag(10003) as? UIImageView
        if officialAuth == nil {
            officialAuth = UIImageView()
            officialAuth?.tag = 10003
            officialAuth?.backgroundColor = UIColor.clearColor()
            officialAuth?.contentMode = .ScaleAspectFit
            personalView?.addSubview(officialAuth!)
            officialAuth?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(personalView!).offset(20)
                make.top.equalTo(personalView!).offset(20)
                make.width.equalTo(20)
                make.height.equalTo(20)
            })
        }
        officialAuth?.image = UIImage.init(named: "guide-auth")
        
        var zhimaAuth = personalView?.viewWithTag(10004) as? UIImageView
        if zhimaAuth == nil {
            zhimaAuth = UIImageView()
            zhimaAuth?.tag = 10004
            zhimaAuth?.backgroundColor = UIColor.clearColor()
            zhimaAuth?.contentMode = .ScaleAspectFit
            personalView?.addSubview(zhimaAuth!)
            zhimaAuth?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(officialAuth!.snp_right).offset(10)
                make.top.equalTo(personalView!).offset(20)
                make.width.equalTo(20)
                make.height.equalTo(20)
            })
        }
        zhimaAuth?.image = UIImage.init(named: "guide-zhima-auth")
        
        var authTips = personalView?.viewWithTag(10005) as? UILabel
        if authTips == nil {
            authTips = UILabel()
            authTips?.tag = 10005
            authTips?.backgroundColor = UIColor.clearColor()
            authTips?.textAlignment = .Right
            authTips?.textColor = UIColor.init(red: 240/255.0, green: 140/255.0, blue: 30/255.0, alpha: 1)
            authTips?.font = UIFont.boldSystemFontOfSize(15)
            personalView?.addSubview(authTips!)
            authTips?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(personalView!).offset(-20)
                make.top.equalTo(personalView!).offset(20)
                make.height.equalTo(20)
            })
        }
        authTips?.text = "照片已认证"
        
        var bottomControl = view?.viewWithTag(10010)
        if bottomControl == nil {
            bottomControl = UIView()
            bottomControl!.tag = 10010
            bottomControl!.backgroundColor = UIColor.clearColor()
            view?.addSubview(bottomControl!)
            bottomControl?.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(personalView!.snp_bottom)
                make.bottom.equalTo(view!)
                make.left.equalTo(view!)
                make.right.equalTo(view!)
            })
        }
        
    }
    
    func setInfo(bigPhotoUrl: NSString?, headPhotoUrl: NSString?) {
        let view = contentView.viewWithTag(101)
        let imageView: UIImageView = view!.viewWithTag(1001) as! UIImageView
        let photoUrl = (bigPhotoUrl != nil) ? NSURL(string: bigPhotoUrl as! String) : nil
        imageView.kf_setImageWithURL(photoUrl, placeholderImage: UIImage(named: "default-big-photo"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            
        }
        let headUrl = (headPhotoUrl != nil) ? NSURL(string: headPhotoUrl as! String) : nil
        let headView = imageView.viewWithTag(10001) as! UIImageView
        headView.kf_setImageWithURL(headUrl, placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
