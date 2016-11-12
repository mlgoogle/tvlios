//
//  CenturionCardLvSelCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/20.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

protocol CenturionCardLvSelCellDelegate : NSObjectProtocol {
    
    func selectedAction(index: Int)
    
}

class CenturionCardLvSelCell : UITableViewCell {
    
    weak var delegate:CenturionCardLvSelCellDelegate?
    var indirector: UIImageView = UIImageView()
    
    let tags = ["lvBtn": 1001,
                "servicesBGView": 1002]
    
    let centurionCardTitle = [0: "一星会员",
                              1: "二星会员",
                              2: "三星会员",
                              3: "四星会员"]
    
    let centurionCardIcon = [0: [0: "primary-level-disable", 1: "primary-level"],
                             1: [0: "middle-level-disable", 1: "middle-level"],
                             2: [0: "advanced-level-disable", 1: "advanced-level"],
                             3: [0: "advanced-level-disable", 1: "advanced-level"]]
    
    let services = [0: []]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.redColor()
        backgroundColor = UIColor.redColor()
        
        let lv = DataManager.currentUser?.centurionCardLv
        var curSelBtn:UIButton?
        for i in 0..<centurionCardIcon.count {
            let buttonWidth:CGFloat = UIScreen.mainScreen().bounds.size.width / CGFloat(centurionCardIcon.count)
            let buttonHeight:CGFloat = 70.0
            let imageWidth:CGFloat = 28.0
            var lvBtn = contentView.viewWithTag(tags["lvBtn"]! * 10 + i) as? UIButton
            if lvBtn == nil {
                lvBtn = UIButton()
                lvBtn?.tag = tags["lvBtn"]! * 10 + i
                lvBtn?.backgroundColor = UIColor.init(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
                lvBtn?.setImage(UIImage.init(named: centurionCardIcon[i]![0]!), forState: .Normal)
                lvBtn?.setTitle(centurionCardTitle[i]!, forState: .Normal)
                lvBtn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
                lvBtn?.imageEdgeInsets = UIEdgeInsetsMake(0, buttonWidth/2.0-imageWidth/2.0, buttonHeight/7.0*2, buttonWidth/2.0-imageWidth/2.0)
                lvBtn?.titleEdgeInsets = UIEdgeInsetsMake(buttonHeight/7.0*5-AtapteHeightValue(15), -buttonWidth/2.0, 0, -imageWidth/2.0)
                lvBtn?.titleLabel?.font = UIFont.systemFontOfSize(S12)
                lvBtn?.addTarget(self, action: #selector(CenturionCardLvSelCell.switchoverServicesView(_:)), forControlEvents: .TouchUpInside)
                contentView.addSubview(lvBtn!)
                lvBtn?.snp_makeConstraints(closure: { (make) in
                    if i == 0 {
                        make.left.equalTo(contentView)
                    } else {
                        if let preBtn = contentView.viewWithTag(tags["lvBtn"]! * 10 + i - 1) {
                            if i == centurionCardTitle.count - 1 {
                                make.right.equalTo(contentView)
                            }
                            make.left.equalTo(preBtn.snp_right)
                        }
                    }
                    make.top.equalTo(contentView)
                    make.height.equalTo(buttonHeight)
                    make.width.equalTo(buttonWidth)
                    make.bottom.equalTo(contentView)
                })

            }
            lvBtn?.setImage(UIImage.init(named: i < lv ? centurionCardIcon[i]![1]! : centurionCardIcon[i]![0]!), forState: .Normal)
            lvBtn?.setTitleColor(i < lv ? UIColor.blackColor() : UIColor.grayColor(), forState: .Normal)
            if lv == i + 1 || (lv == 0 && i == 0) {
                curSelBtn = lvBtn
            }
        }
        
        indirector.image = UIImage.init(named: "indirector")
        contentView.addSubview(indirector)
        indirector.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(curSelBtn!.snp_centerX)
            make.bottom.equalTo(contentView).offset(2)
        })
    }
    
    func switchoverServicesView(sender: UIButton) {
        self.indirector.snp_remakeConstraints(closure: { (make) in
            make.centerX.equalTo(sender.snp_centerX)
            make.bottom.equalTo(self.contentView).offset(2)
        })
        delegate?.selectedAction(sender.tag - tags["lvBtn"]! * 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
