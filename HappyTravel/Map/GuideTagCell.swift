//
//  GuideTagCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/15.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class GuideTagCell: MAAnnotationView {
    
    var userInfo:UserInfoModel?
    
    lazy var bgView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "map-head-bg")
        return imageView
    }()
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        initView()
        centerOffset.y = -77
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initView() {
        image = UIImage.init(named: "map-head-bg")
        
        addSubview(bgView)
        bgView.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(67)
            make.height.equalTo(77)
        })
        
        var headView = viewWithTag(1001) as? UIImageView
        if headView == nil {
            headView = UIImageView()
            headView?.layer.masksToBounds = true
            headView?.layer.cornerRadius = 30.5
            headView?.tag = 1001
            bgView.addSubview(headView!)
            headView?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(self).offset(6)
                make.width.equalTo(61)
                make.height.equalTo(61)
            })
            headView?.image = UIImage.init(named: "default-head")
        }
        
    }
    
    func setInfo(info: UserInfoModel?) {
        userInfo = info
        if let headView = bgView.viewWithTag(1001) as? UIImageView {
            if userInfo?.head_url_ != nil {
                headView.kf_setImageWithURL(NSURL.init(string: userInfo!.head_url_!))
            } else {
                headView.image = UIImage.init(named: userInfo!.gender_ == 1 ? "map-head-male" : "map-head-female")
            }
            
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
