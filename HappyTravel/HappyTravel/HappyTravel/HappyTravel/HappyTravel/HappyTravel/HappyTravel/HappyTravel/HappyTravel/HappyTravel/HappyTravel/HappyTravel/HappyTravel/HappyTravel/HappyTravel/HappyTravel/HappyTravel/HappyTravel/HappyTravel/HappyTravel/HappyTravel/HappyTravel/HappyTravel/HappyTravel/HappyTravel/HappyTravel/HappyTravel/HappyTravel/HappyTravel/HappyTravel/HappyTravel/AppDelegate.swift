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
class AppDelegate: UIResponder, UIApplicationDelegate, GeTuiSdkDelegate {

    var window: UIWindow?
    
    var rootVC:UIViewController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.applicationSupportsShakeToEdit = true
        
        XCGLogger.defaultInstance().xcodeColorsEnabled = true
        XCGLogger.defaultInstance().xcodeColors = [
            .Verbose: .lightGrey,
            .Debug: .darkGrey,
            .Info: .green,
            .Warning: .orange,
            .Error: XCGLogger.XcodeColor(fg: UIColor.redColor(), bg: UIColor.whiteColor()),
            .Severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0))
        ]
        
        commonViewSet()
        
        pushMessageRegister()
        
        return true
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
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60) ,forBarMetrics: .Default)
    }
    
    func pushMessageRegister() {
        //注册消息推送
        GeTuiSdk.startSdkWithAppId("d2YVUlrbRU6yF0PFQJfPkA", appKey: "yEIPB4YFxw64Ag9yJpaXT9", appSecret: "TMQWRB2KrG7QAipcBKGEyA", delegate: self)
        
        let notifySettings = UIUserNotificationSettings.init(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notifySettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    //MARK: - OpenURL
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
//        AlipaySDK.defaultService().processOrderWithPaymentResult(url) { (data: [NSObject : AnyObject]!) in
//            XCGLogger.debug("\(data)")
//        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        
        return true
    }

    //MARK: - BG FG
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        GeTuiSdk.resume()
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        GeTuiSdk.destroy()
    }
    
    //MARK: - Notify
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        XCGLogger.info("\(token)")
        GeTuiSdk.registerDeviceToken(token)
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: CommonDefine.DeviceToken)
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        XCGLogger.error("\(error)")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let vcs = window?.rootViewController?.childViewControllers[1].childViewControllers[0].childViewControllers
        for vc in vcs! {
            if vc.isKindOfClass(ForthwithVC) {
                if let _ = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
                    vc.navigationController?.popToRootViewControllerAnimated(false)
                    (vc as! ForthwithVC).msgAction(notification.userInfo)
                    
                }
                
                break
            }
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        XCGLogger.info("\((userInfo["aps"]!["alert"] as! NSDictionary)["body"] as! String)")
        application.applicationIconBadgeNumber = 0
        completionHandler(UIBackgroundFetchResult.NewData)
//        let vcs = window?.rootViewController?.childViewControllers[1].childViewControllers[0].childViewControllers
//        for vc in vcs! {
//            if vc.isKindOfClass(ForthwithVC) {
//                vc.navigationController?.popToRootViewControllerAnimated(false)
//                (vc as! ForthwithVC).msgAction(nil)
//                break
//            }
//        }
    }
    
    //MARK: - GeTuiSdkDelegate
    func GeTuiSdkDidRegisterClient(clientId: String!) {
        XCGLogger.info("CID:\(clientId)")
    }
    
    func GeTuiSdkDidReceivePayloadData(payloadData: NSData!, andTaskId taskId: String!, andMsgId msgId: String!, andOffLine offLine: Bool, fromGtAppId appId: String!) {
        GeTuiSdk.resetBadge()
        XCGLogger.debug("\(payloadData.length)")
        XCGLogger.debug("\(String.init(data: payloadData, encoding: NSUTF8StringEncoding))")
    }
    
    func GeTuiSdkDidSendMessage(messageId: String!, result: Int32) {
        
    }
    
    func GeTuiSdkDidOccurError(error: NSError!) {
        
    }
    
    func GeTuiSDkDidNotifySdkState(aStatus: SdkStatus) {
        
    }
    
    func GeTuiSdkDidSetPushMode(isModeOff: Bool, error: NSError!) {
        
    }
}

