//
//  ChatDateCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/3.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

import UIKit

class ChatDateCell: UITableViewCell {
    let sentDateLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        sentDateLabel = UILabel(frame: CGRectZero)
        sentDateLabel.backgroundColor = .clearColor()
        sentDateLabel.font = UIFont.systemFontOfSize(11)
        sentDateLabel.textAlignment = .Center
        sentDateLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(sentDateLabel)
        
        sentDateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: sentDateLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: sentDateLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 13))
        contentView.addConstraint(NSLayoutConstraint(item: sentDateLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -4.5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

