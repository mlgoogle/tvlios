//
//  ColorExt.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/17.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation


extension UIColor {
    
    convenience init(decR: CGFloat, decG: CGFloat, decB: CGFloat, a: CGFloat) {
        self.init(red: decR/255.0, green: decG/255.0, blue: decB/255.0, alpha: a)
    }
    
    convenience init(hexR: CGFloat, hexG: CGFloat, hexB: CGFloat, a: CGFloat) {
        self.init(red: hexR/255.0, green: hexG/255.0, blue: hexB/255.0, alpha: a)
    }
    
    
  
}   
