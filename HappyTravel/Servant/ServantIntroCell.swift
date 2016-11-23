//
//  ServantIntroCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/22.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
protocol ServantIntroCellDelegate : NSObjectProtocol {
    
    func chatAction(_ servantInfo: UserInfo?)
    
}

class ServantIntroCell: UITableViewCell {
    
    static var PI:Double = 3.1415926535898
    static var EARTH_R:Double = 6371.393000
    var allLabelWidth:Float = 10.0
    var servantInfo:UserInfo?
    weak var delegate:ServantIntroCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        
        let width = UIScreen.main.bounds.size.width
        
        var view = contentView.viewWithTag(101)
        if view == nil {
            view = UIView()
            view!.tag = 101
            view?.backgroundColor = UIColor.white
            view?.isUserInteractionEnabled = true
            contentView.addSubview(view!)
            view?.snp_makeConstraints({ (make) in
                make.left.equalTo(contentView)
                make.top.equalTo(contentView)
                make.right.equalTo(contentView)
                make.bottom.equalTo(contentView).offset(AtapteHeightValue(-10))
            })
        }
        
        var personalView = view?.viewWithTag(1001) as? UIImageView
        if personalView == nil {
            personalView = UIImageView()
            personalView!.tag = 1001
//            personalView!.backgroundColor = UIColor.redColor()
            personalView!.isUserInteractionEnabled = true
            view!.addSubview(personalView!)
            personalView!.snp_makeConstraints { (make) in
                make.top.equalTo(view!)
                make.left.equalTo(view!)
                make.width.equalTo(width)
                make.height.equalTo(AtapteHeightValue(width / 3.0 * 2.0 - 60))
            }
            personalView?.image = UIImage.init(named: "defaultBg1")
        }
        
