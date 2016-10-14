//
//  ViewController.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import SideMenuController

class ViewController: SideMenuController {
    
    
    func initMainInterface() {
        let forthwithVC = ForthwithVC()
        forthwithVC.view.backgroundColor = UIColor.whiteColor()
        let forthwithNC = UINavigationController(rootViewController: forthwithVC)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [forthwithNC]
        
        let myPersonalVC = MyPersonalVC.shareInstance
        
        embed(sideViewController: myPersonalVC)
        embed(centerViewController: tabBarController)
        
        [forthwithNC].forEach({ controller in
            controller.addSideMenuButton()
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "nav-personal")
        SideMenuController.preferences.drawing.sidePanelPosition = .UnderCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = UIScreen.mainScreen().bounds.size.width / 3.0 * 2
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.drawing.centerPanelOverlayColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        SideMenuController.preferences.animating.statusBarBehaviour = .HorizontalPan
        SideMenuController.preferences.animating.transitionAnimator = FadeAnimator.self
        
        initMainInterface()
        
        startSockThread()
    }
    
    func startSockThread() {
        SocketManager.shareInstance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

