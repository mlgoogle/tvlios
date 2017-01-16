//
//  FlashGuideCell.swift
//  TestAdress
//
//  Created by J-bb on 17/1/14.
//  Copyright © 2017年 J-bb. All rights reserved.
//

import UIKit
import Kingfisher

class FlashGuideCell: UICollectionViewCell {
  
    lazy var guideImageView:UIImageView = {
        
        let imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
        
    }()
    
    lazy var ignoreButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("跳过>", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(S13)
        button.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var showHomeButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("点击进入>>>>", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(guideImageView)
        guideImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        guideImageView.addSubview(showHomeButton)
        showHomeButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(guideImageView)
            make.bottom.equalTo(-100)
        }
        
        guideImageView.addSubview(ignoreButton)
        ignoreButton.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(40)
            make.top.equalTo(40)
            make.height.equalTo(30)
            make.width.equalTo(60)
        })
    }
    
    func setImage(image:UIImage?) {
        guideImageView.image = image
    }
    
    func setImageUrl(urlString:String?) {
        
        guard urlString != nil else {return}
        guideImageView.kf_setImageWithURL(NSURL(string: urlString!), placeholderImage: UIImage(named: ""), optionsInfo: [.ForceRefresh], progressBlock: nil, completionHandler: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentView.addSubview(guideImageView)
        guideImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    
    
    
    
}
