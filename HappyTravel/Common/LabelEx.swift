//
//  LabelEx.swift
//  HappyTravel
//
//  Created by CloudTopDevOne on 2016/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

extension UILabel {
    
    convenience init(text: String, font: UIFont, textColor: UIColor){
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.numberOfLines = 0
    }
}