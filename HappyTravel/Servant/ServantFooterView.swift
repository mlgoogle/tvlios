//
//  ServantFooterView.swift
//  HappyTravel
//
//  Created by 巩婧奕 on 2017/3/5.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//


import UIKit
import Foundation

class ServantFooterView: UIView {
    
    var detailWord:String?
    
    
    init(frame: CGRect, detail:String) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        detailWord = detail
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        
        // 先把字打上
        let attributeText:NSMutableAttributedString = NSMutableAttributedString.init(string: detailWord!)
        attributeText.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12), range: NSMakeRange(0, attributeText.length))
        let option:NSStringDrawingOptions = .UsesLineFragmentOrigin
        
        let boundingRect:CGRect = attributeText.boundingRectWithSize(CGSizeMake(ScreenWidth, 15), options: option, context: nil)
        
        let detailLabel:UILabel = UILabel.init()
        detailLabel.frame = CGRectMake(0, 0, boundingRect.width, 15)
        detailLabel.center = self.center
        detailLabel.textColor = UIColor.init(decR: 102, decG: 102, decB: 102, a: 1)
        detailLabel.font = UIFont.systemFontOfSize(12)
        detailLabel.textAlignment = .Center
        detailLabel.text = detailWord
        self.addSubview(detailLabel)
        
        //左右两边的两条线
        let leftLine:UIView = UIView.init(frame: CGRectMake(40, self.Height/2.0, detailLabel.Left - 50 , 1))
        leftLine.backgroundColor = UIColor.init(decR: 204, decG: 204, decB: 204, a: 1)
        let rightLine:UIView = UIView.init(frame: CGRectMake(self.Width / 2.0 + boundingRect.width / 2.0 + 10 , self.Height / 2.0 , leftLine.Width, 1))
        rightLine.backgroundColor = leftLine.backgroundColor
        self.addSubview(leftLine)
        self.addSubview(rightLine)
    }
}
