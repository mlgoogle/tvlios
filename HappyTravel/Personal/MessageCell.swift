//
//  MessageCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/25.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class MessageCell: UITableViewCell {
    
    var userInfo:UserInfoModel?
    
    var redDotImage:UIImageView = {
       let imageView = UIImageView()
        return imageView
    }()
    let titleLabel:UILabel = UILabel()
    func updeat(info: OrderListCellModel){
        //时间戳的转换
        redDotImage.image = nil
        let dateFormatter = NSDateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.dateFromString(info.order_time_!)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = dateFormatter.stringFromDate(date!)
        titleLabel.text = dateString + "成功购买" + " ''" + info.to_uid_nickename_! + "'' " + "的商务信息"
        if info.is_evaluate_ == 0 {
           redDotImage.image = UIImage(named: "redDot")
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        contentView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-25)
            make.height.equalTo(16)
            make.top.equalTo(contentView).offset(14)
        }
        titleLabel.font = UIFont.systemFontOfSize(16)
        titleLabel.textAlignment = .Left
        
        contentView.addSubview(redDotImage)
        redDotImage.snp_makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-5)
            make.height.equalTo(5)
            make.width.equalTo(5)
            make.centerY.equalTo(titleLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
