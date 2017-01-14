//
//  UIViewControllerExt.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/13.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation


extension UIViewController {
    
    func dismissAll(completion: (() -> Void)?) {
        var present = presentingViewController
        while present != nil {
            if let tmp = present!.presentingViewController {
                present = tmp
                if present!.isKindOfClass(ViewController) {
                    break
                }
            } else {
                break
            }
        }
        
        present?.dismissViewControllerAnimated(false, completion: completion)
    }
}
