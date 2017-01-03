//
//  YD_AnnotationView.swift
//  TestAdress
//
//  Created by J-bb on 16/12/30.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import Foundation

protocol OpenMapDelegate:NSObjectProtocol {
    
    func openMap(annomationView:YD_AnnotationView)
}

class YD_AnnotationView: MAAnnotationView {
    
    weak var delegate:OpenMapDelegate?
    lazy var nameLabel:UILabel = {
       
        let label = UILabel()
        
        label.font = UIFont.systemFontOfSize(16)
        return label
    }()
    lazy var adressLabel:UILabel = {
        
        let label = UILabel()

        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    lazy var contentView:UIView = {
       
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    lazy var navigationButton:UIButton = {
       let button = UIButton(type: .Custom)
       button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.orangeColor()
        button.setTitle("导航", forState: .Normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        contentView.frame = CGRectMake(-100, -50, 200, 50)
        addSubview(contentView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(adressLabel)
        contentView.addSubview(navigationButton)
        navigationButton.snp_makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.width.equalTo(60)
        }
        nameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(5)
            make.height.equalTo(20)
            make.right.equalTo(navigationButton.snp_left).offset(-5)
        }
        adressLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.bottom.equalTo(-5)
        }
        navigationButton.addTarget(self, action: #selector(YD_AnnotationView.openMapAction), forControlEvents: .TouchUpInside)
    }
    
    func openMapAction() {
        guard delegate != nil else {return}
        delegate?.openMap(self)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
     
        if CGRectContainsPoint(contentView.frame, point) {
            return navigationButton
        }
        return super.hitTest(point, withEvent: event)
    }
    
}