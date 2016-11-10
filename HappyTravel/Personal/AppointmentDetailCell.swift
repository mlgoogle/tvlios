//
//  AppointmentDetailCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/10.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class AppointmentDetailCell: UITableViewCell {

    lazy private var iconImageView:UIImageView = {
       let imageView = UIImageView()
        
        imageView.image = UIImage(named: "map-head-female")
        
        return imageView
    }()
    var nicknameLabel:UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFontOfSize(S15)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = colorWithHexString("#131f32")
        return label
    }()
    var serviceTypeLabel:UILabel = {
       
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(S15)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = colorWithHexString("#131f32")
        return label
    }()
    var dateLabel:UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFontOfSize(S15)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = colorWithHexString("#131f32")
        return label
    }()
    var cityButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.titleLabel?.font = UIFont.systemFontOfSize(S12)
        button.setTitleColor(colorWithHexString("#999999"), forState: .Normal)
        return button
    }()
    
    var detailIconImageView:UIImageView = {
        let imageView = UIImageView()
        
        
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
