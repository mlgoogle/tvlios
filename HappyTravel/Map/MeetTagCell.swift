//
//  MeetTagCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/15.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class MeetTagCell: MAAnnotationView {
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initView() {
        var meetTipsView = viewWithTag(1001) as? UIImageView
        if meetTipsView == nil {
            meetTipsView = UIImageView()
            meetTipsView?.tag = 1001
            meetTipsView?.layer.cornerRadius = 5
            meetTipsView?.layer.masksToBounds = true
            meetTipsView?.backgroundColor = UIColor.clearColor()
            addSubview(meetTipsView!)
            meetTipsView?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(self)
                make.bottom.equalTo(self.snp_top).offset(-5)
                make.width.equalTo(120)
                make.height.equalTo(30)
            })
            meetTipsView?.image = UIImage.init(named: "meet-tips")
            image = UIImage.init(named: "map_meet")
        }
        
        var timeLab = viewWithTag(1002) as? UILabel
        if timeLab == nil {
            timeLab = UILabel()
            timeLab?.tag = 1002
            timeLab?.font = UIFont.systemFontOfSize(15)
            timeLab?.textColor = UIColor.whiteColor()
            timeLab?.textAlignment = NSTextAlignment.Center
            timeLab?.backgroundColor = UIColor.clearColor()
            meetTipsView?.addSubview(timeLab!)
            timeLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(meetTipsView!)
                make.top.equalTo(meetTipsView!)
                make.width.equalTo(35)
                make.height.equalTo(20)
            })
        }
        timeLab?.text = "24"
        
        var timeUnitLab = viewWithTag(1003) as? UILabel
        if timeUnitLab == nil {
            timeUnitLab = UILabel()
            timeUnitLab?.tag = 1003
            timeUnitLab?.font = UIFont.systemFontOfSize(10)
            timeUnitLab?.textColor = UIColor.whiteColor()
            timeUnitLab?.textAlignment = NSTextAlignment.Center
            timeUnitLab?.backgroundColor = UIColor.clearColor()
            meetTipsView?.addSubview(timeUnitLab!)
            timeUnitLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(timeLab!)
                make.top.equalTo(timeLab!.snp_bottom)
                make.width.equalTo(timeLab!.snp_width)
                make.bottom.equalTo(meetTipsView!).offset(-2)
            })
        }
        timeUnitLab?.text = "MIN"
        
        var tipsLab = viewWithTag(1005) as? UILabel
        if tipsLab == nil {
            tipsLab = UILabel()
            tipsLab?.tag = 1005
            tipsLab?.text = "这里会面"
            tipsLab?.font = UIFont.systemFontOfSize(13)
            tipsLab?.textColor = UIColor.whiteColor()
            tipsLab?.textAlignment = NSTextAlignment.Center
            tipsLab?.backgroundColor = UIColor.clearColor()
            meetTipsView?.addSubview(tipsLab!)
            tipsLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(timeLab!.snp_right)
                make.top.equalTo(meetTipsView!)
                make.right.equalTo(meetTipsView!)
                make.bottom.equalTo(meetTipsView!)
            })
        }
        
    }
    
    func setInfo(info: UserInfo?) {
        let meetTipsView = viewWithTag(1001) as? UIImageView
        if meetTipsView != nil {
//            meetTipsView!.kf_setImageWithURL(NSURL(string: info!["photo"] as! String))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
