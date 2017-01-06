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
        label.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)

        label.font = UIFont.systemFontOfSize(16)
        return label
    }()
    lazy var adressLabel:UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)

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
        
        contentView.frame = CGRectMake(-80, -70, 200, 50)
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
            make.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.bottom.equalTo(-5)
        }
        
        let imageview = UIImageView.init(frame: CGRectMake(5, -20, 20, 20))
        imageview.image = UIImage(named: "snajiaoxing")
        addSubview(imageview)
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

class TriangleView: UIView {
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        let point1 = CGPointMake(0, 0)
        let point2 = CGPointMake(rect.size.width / 2, -rect.size.height)
        let point3 = CGPointMake(rect.size.width, 0)
        path.moveToPoint(point1)
        path.addLineToPoint(point2)
        path.addLineToPoint(point3)
        path.closePath()
        UIColor.whiteColor().setFill()
        path.fill()
    }

}
