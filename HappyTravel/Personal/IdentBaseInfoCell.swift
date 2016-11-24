//
//  IdentBaseInfoCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class IdentBaseInfoCell: UITableViewCell {
    
    var servantInfo:UserInfo?
    
    let tags = ["bgView": 1001,
                "headImageView": 1002,
                "nicknameLab": 1003,
                "starBGView": 1004,
                "tallyBGView": 1005,
                "tallyItemView": 1006]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        
        var bgView = contentView.viewWithTag(tags["bgView"]!)
        if bgView == nil {
            bgView = UIView()
            bgView!.tag = tags["bgView"]!
            bgView?.backgroundColor = UIColor.white
            bgView?.isUserInteractionEnabled = true
            bgView?.layer.cornerRadius = 5
            bgView?.layer.masksToBounds = true
            contentView.addSubview(bgView!)
            bgView?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView)
            })
        }
        
        var headImageView = bgView?.viewWithTag(tags["headImageView"]!) as? UIImageView
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = tags["headImageView"]!
            headImageView!.backgroundColor = UIColor.init(decR: 230, decG: 230, decB: 230, a: 1)
            headImageView!.isUserInteractionEnabled = true
            headImageView?.layer.cornerRadius = 80 / 2.0
            headImageView?.layer.masksToBounds = true
            headImageView?.layer.borderWidth = 1
            headImageView?.layer.borderColor = UIColor.init(decR: 183, decG: 39, decB: 43, a: 1).cgColor
            bgView!.addSubview(headImageView!)
            headImageView!.snp.makeConstraints { (make) in
                make.top.equalTo(bgView!).offset(20)
                make.left.equalTo(bgView!).offset(10)
                make.width.equalTo(80)
                make.height.equalTo(80)
                make.bottom.equalTo(bgView!).offset(-20)
            }
        }
        
        var nicknameLab = bgView?.viewWithTag(tags["nicknameLab"]!) as? UILabel
        if nicknameLab == nil {
            nicknameLab = UILabel()
            nicknameLab?.tag = tags["nicknameLab"]!
            nicknameLab?.backgroundColor = UIColor.clear
            nicknameLab?.font = UIFont.systemFont(ofSize: S15)
            bgView?.addSubview(nicknameLab!)
            nicknameLab?.snp.makeConstraints({ (make) in
                make.left.equalTo(headImageView!.snp.right).offset(10)
                make.top.equalTo(headImageView!)
            })
        }
        nicknameLab?.text = "PAPI酱"
        
        var starBGView = bgView?.viewWithTag(tags["starBGView"]!)
        if starBGView == nil {
            starBGView = UIView()
            starBGView?.tag = tags["starBGView"]!
            starBGView?.backgroundColor = UIColor.clear
            bgView?.addSubview(starBGView!)
            starBGView?.snp.makeConstraints({ (make) in
                make.left.equalTo(nicknameLab!)
                make.right.equalTo(bgView!).offset(-10)
                make.bottom.equalTo(headImageView!)
                make.height.equalTo(20)
            })
            for i in 0...4 {
                var star = starBGView!.viewWithTag(starBGView!.tag * 10 + i) as? UIImageView
                if star == nil {
                    star = UIImageView()
                    star!.backgroundColor = .clear
                    star!.tag = starBGView!.tag * 10 + i
                    star!.contentMode = .scaleAspectFit
                    starBGView!.addSubview(star!)
                    star!.snp.makeConstraints({ (make) in
                        if i == 0 {
                            make.left.equalTo(starBGView!)
                        } else {
                            make.left.equalTo((starBGView!.viewWithTag(starBGView!.tag * 10 + i - 1) as? UIImageView)!.snp.right).offset(10)
                        }
                        make.top.equalTo(starBGView!)
                        make.bottom.equalTo(starBGView!)
                        make.width.equalTo(17)
                    })
                }
                star?.image = UIImage.init(named: "guide-star-hollow")
            }
        }
        
        var tallyBGView = bgView?.viewWithTag(tags["tallyBGView"]!)
        if tallyBGView == nil {
            tallyBGView = UIView()
            tallyBGView?.tag = tags["tallyBGView"]!
            tallyBGView?.backgroundColor = UIColor.clear
            bgView?.addSubview(tallyBGView!)
            tallyBGView?.snp.makeConstraints({ (make) in
                make.left.equalTo(nicknameLab!)
                make.right.equalTo(bgView!).offset(-10)
                make.top.equalTo(nicknameLab!.snp.bottom)
                make.bottom.equalTo(starBGView!.snp.top)
            })
        }
    }
    
    func setInfo(_ userInfo: UserInfo?) {
        servantInfo = userInfo
        
        let tallys = List<Tally>()
        for businessTag in userInfo!.businessTags {
            tallys.append(businessTag)
        }
        for travalTag in userInfo!.travalTags {
            tallys.append(travalTag)
        }
        let bgView = contentView.viewWithTag(tags["bgView"]!)
        
        if let headImageView = bgView?.viewWithTag(tags["headImageView"]!) as? UIImageView {
            headImageView.kf_setImageWithURL(URL(string: (userInfo?.headUrl)!), placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                
            })
        }
        
        if let nicknameLab = contentView.viewWithTag(tags["nicknameLab"]!) as? UILabel {
            nicknameLab.text = userInfo?.nickname!
        }
        
        if tallys.count != 0 {
            let tallyBGView = bgView?.viewWithTag(tags["tallyBGView"]!)
            for (index, tag) in tallys.enumerated() {
                if index > 2 {
                    break
                }
                var tallyItemView = tallyBGView!.viewWithTag(self.tags["tallyItemView"]! * 10 + index)
                if tallyItemView == nil {
                    tallyItemView = UIView()
                    tallyItemView!.tag = self.tags["tallyItemView"]! * 10 + index
                    tallyItemView!.isUserInteractionEnabled = true
                    tallyItemView!.backgroundColor = UIColor.clear
                    tallyItemView!.layer.cornerRadius = 25 / 2.0
                    tallyItemView?.layer.masksToBounds = true
                    tallyItemView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
                    tallyItemView?.layer.borderWidth = 1
                    tallyBGView!.addSubview(tallyItemView!)
                    tallyItemView!.translatesAutoresizingMaskIntoConstraints = false
                    let previousView = tallyBGView!.viewWithTag(tallyItemView!.tag - 1)
                    tallyItemView!.snp.makeConstraints { (make) in
                        make.centerY.equalTo(tallyBGView!)
                        if previousView == nil {
                            make.left.equalTo(tallyBGView!)
                        } else {
                            make.left.equalTo(previousView!.snp.right).offset(10)
                        }
                        make.height.equalTo(25)
                    }
                }
                
                var tallyLabel = tallyItemView?.viewWithTag(tallyItemView!.tag * 10 + 1) as? UILabel
                if tallyLabel == nil {
                    tallyLabel = UILabel(frame: CGRectZero)
                    tallyLabel!.tag = tallyItemView!.tag * 10 + 1
                    tallyLabel!.font = UIFont.systemFont(ofSize: S12)
                    tallyLabel!.isUserInteractionEnabled = false
                    tallyLabel!.backgroundColor = UIColor.clear
                    tallyLabel?.textAlignment = .center
                    tallyLabel?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
                    tallyItemView!.addSubview(tallyLabel!)
                    tallyLabel!.translatesAutoresizingMaskIntoConstraints = false
                    tallyLabel!.snp.makeConstraints { (make) in
                        make.left.equalTo(tallyItemView!).offset(10)
                        make.top.equalTo(tallyItemView!)
                        make.bottom.equalTo(tallyItemView!)
                        make.right.equalTo(tallyItemView!).offset(-10)
                    }
                }
                tallyLabel!.text = tag.tally
                
            }
        }
        if let starBGView = bgView?.viewWithTag(tags["starBGView"]!) {
            for i in 0...4 {
                if let star = starBGView.viewWithTag(starBGView.tag * 10 + i) as? UIImageView {
                    star.image = userInfo!.businessLv / Float(i+1) >= 1 ? UIImage.init(named: "guide-star-fill") : UIImage.init(named: "guide-star-hollow")
                }
                
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

