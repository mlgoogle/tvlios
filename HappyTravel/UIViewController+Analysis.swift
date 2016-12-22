//
//  UIViewController+Analysis.swift
//  HappyTravel
//
//  Created by J-bb on 16/12/20.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

extension UIViewController {
    
    
     override public static func initialize() {

        guard self == UIViewController.self else {return}
        
        /**
         * 获取系统的viewWillAppear方法
         */
        let viewWillAppear = class_getInstanceMethod(self, #selector(UIViewController.viewWillAppear(_:)))
        /**
         * 获取自定义的viewWillAppear方法
         */
        let analysisViewWillAppear = class_getInstanceMethod(self, #selector(UIViewController.analysisViewWillAppear(_:)))

        /**
         * 替换方法实现
         */
        method_exchangeImplementations(viewWillAppear, analysisViewWillAppear)
        
        /*****同上*****/
        let viewWillDisappear = class_getInstanceMethod(self, #selector(UIViewController.viewWillDisappear(_:)))
        let analysisViewWillDisAppear = class_getInstanceMethod(self, #selector(UIViewController.analysisViewWillDisAppear(_:)))
        
        method_exchangeImplementations(viewWillDisappear, analysisViewWillDisAppear)
    }


    
    func analysisViewWillAppear(animated:Bool) {
        
        let classname = NSStringFromClass(self.classForCoder)
        
        MobClick.beginLogPageView(classname)
        /**
         * 因为此时方法实现已经替换，所以analysisViewWillAppear(animated) 相当于调用系统原来的 viewWillAppear
         */
        analysisViewWillAppear(animated)
        
    }
    /**********同上*************/
    func analysisViewWillDisAppear(animated:Bool) {
        
        let classname = NSStringFromClass(self.classForCoder)
        
        MobClick.endLogPageView(classname)
        
        
        analysisViewWillDisAppear(animated)
    }
}
