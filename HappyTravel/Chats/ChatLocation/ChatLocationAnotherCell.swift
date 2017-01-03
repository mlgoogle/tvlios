//
//  ChatLocationAnotherCell.swift
//  TestAdress
//
//  Created by J-bb on 16/12/29.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import UIKit

class ChatLocationAnotherCell: ChatLocationCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bundleImageView.tintColor = UIColor(red: 19/255.0, green: 31/255.0, blue: 50/255.0, alpha: 1.0)
        titleLabel.textColor = UIColor.whiteColor()

        adressLabel.textColor = UIColor.whiteColor()

        bundleImageView.snp_remakeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(5)
            make.right.equalTo(-100)
            make.bottom.equalTo(-5)
        }
    }
    override func setupDataWithContent(content: String?) {
        
        super.setupDataWithContent(content)
        var image = UIImage(named: "msg-bubble-another")
        
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        bundleImageView.image = image?.resizableImageWithCapInsets(UIEdgeInsetsMake(17, 23  , 17, 23), resizingMode: UIImageResizingMode.Stretch)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
