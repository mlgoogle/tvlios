//
//  YD_NewPersonGuideManager.swift
//  TestAdress
//
//  Created by J-bb on 17/1/13.
//  Copyright © 2017年 J-bb. All rights reserved.
//

import UIKit

class YD_NewPersonGuideManager: NSObject {

    static var view:NewPersonMaskView?
    
    static func startGuide(tag: String, mainGuideInfos:[[String: Any?]], secGuideInfos:[[String: Any?]]?) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let isShowMaskView = userDefaults.valueForKey(tag)
        guard isShowMaskView == nil else {return}
        guard view == nil else {return}
        view = NewPersonMaskView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        view?.mainGuideInfos = mainGuideInfos
        view?.secGuideInfos = secGuideInfos
        view!.touchedEndBlock = { () in
            userDefaults.setBool(true, forKey: tag)
            view?.removeFromSuperview()
            view?.hidden = true
            view = nil
        }
        view?.startGuide()
    }
    
}