        var headImageView = personalView?.viewWithTag(10001) as? UIImageView
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = 10001
            headImageView?.layer.cornerRadius = AtapteWidthValue(80) / 2
            headImageView?.layer.masksToBounds = true
            headImageView?.layer.borderWidth = 1
            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            headImageView!.isUserInteractionEnabled = true
            headImageView!.backgroundColor = UIColor.clear
            personalView!.addSubview(headImageView!)
            headImageView!.snp_makeConstraints { (make) in
                make.left.equalTo(personalView!).offset(AtapteWidthValue(25))
                make.bottom.equalTo(personalView!).offset(AtapteHeightValue(-20))
                make.height.equalTo(AtapteWidthValue(80))
                make.width.equalTo(AtapteWidthValue(80))
            }
        }
        
        var officialAuth = personalView?.viewWithTag(10003) as? UIImageView
        if officialAuth == nil {
            officialAuth = UIImageView()
            officialAuth?.tag = 10003
            officialAuth?.backgroundColor = UIColor.clear
            officialAuth?.contentMode = .scaleAspectFit
            personalView?.addSubview(officialAuth!)
            officialAuth?.snp_makeConstraints({ (make) in
                make.left.equalTo(personalView!).offset(AtapteWidthValue(20))
                make.top.equalTo(personalView!).offset(AtapteHeightValue(20))
                make.width.equalTo(AtapteWidthValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        officialAuth?.image = UIImage.init(named: "renzheng")
        
        var zhimaAuth = personalView?.viewWithTag(10004) as? UIImageView
        if zhimaAuth == nil {
            zhimaAuth = UIImageView()
            zhimaAuth?.tag = 10004
            zhimaAuth?.backgroundColor = UIColor.clear
            zhimaAuth?.contentMode = .scaleAspectFit
            personalView?.addSubview(zhimaAuth!)
            zhimaAuth?.snp_makeConstraints({ (make) in
                make.left.equalTo(officialAuth!.snp_right).offset(AtapteWidthValue(10))
                make.top.equalTo(personalView!).offset(AtapteHeightValue(20))
                make.width.equalTo(AtapteWidthValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        zhimaAuth?.image = UIImage.init(named: "guide-zhima-auth")
        
        var authTips = personalView?.viewWithTag(10005) as? UILabel
        if authTips == nil {
            authTips = UILabel()
            authTips?.tag = 10005
            authTips?.backgroundColor = UIColor.clear
            authTips?.textAlignment = .right
            authTips?.textColor = UIColor.init(red: 240/255.0, green: 140/255.0, blue: 30/255.0, alpha: 1)
            authTips?.font = UIFont.boldSystemFont(ofSize: S15)
            personalView?.addSubview(authTips!)
            authTips?.snp_makeConstraints({ (make) in
                make.right.equalTo(personalView!).offset(AtapteWidthValue(-20))
                make.top.equalTo(personalView!).offset(AtapteHeightValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        authTips?.text = "照片已认证"
        
        var limitLab = personalView?.viewWithTag(10006) as? UILabel
        if limitLab == nil {
            limitLab = UILabel()
            limitLab?.tag = 10006
            limitLab?.backgroundColor = UIColor.clear
            limitLab?.textAlignment = .right
            limitLab?.textColor = .white
            limitLab?.font = UIFont.boldSystemFont(ofSize: S15)
            personalView?.addSubview(limitLab!)
            limitLab?.snp_makeConstraints({ (make) in
                make.right.equalTo(personalView!).offset(AtapteWidthValue(-20))
                make.bottom.equalTo(personalView!).offset(AtapteHeightValue(-20))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        limitLab?.text = "0 Km"
        
        var limitIcon = personalView?.viewWithTag(10007) as? UIImageView
        if limitIcon == nil {
            limitIcon = UIImageView()
            limitIcon?.tag = 10007
            limitIcon?.backgroundColor = UIColor.clear
            limitIcon?.contentMode = .scaleAspectFit
            personalView?.addSubview(limitIcon!)
            limitIcon?.snp_makeConstraints({ (make) in
                make.right.equalTo(limitLab!.snp_left).offset(AtapteWidthValue(-5))
                make.bottom.equalTo(limitLab!)
                make.width.equalTo(AtapteWidthValue(20))
                make.height.equalTo(AtapteHeightValue(20))
            })
            limitIcon?.image = UIImage.init(named: "limit")
        }
        
        var nickNameLab = view!.viewWithTag(2001) as? UILabel
        if nickNameLab == nil {
            nickNameLab = UILabel()
            nickNameLab?.tag = 2001
            nickNameLab?.backgroundColor = UIColor.clear
            nickNameLab?.textAlignment = .left
            nickNameLab?.textColor = .black
            nickNameLab?.font = UIFont.boldSystemFont(ofSize: S15)
            view?.addSubview(nickNameLab!)
            nickNameLab?.snp_makeConstraints({ (make) in
                make.left.equalTo(view!).offset(AtapteWidthValue(20))
                make.right.equalTo(view!)
                make.top.equalTo(personalView!.snp_bottom).offset(AtapteHeightValue(10))
                make.height.equalTo(AtapteHeightValue(20))
            })
        }
        
        var tallyView = view!.viewWithTag(3001)
        if tallyView == nil {
            tallyView = UIView()
            tallyView?.tag = 3001
            tallyView?.backgroundColor = UIColor.white
            view!.addSubview(tallyView!)
            
        }
        
        var starLevelView = view?.viewWithTag(4001)
        if starLevelView == nil {
            starLevelView = UIView()
            starLevelView!.tag = 4001   
            starLevelView?.backgroundColor = UIColor.clear
            view!.addSubview(starLevelView!)
            
            for i in 0...4 {
                var star = starLevelView?.viewWithTag(starLevelView!.tag * 10 + i) as? UIImageView
                if star == nil {
                    star = UIImageView()
                    star?.tag = starLevelView!.tag * 10 + i
                    star?.backgroundColor = UIColor.clear
                    starLevelView?.addSubview(star!)
                    star?.snp_makeConstraints({ (make) in
                        make.left.equalTo(starLevelView!.snp_left).offset(AtapteWidthValue(((width / 3.0 + 20) / 5.0) * CGFloat(i)))
                        make.centerY.equalTo(starLevelView!)
                        make.width.equalTo(AtapteWidthValue(20))
                        make.height.equalTo(AtapteHeightValue(20))
                        
                    })
                    star?.image = UIImage.init(named: "guide-star-hollow")
                }
            }
        }

        tallyView?.snp_makeConstraints({ (make) in
            make.left.equalTo(view!).offset(AtapteWidthValue(20))
            make.right.equalTo(view!)
            make.top.equalTo(nickNameLab!.snp_bottom)
            make.bottom.equalTo(starLevelView!.snp_top)
        })
        
        var chatBtn = view!.viewWithTag(5001) as? UIButton
        if chatBtn == nil {
            chatBtn = UIButton()
            chatBtn?.tag = 5001
            chatBtn?.backgroundColor = UIColor.init(decR: 20, decG: 31, decB: 49, a: 1)
            chatBtn?.layer.cornerRadius = 5
            chatBtn?.layer.masksToBounds = true
            chatBtn?.setTitle("开始沟通", for: UIControlState())
            chatBtn?.setTitleColor(UIColor.white, for: UIControlState())
            chatBtn?.addTarget(self, action: #selector(ServantIntroCell.chatAction(_:)), for: .touchUpInside)
            view?.addSubview(chatBtn!)
            chatBtn?.snp_makeConstraints({ (make) in
                make.right.equalTo(view!).offset(AtapteWidthValue(-10))
                make.centerY.equalTo(starLevelView!)
                make.width.equalTo(AtapteWidthValue(100))
                make.height.equalTo(AtapteHeightValue(30))
            })
        }
        
        starLevelView?.snp_makeConstraints({ (make) in
            make.top.equalTo(tallyView!.snp_bottom)
            make.left.equalTo(view!).offset(AtapteWidthValue(20))
            make.right.equalTo(chatBtn!.snp_left)
            make.height.equalTo(AtapteHeightValue(50))
        })
        
        
        
        var bottomControl = view!.viewWithTag(10010)
        if bottomControl == nil {
            bottomControl = UIView()
            bottomControl!.tag = 10010
            bottomControl!.backgroundColor = UIColor.clear
            view?.addSubview(bottomControl!)
            bottomControl?.snp_makeConstraints({ (make) in
                make.top.equalTo(starLevelView!.snp_bottom)
                make.bottom.equalTo(view!)
                make.left.equalTo(view!)
                make.right.equalTo(view!)
            })
        }
        
    }
    
    func chatAction(_ sender: UIButton?) {
        delegate?.chatAction(servantInfo)
    }
    
    func setInfo(_ userInfo: UserInfo?) {
        servantInfo = userInfo
        let view = contentView.viewWithTag(101)
        let imageView: UIImageView = view!.viewWithTag(1001) as! UIImageView
//        if let bigBGPhotoUrl = userInfo?.bigBGPhotoUrl {
//            
//            let photoUrl = NSURL(string: (bigBGPhotoUrl))
//            imageView.kf_setImageWithURL(photoUrl, placeholderImage: UIImage(named: "defaultBg1"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
//            }
//            
//        }
        let headUrl = URL(string: userInfo!.headUrl!)
        let headView = imageView.viewWithTag(10001) as! UIImageView
        headView.kf_setImageWithURL(headUrl, placeholderImage: UIImage(named: "touxiang_women"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            
        }
        
        if let nickNameLab = view!.viewWithTag(2001) as? UILabel {
            nickNameLab.text = userInfo?.nickname
        }
        
        var lastTallyView:UIView?
        let businessTags = List<Tally>() +  (userInfo?.businessTags)!
        let tags = businessTags + (userInfo?.travalTags)!
        let tallyView = view!.viewWithTag(3001)
        for subview in tallyView!.subviews {
            subview.removeFromSuperview()
        }
        allLabelWidth = 0.0
        for (index, tag) in tags.enumerated() {
            var tallyItemView = tallyView!.viewWithTag(1001 + index)
            if tallyItemView == nil {
                tallyItemView = UIView()
                tallyItemView!.tag = 1001 + index
                tallyItemView!.isUserInteractionEnabled = true
                tallyItemView!.backgroundColor = UIColor.clear
                tallyItemView!.layer.cornerRadius = 25 / 2.0
                tallyItemView?.layer.masksToBounds = true
                tallyItemView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
                tallyItemView?.layer.borderWidth = 1
                tallyView!.addSubview(tallyItemView!)
                tallyItemView!.translatesAutoresizingMaskIntoConstraints = false
                
                
                allLabelWidth = allLabelWidth + Float(AtapteWidthValue(10)) + tag.labelWidth

                tallyItemView!.snp_makeConstraints { (make) in
                    let previousView = tallyView!.viewWithTag(1001+index-1)

                    if previousView == nil {

                        make.top.equalTo(tallyView!).offset(AtapteHeightValue(10))
                        make.left.equalTo(tallyView!)
                    } else {
                        if allLabelWidth + 20 > Float(ScreenWidth) {

                            allLabelWidth = 10 + tag.labelWidth
                            make.top.equalTo(previousView!.snp_bottom).offset(AtapteHeightValue(10))
                            make.left.equalTo(tallyView!)
                        } else {
                            make.top.equalTo(previousView!)
                            make.left.equalTo(previousView!.snp_right).offset(AtapteWidthValue(10))
                        } 
                    }
                    make.height.equalTo(25)
                    make.width.equalTo(tag.labelWidth)
                }
            }
            lastTallyView = tallyItemView
            
            var tallyLabel = tallyItemView?.viewWithTag(tallyItemView!.tag * 100 + 1) as? UILabel
            if tallyLabel == nil {
                tallyLabel = UILabel(frame: CGRectZero)
                tallyLabel!.tag = tallyItemView!.tag * 100 + 1
                tallyLabel!.font = UIFont.systemFont(ofSize: S12)
                tallyLabel!.isUserInteractionEnabled = false
                tallyLabel!.backgroundColor = UIColor.clear
                tallyLabel?.textAlignment = .center
                tallyLabel?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
                tallyItemView!.addSubview(tallyLabel!)
                tallyLabel!.snp_makeConstraints { (make) in
                    make.left.equalTo(tallyItemView!).offset(AtapteWidthValue(10))
                    make.top.equalTo(tallyItemView!)
                    make.bottom.equalTo(tallyItemView!)
                    make.right.equalTo(tallyItemView!).offset(AtapteWidthValue(-10))
                }
            }
            tallyLabel!.text = tag.tally
            
        }
        if lastTallyView != nil {
            var tallyBottomView = tallyView?.viewWithTag(3001*10+1)
            if tallyBottomView == nil {
                tallyBottomView = UIView()
                tallyBottomView?.tag = 3001*10+1
                tallyBottomView?.backgroundColor = UIColor.clear
                tallyView?.addSubview(tallyBottomView!)
            }
            tallyBottomView?.snp_remakeConstraints({ (make) in
                make.top.equalTo(lastTallyView!.snp_bottom)
                make.bottom.equalTo(tallyView!)
            })
        }
        
        let starLevelView = view!.viewWithTag(4001)
        for i in 0...4 {
            if let star = starLevelView?.viewWithTag(starLevelView!.tag * 10 + i) as? UIImageView {
                star.image = UIImage.init(named: (userInfo!.praiseLv / Int(i+1) >= 1) ? "guide-star-fill" : "guide-star-hollow")
                
            }
        }
        
        if let officialAuth = imageView.viewWithTag(10003) as? UIImageView {
            officialAuth.isHidden = !(userInfo?.certification)!
        }
        
        if let limitLab = imageView.viewWithTag(10006) as? UILabel {
            let myLongitude = DataManager.currentUser!.gpsLocationLon
            let myLatitude = DataManager.currentUser!.gpsLocationLat
            let servantLongitude = userInfo?.gpsLocationLon
            let servantLatitude = userInfo?.gpsLocationLat
            limitLab.text = "\(String(format: "%.2f", CalcDistance(myLongitude, lat1: myLatitude, lon2: servantLongitude!, lat2: servantLatitude!))) Km"
        }
        
    }
    
    func Angle2Radian(_ angle: Double) ->Double {
        return angle * ServantIntroCell.PI / 180.0;
    }
    
    func CalcDistance(_ lon1: Double, lat1: Double, lon2: Double, lat2: Double) ->Double {
        let lat_a:Double = Angle2Radian(lat1)
        let lon_a:Double = Angle2Radian(lon1)
        let lat_b:Double = Angle2Radian(lat2)
        let lon_b:Double = Angle2Radian(lon2)
        return acos(sin(lat_a) * sin(lat_b) + cos(lat_a) * cos(lat_b) * cos(lon_a - lon_b)) * ServantIntroCell.EARTH_R;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
