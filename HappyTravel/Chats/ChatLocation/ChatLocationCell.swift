//
//  ChatLocationCell.swift
//  TestAdress
//
//  Created by J-bb on 16/12/29.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import Foundation

import UIKit

class ChatLocationCell: UITableViewCell {
    
    lazy var bundleImageView:UIImageView = {
        let imageView = UIImageView()

        imageView.tintColor = UIColor.whiteColor()

        return imageView
    }()
    
    
    lazy var iconImageView:UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "2222")
        return imageView
        
    }()
    lazy var titleLabel:UILabel = {
       
        let label = UILabel()
        label.text = "位置分享"
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        return label
    }()

    lazy var adressLabel:UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(bundleImageView)
        bundleImageView.addSubview(iconImageView)
        bundleImageView.addSubview(titleLabel)
        bundleImageView.addSubview(adressLabel)
        
        bundleImageView.snp_makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(5)
            make.left.equalTo(100)
            make.bottom.equalTo(-5)
        }
        
        iconImageView.snp_makeConstraints { (make) in
            make.left.equalTo(bundleImageView.snp_left).offset(20)
            make.top.equalTo(10)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp_right).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(20)
        }
        adressLabel.snp_makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(5)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.bottom.lessThanOrEqualTo(-10)
            
        }
    }
    
    func setupDataWithContent(content:String?) {

        guard content != nil else {return}
        
        let poiModel = stringToModel(content!)
        
        adressLabel.text = poiModel.detail
        titleLabel.text = poiModel.name
        
    }


    
    func stringToModel(content:String) -> POIInfoModel {
        
        let model = POIInfoModel()
        
        let infoArray = content.componentsSeparatedByString("|")
        
        let addressString = infoArray.first
        let locationString = infoArray.last
        
        model.name = addressString?.componentsSeparatedByString(",").first
        model.detail = addressString?.componentsSeparatedByString(",").last
        
        guard locationString != nil else {return model}
        
        if locationString?.componentsSeparatedByString(",").first != nil {
            model.latiude = Double((locationString?.componentsSeparatedByString(",").first)!)!
        }
        if locationString?.componentsSeparatedByString(",").last != nil {
            model.longtiude = Double((locationString?.componentsSeparatedByString(",").last)!)!
        }
        
        return model
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
