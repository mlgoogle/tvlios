//
//  UIViewEx.swift
//  HappyTravel
//
//  Created by 巩婧奕 on 2017/3/3.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var Left:CGFloat {
        get {
            return self.frame.origin.x
        }
        set(left) {
            self.frame = CGRectMake(left, self.frame.origin.y, self.frame.size.width, self.frame.size.height)
        }
    }
    
    var Right:CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set(right) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, right - self.Left, self.frame.size.height)
        }
    }
    
    var Top:CGFloat {
        get {
            return self.frame.origin.y
        }
        set(top) {
            self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width, self.frame.size.height)
        }
    }
    
    var Bottom:CGFloat {
        get {
            return self.frame.size.height + self.Top
        }
        set(bottom) {
            self.frame = CGRectMake(self.Left, self.Top, self.frame.size.width, bottom - self.Top)
        }
    }
    
    var Width:CGFloat {
        get {
            return self.frame.size.width
        }
        set(width) {
            self.frame = CGRectMake(self.Left, self.Top, width, self.frame.size.height)
        }
    }
    
    var Height:CGFloat {
        get {
            return self.frame.size.height
        }
        set(height) {
            self.frame = CGRectMake(self.Left, self.Top, self.Width, height)
        }
    }
    
    
    
    
}



