//
//  ViewController.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import SideMenuController



class ViewController: SideMenuController,FlashGuideViewControllerDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        SideMenuController.preferences.drawing.menuButtonImage = UIImage.init(named:"nav-personal")
        SideMenuController.preferences.drawing.sidePanelPosition = .OverCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = UIScreen.mainScreen().bounds.size.width * 0.75
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
        
        let guide = FlashGuideViewController()
        guide.modalTransitionStyle = .CrossDissolve
        guide.delegate = self
        embed(centerViewController: guide)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.floatForKey("guideVersion") < 1.2 {
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
    
    
    func guideEnd() {
        initMainInterface()
    }
}

