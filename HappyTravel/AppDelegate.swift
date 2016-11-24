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
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.applicationSupportsShakeToEdit = true
        
        XCGLogger.default.xcodeColorsEnabled = true
        XCGLogger.default.xcodeColors = [
            .Verbose: .lightGrey,
            .Debug: .darkGrey,
            .Info: .green,
            .Warning: .orange,
            .Error: XCGLogger.XcodeColor(fg: UIColor.redColor(), bg: UIColor.whiteColor()),
            .Severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0))
        ]
        
        commonViewSet()
        
        initPlugins()
        
        pushMessageRegister()
        
        return true
    }
    
    func initPlugins() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () in
            WXApi.registerApp("wx9dc39aec13ee3158", withDescription: "vLeader-1.0(alpha)")
            
            Fabric.with([Crashlytics.self])
            
        })
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () in
            var key = ""
            if let id = Bundle.main.bundleIdentifier {
                if id == "com.yundian.enterprise.trip" {
                    key = "11feec2b7ad127ae156d72aa08f2342e"
                } else if id == "com.yundian.trip" {
                    key = "50bb1e806f1d2c1a797e6e789563e334"
                }
            }
            AMapServices.shared().apiKey = key
        })
        
    }
    
    func commonViewSet() {
        let bar = UINavigationBar.appearance()
        bar.setBackgroundImage(UIImage.init(named: "head-bg"), for: .default)
        bar.tintColor = UIColor.white
        
        let attr:Dictionary = [NSForegroundColorAttributeName: UIColor.white]
        bar.titleTextAttributes = attr
        bar.isTranslucent = false
        bar.shadowImage = UIImage()
        bar.layer.masksToBounds = true
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        let tabbar = UITabBar.appearance()
        tabbar.barTintColor = UIColor.init(red: 33/255.0, green: 59/255.0, blue: 76/255.0, alpha: 1)
        tabbar.isHidden = true
        
        var attrTabbarItem = [NSFontAttributeName: UIFont.systemFont(ofSize: 20),
                              NSForegroundColorAttributeName: UIColor.init(red: 33/255.0, green: 235/255.0, blue: 233/255.0, alpha: 1)]
        let tabbarItem = UITabBarItem.appearance()
        tabbarItem.titlePositionAdjustment = UIOffsetMake(CGFloat(-10),CGFloat(-10))
        tabbarItem.setTitleTextAttributes(attrTabbarItem, for: UIControlState.selected)
        attrTabbarItem[NSForegroundColorAttributeName] = UIColor.gray
        tabbarItem.setTitleTextAttributes(attrTabbarItem, for: UIControlState())
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60) ,for: .default)
    }
    
    func pushMessageRegister() {
        //注册消息推送
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () in
            GeTuiSdk.start(withAppId: "d2YVUlrbRU6yF0PFQJfPkA", appKey: "yEIPB4YFxw64Ag9yJpaXT9", appSecret: "TMQWRB2KrG7QAipcBKGEyA", delegate: self)
        
            let notifySettings = UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notifySettings)
            UIApplication.shared.registerForRemoteNotifications()

        })
    }

    //MARK: - OpenURL
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
//        AlipaySDK.defaultService().processOrderWithPaymentResult(url) { (data: [NSObject : AnyObject]!) in
//            XCGLogger.debug("\(data)")
//        }
        
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        return WXApi.handleOpen(url, delegate: self)
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        return WXApi.handleOpen(url, delegate: self)
    }
    
    //MARK: - BG FG
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        GeTuiSdk.resume()
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        GeTuiSdk.destroy()
    }
    
    //MARK: - Notify
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = deviceToken.description
        token = token.replacingOccurrences(of: " ", with: "")
        token = token.replacingOccurrences(of: "<", with: "")
        token = token.replacingOccurrences(of: ">", with: "")

        XCGLogger.debug("\(token)")
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () in
            GeTuiSdk.registerDeviceToken(token)
        })
        UserDefaults.standard.set(token, forKey: CommonDefine.DeviceToken)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        XCGLogger.error("\(error)")
    }

    

    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let vcs = window?.rootViewController?.childViewControllers[1].childViewControllers[0].childViewControllers
        for vc in vcs! {
            if vc.isKind(of: ForthwithVC.self) {
                if let _ = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
                    _ = vc.navigationController?.popToRootViewController(animated: false)
                    (vc as! ForthwithVC).msgAction(notification.userInfo as AnyObject?)
                    
                }
                
                break
            }
        }
    }
    
    
    /**
     
     远程通知 回调处理 iOS10 以下有效？？2016年11月16日19:44:54
     iOS10也有效了。。2016年11月17日17:05:20
     - parameter application:
     - parameter userInfo:
     - parameter completionHandler:
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        application.applicationIconBadgeNumber = 0
        completionHandler(UIBackgroundFetchResult.newData)


        let dict = userInfo["aps"] as! [String : Any]
        let messageDict  = dict["category"] as? String
        
        var str = messageDict!.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
        str = str.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        let data = str.data(using: String.Encoding.utf8)
        let jsonData = JSON.init(data: data!)
        let pushMessage = PushMessage()
        pushMessage.setInfo(jsonData.dictionaryObject as Dictionary<String, AnyObject>?)
        
        DataManager.insertPushMessage(pushMessage)
//        if UIApplication.sharedApplication().applicationState == .Background {
////            XCGLogger.info("\((userInfo["aps"]!["alert"] as! NSDictionary)["body"] as! String)")
//            application.applicationIconBadgeNumber = 0
//            completionHandler(UIBackgroundFetchResult.NewData)
//            let vcs = window?.rootViewController?.childViewControllers[1].childViewControllers[0].childViewControllers
//            for vc in vcs! {
//                if vc.isKindOfClass(ForthwithVC) {
//                    vc.navigationController?.popToRootViewControllerAnimated(false)
//                    (vc as! ForthwithVC).msgAction((userInfo["aps"]!["alert"] as! [String: AnyObject])["body"])
//                    break
//                }
//            }
//        }
//        else
//        {
//            
//            let messageDict  = userInfo["aps"]!["alert"]!!["body"] as! String
//
//            var str = messageDict.stringByReplacingOccurrencesOfString("\n", withString: "", options: .LiteralSearch, range: nil)
//            str = str.stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
//            let data = str.dataUsingEncoding(NSUTF8StringEncoding)
//            
//            let jsonData = JSON.init(data: data!)
//            let pushMessage = PushMessage()
//
//            
//            pushMessage.setInfo(jsonData.dictionaryObject)
//            
//            DataManager.insertPushMessage(pushMessage)
//        }
    }
    
    //MARK: - GeTuiSdkDelegate
    func geTuiSdkDidRegisterClient(_ clientId: String!) {
        XCGLogger.debug("CID:\(clientId)")
    }
    
    func geTuiSdkDidReceivePayloadData(_ payloadData: Data!, andTaskId taskId: String!, andMsgId msgId: String!, andOffLine offLine: Bool, fromGtAppId appId: String!) {
        GeTuiSdk.resetBadge()
        XCGLogger.debug("\(payloadData.count)")
        XCGLogger.debug("\(String.init(data: payloadData, encoding: String.Encoding.utf8))")
    }
    
    func geTuiSdkDidSendMessage(_ messageId: String!, result: Int32) {
        
    }
    
    func geTuiSdkDidOccurError(_ error: Error!) {
        
    }
    
    func geTuiSDkDidNotifySdkState(_ aStatus: SdkStatus) {
        
    }
    
    func geTuiSdkDidSetPushMode(_ isModeOff: Bool, error: Error!) {
        
    }
    
    // WXApiDelegate
    func onReq(_ req: BaseReq!) {
        XCGLogger.debug("s")
    }
    
    func onResp(_ resp: BaseResp!) {
        var strMsg = "(resp.errCode)"
        if resp.isKind(of: PayResp.self) {
            switch resp.errCode {
            case 0 :
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.WeChatPaySuccessed), object: nil)
            default:
                strMsg = "支付失败，请您重新支付!"
                print("retcode = \(resp.errCode), retstr = \(resp.errStr)")
                let alert = UIAlertView(title: "支付结果", message: strMsg, delegate: nil, cancelButtonTitle: "好的")
                alert.show()
            }
        }
        XCGLogger.debug(resp)
        if resp.isKind(of: SendMessageToWXResp.self) {
            let message = resp.errCode == 0 ? "分享成功":"分享失败"
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.WeChatShareResult), object: ["result":message])
            
        }
        
    }
    
}

