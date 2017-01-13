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
    
    static func startGuide() {
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let key = "isShowMaskView"
        
        let isShowMaskView = userDefaults.valueForKey(key)
        guard isShowMaskView == nil else {return}
        guard view == nil else {return}
        view = NewPersonMaskView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        
        view!.frameXYs = setFrames()
        view!.guideImages = setGuideImages()
        view!.infoImages = setInfoImages()
        view!.guideTypes = setGuideTypes()
        view!.infoTypes = setInfoTypes()
        view!.touchedEndBlock = { () in
            userDefaults.setBool(true, forKey: key)
            view?.removeFromSuperview()
            view?.hidden = true
            view = nil
        }
        view?.startGuide()
    }
    
    static func setFrames() -> Array<CGRect>{
   
        var array = Array<CGRect>()
        
        for index in 0...(setInfoTypes().count - 1) {
            
            var rect = CGRectZero
            
            switch index {
            case 0:
                rect = CGRectMake(10, 20, 0, 0)
            case 1:
                rect = CGRectMake(UIScreen.mainScreen().bounds.size.width - 90, 20, 0, 0)
                
            case 2:
                rect = CGRectMake(10, UIScreen.mainScreen().bounds.size.height - 80 - 50, 0, 0)
            case 3:
                rect = CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 70, 100, 0, 0)
            case 4:
                rect = CGRectMake(UIScreen.mainScreen().bounds.size.width - 150, UIScreen.mainScreen().bounds.size.height - 75, 0, 0)
            default:
                break
            }
            array.append(rect)

        }
        
        return array
    }
    
    static func setInfoImages() -> Array<String>{
        let infoNames = ["newperson-menuInfo","newperson-messageInfo","newperson-locationInfo","newperson-assistantInfo","newperson-appointmentInfo"]
        
        return infoNames
    }
    static func setGuideImages() -> Array<String>{
        
        let guideNames = ["newperson-menu","newperson-message","newperson-location","newperson-assistant","newperson-appointment"]
        return guideNames
    }
    
    static func setInfoTypes() -> Array<GuideDirection>{
        
        
        
        return [GuideDirection.Right,GuideDirection.Left,GuideDirection.Right,GuideDirection.Left,GuideDirection.Left]
    }
    static func setGuideTypes() -> Array<GuideDirection>{
        
        
        return [GuideDirection.Top,GuideDirection.Top,GuideDirection.Bottom,GuideDirection.Top,GuideDirection.Bottom]
    }
    
}
