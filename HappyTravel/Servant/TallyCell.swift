//
//  GuideAreaCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

open class TallyCell : UITableViewCell {
    
    let tags = ["bgView": 1001,
                "noTallyLabel": 1002,
                "bottomControl": 1003,
                "tallyItemView": 1004]
    var allLabelWidth:Float = 10.0

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        
        var bgView = contentView.viewWithTag(tags["bgView"]!)
        if bgView == nil {
            bgView = UIView()
            bgView!.tag = tags["bgView"]!
            bgView!.backgroundColor = UIColor.clear
            bgView!.isUserInteractionEnabled = true
            contentView.addSubview(bgView!)
            bgView!.snp_makeConstraints { (make) in
                make.left.equalTo(self.contentView)
                make.top.equalTo(self.contentView)
                make.right.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView)
            }
        }
        
        var noTallyLabel = contentView.viewWithTag(tags["noTallyLabel"]!) as? UILabel
        if noTallyLabel == nil {
            noTallyLabel = UILabel(frame: CGRect.zero)
            noTallyLabel!.tag = tags["noTallyLabel"]!
            noTallyLabel!.font = UIFont.systemFont(ofSize: S12)
            noTallyLabel!.isUserInteractionEnabled = false
            noTallyLabel!.numberOfLines = 0
            noTallyLabel!.layer.cornerRadius = 25 / 2.0
            noTallyLabel?.layer.masksToBounds = true
            noTallyLabel?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            noTallyLabel?.layer.borderWidth = 1
            noTallyLabel!.backgroundColor = UIColor.init(red: 67/255.0, green: 189/255.0, blue: 159/255.0, alpha: 0.8)
            noTallyLabel!.translatesAutoresizingMaskIntoConstraints = false
            bgView!.addSubview(noTallyLabel!)
            noTallyLabel!.snp_remakeConstraints { (make) in
                make.top.equalTo(bgView!)
                make.left.equalTo(bgView!)
                make.height.equalTo(25)
                make.width.equalTo(25)
            }
        }
        noTallyLabel?.isHidden = false
        noTallyLabel!.text = "无"
        
        var bottomControl = bgView!.viewWithTag(tags["bottomControl"]!)
        if bottomControl == nil {
            bottomControl = UIView()
            bottomControl!.tag = tags["bottomControl"]!
            bottomControl!.backgroundColor = UIColor.clear
            bgView!.addSubview(bottomControl!)
            bottomControl?.snp_makeConstraints({ (make) in
                make.top.equalTo(noTallyLabel!.snp_bottom)
                make.bottom.equalTo(bgView!).offset(-10)
                make.left.equalTo(bgView!)
                make.right.equalTo(bgView!)
            })
        }
        
    }
    
    func setInfo(_ tags: List<Tally>?) {
        
        
        if tags?.count != 0 {
            var lastTallyItemView:UIView?
            allLabelWidth = 10.0

            for (index, tag) in tags!.enumerated() {
                var tallyItemView = contentView.viewWithTag(self.tags["tallyItemView"]! * 10 + index)
                if tallyItemView == nil {
                    tallyItemView = UIView()
                    tallyItemView!.tag = self.tags["tallyItemView"]! * 10 + index
                    tallyItemView!.isUserInteractionEnabled = true
                    tallyItemView!.backgroundColor = UIColor.clear
                    tallyItemView!.layer.cornerRadius = 25 / 2.0
                    tallyItemView?.layer.masksToBounds = true
                    tallyItemView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
                    tallyItemView?.layer.borderWidth = 1
                    contentView.addSubview(tallyItemView!)
                    tallyItemView!.translatesAutoresizingMaskIntoConstraints = false
                    let previousView = contentView.viewWithTag(tallyItemView!.tag - 1)
                    allLabelWidth = allLabelWidth + 10 + tag.labelWidth

                    tallyItemView!.snp_makeConstraints { (make) in
                        if previousView == nil {
                            make.top.equalTo(self.contentView).offset(10)
                            make.left.equalTo(self.contentView).offset(10)
                        } else {
                            if allLabelWidth + 10 > Float(ScreenWidth) {
                                
                                allLabelWidth = 10 + tag.labelWidth
                                make.top.equalTo(previousView!.snp_bottom).offset(10)
                                make.left.equalTo(self.contentView).offset(10)
                            } else {
                                make.top.equalTo(previousView!)
                                make.left.equalTo(previousView!.snp_right).offset(10)
                            }
                        }
                        make.height.equalTo(25)
                        make.width.equalTo(tag.labelWidth)

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
                    tallyLabel!.snp_makeConstraints { (make) in
                        make.left.equalTo(tallyItemView!).offset(10)
                        make.top.equalTo(tallyItemView!)
                        make.bottom.equalTo(tallyItemView!)
                        make.right.equalTo(tallyItemView!).offset(-10)
                    }
                }
                tallyLabel!.text = tag.tally
                
                lastTallyItemView = tallyItemView
            }
            if let bgView = contentView.viewWithTag(self.tags["bgView"]!) {
                if let bottomControl = bgView.viewWithTag(self.tags["bottomControl"]!) {
                    bottomControl.snp_remakeConstraints({ (make) in
                        make.top.equalTo(lastTallyItemView!.snp_bottom)
                        make.bottom.equalTo(bgView).offset(-10)
                        make.left.equalTo(bgView)
                        make.right.equalTo(bgView)
                    })
                }
                
                if let noTallyLabel = bgView.viewWithTag(self.tags["noTallyLabel"]!) as? UILabel {
                    noTallyLabel.isHidden = true
                }
                
            }
            
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
