//
//  AppDelegate.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import SideMenuController
import XCGLogger
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    func CustomUncaughtExceptionHandler() -> @convention(c) (NSException) -> Void {
//        return { (exception) -> Void in
//            let arr = exception.callStackSymbols  // 得到当前调用栈信息
//            let reason = exception.reason  // 非常重要，就是崩溃的原因
//            let name = exception.name  // 异常类型
//            
//            NSLog("exception type : \(name) \n crash reason : \(reason) \n call stack info : \(arr)");
//            print(exception)
//            print(exception.callStackSymbols)
//            
//        }
//    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
//        let log = XCGLogger.defaultInstance()
//        log.xcodeColors = [
//            .Verbose: .lightGrey,
//            .Debug: .darkGrey,
//            .Info: .darkGreen,
//            .Warning: .orange,
//            .Error: XCGLogger.XcodeColor(fg: UIColor.redColor(), bg: UIColor.whiteColor()), // Optionally use a UIColor
//            .Severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0)) // Optionally use RGB values directly
//        ]
//        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: .Debug)
//        
//        do {
//            try NSFileManager.defaultManager().removeItemAtURL(Realm.Configuration.defaultConfiguration.fileURL!)
//        } catch {}
        
//        NSSetUncaughtExceptionHandler(CustomUncaughtExceptionHandler())
        
        XCGLogger.debug("\(try! Realm().configuration)")
        
        application.applicationSupportsShakeToEdit = true
        
        commonViewSet()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func commonViewSet() {
        let bar = UINavigationBar.appearance()
        bar.setBackgroundImage(UIImage.init(named: "head-bg")?.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, -88, 0)), forBarMetrics: UIBarMetrics.Default)
        bar.tintColor = UIColor.whiteColor()
        let attr:Dictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        bar.titleTextAttributes = attr
        bar.translucent = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let tabbar = UITabBar.appearance()
        tabbar.barTintColor = UIColor.init(red: 33/255.0, green: 59/255.0, blue: 76/255.0, alpha: 1)
        tabbar.hidden = true
        
        var attrTabbarItem = [NSFontAttributeName: UIFont.systemFontOfSize(20),
                              NSForegroundColorAttributeName: UIColor.init(red: 33/255.0, green: 235/255.0, blue: 233/255.0, alpha: 1)]
        let tabbarItem = UITabBarItem.appearance()
        tabbarItem.titlePositionAdjustment = UIOffsetMake(CGFloat(-10),CGFloat(-10))
        tabbarItem.setTitleTextAttributes(attrTabbarItem, forState: UIControlState.Selected)
        attrTabbarItem[NSForegroundColorAttributeName] = UIColor.grayColor()
        tabbarItem.setTitleTextAttributes(attrTabbarItem, forState: UIControlState.Normal)
        
    }
}

