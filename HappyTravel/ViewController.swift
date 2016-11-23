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
    
    // 初始化主界面
    func initMainInterface() {
        
        let forthwithVC = ForthwithVC()
        forthwithVC.view.backgroundColor = UIColor.white
        let forthwithNC = UINavigationController(rootViewController: forthwithVC)
        forthwithNC.navigationBar.setBackgroundImage(UIImage.init(named: "nav_clear"), for: .any, barMetrics: .default)
        forthwithNC.navigationBar.shadowImage = UIImage.init(named: "nav_clear")
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

