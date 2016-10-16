//
//  CenturionCardLvSegmentCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/13.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class CenturionCardLvSegmentCell : UITableViewCell {
    
    
    let tags = ["segment": 1001]
    
    let centurionCardTitle = [0: "初级会员",
                              1: "中级会员",
                              2: "高级会员"]
    
    let centurionCardIcon = [0: [0: "primary-level-disable", 1: "primary-level"],
                             1: [0: "middle-level-disable", 1: "middle-level"],
                             2: [0: "advanced-level-disable", 1: "advanced-level"]]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.whiteColor()
        
        for i in 0..<centurionCardIcon.count {
            let lvBtn = UIButton.init()
            lvBtn.tag = tags["segment"]! * 10 + i
            lvBtn.setImage(UIImage.init(named: centurionCardIcon[i]![0]!), forState: .Normal)
            lvBtn.setTitle(centurionCardTitle[i]!, forState: .Normal)
            contentView.addSubview(lvBtn)
            lvBtn.snp_makeConstraints(closure: { (make) in
                if let preBtn = contentView.viewWithTag(tags["segment"]! * 10 + i - 1) {
                    if i != 0 {
                        make.left.equalTo(preBtn.snp_right)
                    }
                }
                if i == 0 {
                    make.left.equalTo(contentView)
                }
                if i == centurionCardTitle.count - 1 {
                    make.right.equalTo(contentView)
                }
                make.top.equalTo(contentView)
                make.bottom.equalTo(contentView)
                make.height.equalTo(70)
            })
        }
        
    }
    
    func setInfo(userInfo: UserInfo?, segmentIndex: Int) {
        if let segment = contentView.viewWithTag(tags["segment"]!) {
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
