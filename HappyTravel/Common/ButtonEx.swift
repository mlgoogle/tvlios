//
//  ButtonEx.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/20.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

extension UIButton {
    
    func setImageAndTitleLeft(){
        let SPACING:CGFloat = 6.0
        setImageAndTitleLeft(SPACING)
    }
    
    //imageView在上,label在下
    func setImageAndTitleLeft(spacing:CGFloat){
        let imageSize =  imageView?.frame.size
        let titleSize = titleLabel?.frame.size;
        
        let totalHeight = imageSize!.height + titleSize!.height + spacing
        
        imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize!.height), 0.0, 0.0, -titleSize!.width)
        titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize!.width, -(totalHeight - titleSize!.height), 0.0)
    }
    
}