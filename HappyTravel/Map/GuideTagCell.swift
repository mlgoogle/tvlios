//
//  GuideTagCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/15.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class GuideTagCell: MAAnnotationView {
    
    var userInfo:UserInfo?
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        initView()
        centerOffset.y = 5
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initView() {
        var headView = viewWithTag(1001) as? UIImageView
        if headView == nil {
            headView = UIImageView()
            headView?.tag = 1001
//            headView?.layer.cornerRadius = 25
//            headView?.layer.masksToBounds = true
////            headView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
//            headView?.layer.borderColor = UIColor.whiteColor().CGColor
//            headView?.layer.borderWidth = 1
//            headView?.backgroundColor = UIColor.grayColor()
            addSubview(headView!)
            headView?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(self)
                make.width.equalTo(50)
                make.height.equalTo(50)
            })
            headView?.image = UIImage.init(named: "default-head")
            image = UIImage.init(named: "")
        }
        
        var guideTipsView = viewWithTag(1002) as? UIImageView
        if guideTipsView == nil {
            guideTipsView = UIImageView()
            guideTipsView?.tag = 1002
            guideTipsView?.layer.cornerRadius = 5
            guideTipsView?.layer.masksToBounds = true
            guideTipsView?.backgroundColor = UIColor.clearColor()
            addSubview(guideTipsView!)
            guideTipsView?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(self)
                make.bottom.equalTo(headView!.snp_top).offset(-2)
                make.width.equalTo(120)
                make.height.equalTo(41)
            })
            guideTipsView?.image = UIImage.init(named: "guide-tips")
            image = UIImage.init(named: "")
        }
        
        var guideTipsLab = viewWithTag(10021) as? UILabel
        if guideTipsLab == nil {
            guideTipsLab = UILabel()
            guideTipsLab?.tag = 10021
            guideTipsLab?.font = UIFont.systemFontOfSize(S15)
            guideTipsLab?.textColor = UIColor.whiteColor()
            guideTipsLab?.textAlignment = NSTextAlignment.Center
            guideTipsLab?.backgroundColor = UIColor.clearColor()
            guideTipsView?.addSubview(guideTipsLab!)
            guideTipsLab?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(guideTipsView!)
                make.top.equalTo(guideTipsView!)
                make.height.equalTo(30)
                make.width.equalTo(guideTipsView!)
            })
        }
        guideTipsLab?.text = "最低服务200元"
        guideTipsView?.hidden = true
    }
    
    func setInfo(info: UserInfo?) {
        userInfo = info
        if let headView = viewWithTag(1001) as? UIImageView {
            headView.image = UIImage.init(named: userInfo?.gender == 1 ? "map-head-male" : "map-head-female")
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let headView = viewWithTag(1001) as? UIImageView
        if CGRectContainsPoint((headView?.frame)!, point) {
           
            return self
            
        }
        return super.hitTest(point, withEvent: event)
    }
}
