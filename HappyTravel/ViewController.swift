//
//  ViewController.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import SideMenuController



class ViewController: SideMenuController,GuidePageDelegate {
    
    var guidePage:BLGuidePage?
    
    
    required init?(coder aDecoder: NSCoder) {
        SideMenuController.preferences.drawing.menuButtonImage = UIImage.init(named:"nav-personal")
        SideMenuController.preferences.drawing.sidePanelPosition = .OverCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = UIScreen.mainScreen().bounds.size.width * 0.7
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .ShowUnderlay
        super.init(coder: aDecoder)
    }
    
    // 初始化主界面
    func initMainInterface() {
        let forthwithVC = ForthwithVC()
        forthwithVC.modalTransitionStyle = .CrossDissolve
        forthwithVC.view.backgroundColor = UIColor.whiteColor()
        let forthwithNC = BaseNavigationController(rootViewController: forthwithVC)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [forthwithNC]
        
        let myPersonalVC = MyPersonalVC.shareInstance
        
        embed(sideViewController: myPersonalVC)
        embed(centerViewController: tabBarController)
        
        [forthwithNC].forEach({ controller in
            controller.addSideMenuButton()
        })
        
        startSockThread()
    }
    
    
    func loadGuide() {
        
        let pageArray:NSArray = ["guide01.jpg","guide02.jpg"]
        guidePage = BLGuidePage.init(imageArray: pageArray as [AnyObject])
        guidePage!.delegate = self
        view.addSubview(guidePage!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.floatForKey("guideVersion") < 1.1 {
            loadGuide()
        } else {
            initMainInterface()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func startSockThread() {
        SocketManager.shareInstance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lastImageClicked() {
        
//        let userDefault = NSUserDefaults.standardUserDefaults()
//        userDefault .setValue(2, forKey: "guideVersion")
        
        initMainInterface()
        UIView.animateWithDuration(1.5, animations: {
            self.guidePage?.alpha = 0
            }) { (finished) in
                self.guidePage?.removeFromSuperview()
        }
    }
}

