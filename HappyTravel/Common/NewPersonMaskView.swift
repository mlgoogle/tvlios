//
//  NewPersonMaskView.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/12.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit

@objc protocol TouchViewDelegate:NSObjectProtocol {
    
    
    optional func touchMaskView()
}
class NewPersonMaskView: UIView {
    weak var delegate:TouchViewDelegate?

    var guideImageView:UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "newperson-appointment")
        return imageView
    }()
    
    var imageName:String?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        addSubview(guideImageView)
        guideImageView.frame = CGRectMake(0, 20, frame.size.width, frame.size.height)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
