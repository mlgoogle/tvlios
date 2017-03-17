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
import Fabric
import Crashlytics
import SwiftyJSON
//import YWFeedbackKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GeTuiSdkDelegate, WXApiDelegate {

    var window: UIWindow?
    
    var rootVC:UIViewController?
    var bgTask:UIBackgroundTaskIdentifier?

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
        initPlugins()
        
        return true
    }
    
    func initPlugins() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () in
            WXApi.registerApp("wx9dc39aec13ee3158", withDescription: "vLeader-1.0(alpha)")
            
            Fabric.with([Crashlytics.self])
            
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () in
            var key = "62f33d0af1098f28ceed54c86ea21890"
            if let id = NSBundle.mainBundle().bundleIdentifier {
                if id == "com.yundian.enterprise.trip" {
                    key = "4bb6a0b7762c3f6881048a57d9d64bef"
                } else if id == "com.yundian.trip" {
                    key = "62f33d0af1098f28ceed54c86ea21890"
                }
            }
            AMapServices.sharedServices().apiKey = key
        })
        
        registerUMAnalytics()
    }
    func registerUMAnalytics() {
        MobClick.setCrashReportEnabled(false)
        UMAnalyticsConfig.sharedInstance().appKey = "584e18ca1c5dd07e7d001a19"
        UMAnalyticsConfig.sharedInstance().channelId = ""
        MobClick.startWithConfigure(UMAnalyticsConfig.sharedInstance())
        //version标识
        let version: String? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String
        MobClick.setAppVersion(version)
        //日志加密设置
        MobClick.setEncryptEnabled(true)
   
    }
    
    func commonViewSet() {
        let bar = UINavigationBar.appearance()
//        bar.setBackgroundImage(UIImage.init(named: "head-bg"), forBarMetrics: .Default)
        bar.tintColor = UIColor.blackColor()
//        bar.backgroundColor = UIColor.whiteColor()
        bar.barTintColor = UIColor.whiteColor()
        
        let attr:Dictionary = [NSForegroundColorAttributeName: UIColor.blackColor()]
        bar.titleTextAttributes = attr
        bar.translucent = false
//        bar.shadowImage = UIImage()
//        bar.layer.masksToBounds = true
        
        UITabBar.appearance().hidden = true
        
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
//        let tabbar = UITabBar.appearance()
//        tabbar.barTintColor = UIColor.init(red: 33/255.0, green: 59/255.0, blue: 76/255.0, alpha: 1)
//        tabbar.hidden = true
        
//        var attrTabbarItem = [NSFontAttributeName: UIFont.systemFontOfSize(20),
//                              NSForegroundColorAttributeName: UIColor.init(red: 33/255.0, green: 235/255.0, blue: 233/255.0, alpha: 1)]
//        let tabbarItem = UITabBarItem.appearance()
//        tabbarItem.titlePositionAdjustment = UIOffsetMake(CGFloat(-10),CGFloat(-10))
//        tabbarItem.setTitleTextAttributes(attrTabbarItem, forState: UIControlState.Selected)
//        attrTabbarItem[NSForegroundColorAttributeName] = UIColor.grayColor()
//        tabbarItem.setTitleTextAttributes(attrTabbarItem, forState: UIControlState.Normal)
//        
//        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60) ,forBarMetrics: .Default)
    }
    
    func pushMessageRegister() {
        //注册消息推送
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () in
            var appid = "d2YVUlrbRU6yF0PFQJfPkA"
            var appkey =  "yEIPB4YFxw64Ag9yJpaXT9"
            var appSecret = "TMQWRB2KrG7QAipcBKGEyA"
            if let id = NSBundle.mainBundle().bundleIdentifier {
                if id == "com.yundian.trip" {
                    appid = "rx572izgdt5Sdfomxbel1"
                    appkey = "LBW2Ex5cT79VIHunoC6Zg6"
                    appSecret = "hYTWpJOK8L6ge1etzQnlV2"
                }
                
            }
            
            GeTuiSdk.startSdkWithAppId(appid, appKey: appkey, appSecret: appSecret, delegate: self)
            let notifySettings = UIUserNotificationSettings.init(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notifySettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()

        })
    }

    //MARK: - OpenURL
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    //MARK: - BG FG
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        GeTuiSdk.resume()
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {

    }
    //MARK: - Notify
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")

        XCGLogger.debug("\(token)")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () in
            GeTuiSdk.registerDeviceToken(token)
        })
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
                    
                }
                
                break
            }
        }
    }
    
    /**
     
     - parameter application:
     - parameter userInfo:
     - parameter completionHandler:
     */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        application.applicationIconBadgeNumber = 0
        completionHandler(UIBackgroundFetchResult.NewData)
        
    }
    
    //MARK: - GeTuiSdkDelegate
    func GeTuiSdkDidRegisterClient(clientId: String!) {
        XCGLogger.debug("CID:\(clientId)")
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
    
    // WXApiDelegate
    func onReq(req: BaseReq!) {
        XCGLogger.debug("s")
    }
    
    func onResp(resp: BaseResp!) {
        var strMsg = "(resp.errCode)"
        if resp.isKindOfClass(PayResp) {
            switch resp.errCode {
            case 0 :
                NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.WeChatPaySuccessed, object: nil)
            default:
                strMsg = "支付失败，请您重新支付!"
                print("retcode = \(resp.errCode), retstr = \(resp.errStr)")
                let alert = UIAlertView(title: "支付结果", message: strMsg, delegate: nil, cancelButtonTitle: "好的")
                alert.show()
            }
        }
        XCGLogger.debug(resp)
        if resp.isKindOfClass(SendMessageToWXResp) {
            let message = resp.errCode == 0 ? "分享成功":"分享失败"
            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.WeChatShareResult, object: ["result":message])
            
        }
        
    }
    
}

