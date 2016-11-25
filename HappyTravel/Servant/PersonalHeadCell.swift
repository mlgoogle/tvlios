//
//  PersonalHeadCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/4.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class PersonalHeadCell : UITableViewCell {
    
    static var PI:Double = 3.1415926535898
    static var EARTH_R:Double = 6371.393000
    
    let tags = ["view": 1001,
                "personalView": 1002,
                "headImageView": 1003,
                "starLevelView": 1004,
                "officialAuth": 1005,
                "zhimaAuth": 1006,
                "authTips": 1007,
                "limitLab": 1008,
                "limitIcon": 1009]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        
        let width = UIScreen.main.bounds.size.width
        
        var view = contentView.viewWithTag(tags["view"]!)
        if view == nil {
            view = UIView()
            view!.tag = tags["view"]!
            contentView.addSubview(view!)
            view?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView)
                make.top.equalTo(contentView)
                make.right.equalTo(contentView)
                make.bottom.equalTo(contentView)
            })
        }
        
        var personalView = view?.viewWithTag(tags["personalView"]!) as? UIImageView
        if personalView == nil {
            personalView = UIImageView()
            personalView!.tag = tags["personalView"]!
            personalView!.backgroundColor = UIColor.red
            personalView!.isUserInteractionEnabled = true
            view!.addSubview(personalView!)
            personalView!.snp.makeConstraints { (make) in
                make.top.equalTo(view!)
                make.left.equalTo(view!)
                make.width.equalTo(width)
                make.height.equalTo(AtapteWidthValue(width) / 3.0 * 2.0)
                make.bottom.equalTo(view!)
            }
            personalView?.image = UIImage.init(named: "defaultBg1")
        }
        
        var headImageView = personalView?.viewWithTag(tags["headImageView"]!) as? UIImageView
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = tags["headImageView"]!
            headImageView?.layer.cornerRadius = AtapteWidthValue(100) / 2
            headImageView?.layer.masksToBounds = true
            headImageView?.layer.borderWidth = 1
            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            headImageView!.isUserInteractionEnabled = true
            headImageView!.backgroundColor = UIColor.clear
            personalView!.addSubview(headImageView!)
            headImageView!.snp.makeConstraints { (make) in
                make.left.equalTo(personalView!).offset(AtapteWidthValue(25))
                make.centerY.equalTo(personalView!)
                make.height.equalTo(AtapteWidthValue(100))
                make.width.equalTo(AtapteWidthValue(100))
            }
        }
        
        var starLevelView = personalView?.viewWithTag(tags["starLevelView"]!)
        if starLevelView == nil {
            starLevelView = UIView()
            starLevelView!.tag = tags["starLevelView"]!
            starLevelView?.backgroundColor = UIColor.clear
            personalView!.addSubview(starLevelView!)
            starLevelView?.snp.makeConstraints({ (make) in
                make.bottom.equalTo(personalView!).offset(AtapteWidthValue(-20))
                make.centerX.equalTo(headImageView!).offset(AtapteWidthValue(10))
                make.width.equalTo(AtapteWidthValue(width) / 3.0 + AtapteWidthValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
            for i in 0...4 {
                var star = starLevelView?.viewWithTag(starLevelView!.tag * 10 + i) as? UIImageView
                if star == nil {
                    star = UIImageView()
                    star?.tag = starLevelView!.tag * 10 + i
                    star?.backgroundColor = UIColor.clear
                    starLevelView?.addSubview(star!)
                    star?.snp.makeConstraints({ (make) in
                        make.left.equalTo(starLevelView!.snp.left).offset(((width / 3.0 + 20) / 5.0) * CGFloat(i))
                        make.centerY.equalTo(starLevelView!)
                        make.width.equalTo(AtapteWidthValue(20))
                        make.height.equalTo(AtapteHeightValue(20))
                        
                    })
                    star?.image = UIImage.init(named: i > 3 ? "guide-star-hollow": "guide-star-fill")
                }
            }
        }
        
        var officialAuth = personalView?.viewWithTag(tags["officialAuth"]!) as? UIImageView
        if officialAuth == nil {
            officialAuth = UIImageView()
            officialAuth?.tag = tags["officialAuth"]!
            officialAuth?.backgroundColor = UIColor.clear
            officialAuth?.contentMode = .scaleAspectFit
            personalView?.addSubview(officialAuth!)
            officialAuth?.snp.makeConstraints({ (make) in
                make.left.equalTo(personalView!).offset(AtapteWidthValue(20))
                make.top.equalTo(personalView!).offset(AtapteHeightValue(20))
                make.width.equalTo(AtapteWidthValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        officialAuth?.image = UIImage.init(named: "renzheng")
        
        var zhimaAuth = personalView?.viewWithTag(tags["zhimaAuth"]!) as? UIImageView
        if zhimaAuth == nil {
            zhimaAuth = UIImageView()
            zhimaAuth?.tag = tags["zhimaAuth"]!
            zhimaAuth?.backgroundColor = UIColor.clear
            zhimaAuth?.contentMode = .scaleAspectFit
            personalView?.addSubview(zhimaAuth!)
            zhimaAuth?.snp.makeConstraints({ (make) in
                make.left.equalTo(officialAuth!.snp.right).offset(AtapteWidthValue(10))
                make.top.equalTo(personalView!).offset(AtapteHeightValue(20))
                make.width.equalTo(AtapteWidthValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        zhimaAuth?.image = UIImage.init(named: "guide-zhima-auth")
        zhimaAuth?.isHidden = true
        
        var authTips = personalView?.viewWithTag(tags["authTips"]!) as? UILabel
        if authTips == nil {
            authTips = UILabel()
            authTips?.tag = tags["authTips"]!
            authTips?.backgroundColor = UIColor.clear
            authTips?.textAlignment = .right
            authTips?.textColor = UIColor.init(red: 240/255.0, green: 140/255.0, blue: 30/255.0, alpha: 1)
            authTips?.font = UIFont.boldSystemFont(ofSize: AtapteWidthValue(S15))
            personalView?.addSubview(authTips!)
            authTips?.snp.makeConstraints({ (make) in
                make.right.equalTo(personalView!).offset(AtapteWidthValue(-20))
                make.top.equalTo(personalView!).offset(AtapteHeightValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        authTips?.text = "照片已认证"
        
        var limitLab = personalView?.viewWithTag(tags["limitLab"]!) as? UILabel
        if limitLab == nil {
            limitLab = UILabel()
            limitLab?.tag = tags["limitLab"]!
            limitLab?.backgroundColor = UIColor.clear
            limitLab?.textAlignment = .right
            limitLab?.textColor = .white
            limitLab?.font = UIFont.boldSystemFont(ofSize: AtapteWidthValue(S15))
            personalView?.addSubview(limitLab!)
            limitLab?.snp.makeConstraints({ (make) in
                make.right.equalTo(personalView!).offset(AtapteWidthValue(-20))
                make.bottom.equalTo(personalView!).offset(AtapteHeightValue(-20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        limitLab?.text = "0 Km"
        
        var limitIcon = personalView?.viewWithTag(tags["limitIcon"]!) as? UIImageView
        if limitIcon == nil {
            limitIcon = UIImageView()
            limitIcon?.tag = tags["limitIcon"]!
            limitIcon?.backgroundColor = UIColor.clear
            limitIcon?.contentMode = .scaleAspectFit
            personalView?.addSubview(limitIcon!)
            limitIcon?.snp.makeConstraints({ (make) in
                make.right.equalTo(limitLab!.snp.left).offset(AtapteWidthValue(-5))
                make.bottom.equalTo(limitLab!)
                make.width.equalTo(AtapteWidthValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
            limitIcon?.image = UIImage.init(named: "limit")
        }

    }
    
    func setInfo(_ userInfo: UserInfo?, detailInfo: Dictionary<String, AnyObject>?) {
        let view = contentView.viewWithTag(tags["view"]!)
        
        if let personalView = view!.viewWithTag(tags["personalView"]!) as? UIImageView {
//            if userInfo?.bigBGPhotoUrl != nil {                
//                let photoUrl = NSURL(string: (userInfo?.bigBGPhotoUrl!)!)
//                personalView.kf_setImageWithURL(photoUrl, placeholderImage: UIImage(named: "default-big-photo"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
//                    
//                }
//            }
            
            if let headImageView = personalView.viewWithTag(tags["headImageView"]!) as? UIImageView {
                let headUrl = URL(string: userInfo!.headUrl!)
                headImageView.kf.setImage(with: headUrl, placeholder: UIImage(named: "default-head"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in

                }
            }
            
            if let starLevelView = personalView.viewWithTag(tags["starLevelView"]!) {
                let level = userInfo?.praiseLv
                for i in 0...4 {
                    if let star = starLevelView.viewWithTag(starLevelView.tag * 10 + i) as? UIImageView {
                        star.image = UIImage.init(named: (level! / Int(i+1) >= 1) ? "guide-star-fill" : "guide-star-hollow")
                    }
                }
            }
            
            if let officialAuth = personalView.viewWithTag(tags["officialAuth"]!) as? UIImageView {
                officialAuth.isHidden = !((userInfo?.certification)!)
            }
            
            if let limitLab = personalView.viewWithTag(tags["limitLab"]!) as? UILabel {
                let myLongitude = DataManager.currentUser!.gpsLocationLon
                let myLatitude = DataManager.currentUser!.gpsLocationLat
                let servantLongitude = userInfo?.gpsLocationLon
                let servantLatitude = userInfo?.gpsLocationLat
                limitLab.text = "\(String(format: "%.2f", CalcDistance(myLongitude, lat1: myLatitude, lon2: servantLongitude!, lat2: servantLatitude!))) Km"
            }
        }
        
        
    }
    
    func Angle2Radian(_ angle: Double) ->Double {
        return angle * PersonalHeadCell.PI / 180.0;
    }
    
    func CalcDistance(_ lon1: Double, lat1: Double, lon2: Double, lat2: Double) ->Double {
        let lat_a:Double = Angle2Radian(lat1)
        let lon_a:Double = Angle2Radian(lon1)
        let lat_b:Double = Angle2Radian(lat2)
        let lon_b:Double = Angle2Radian(lon2)
        return acos(sin(lat_a) * sin(lat_b) + cos(lat_a) * cos(lat_b) * cos(lon_a - lon_b)) * PersonalHeadCell.EARTH_R;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
