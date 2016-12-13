//
//  CommonDefine.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/26.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
//MARK: -- 颜色全局方法
func colorWithHexString(hex: String) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substringFromIndex(1)
    }
    
    let rString = (cString as NSString).substringToIndex(2)
    let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
    let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    NSScanner(string: rString).scanHexInt(&r)
    NSScanner(string: gString).scanHexInt(&g)
    NSScanner(string: bString).scanHexInt(&b)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}
//MARK: -- 字体大小全局变量
let ScreenWidth = UIScreen.mainScreen().bounds.size.width
let ScreenHeight = UIScreen.mainScreen().bounds.size.height
let Timestamp = NSDate().timeIntervalSince1970
let S18 = AtapteWidthValue(18)
let S16 = AtapteWidthValue(16)
let S15 = AtapteWidthValue(15)
let S14 = AtapteWidthValue(14)
let S13 = AtapteWidthValue(13)          
let S12 = AtapteWidthValue(12)
let S10 = AtapteWidthValue(10)



func  AtapteWidthValue(value: CGFloat) -> CGFloat {
    let mate = ScreenWidth/375.0
    let atapteValue = value*mate
    return atapteValue
}

func  AtapteHeightValue(value: CGFloat) -> CGFloat {
    let mate = ScreenHeight/667.0
    let atapteValue = value*mate
    return atapteValue
}

//MARK: --正则表达
func isTelNumber(num:NSString)->Bool
{
    let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
    let  CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
    let  CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
    let  CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
    let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
    let regextestcm = NSPredicate(format: "SELF MATCHES %@",CM )
    let regextestcu = NSPredicate(format: "SELF MATCHES %@" ,CU)
    let regextestct = NSPredicate(format: "SELF MATCHES %@" ,CT)
    if ((regextestmobile.evaluateWithObject(num) == true)
        || (regextestcm.evaluateWithObject(num)  == true)
        || (regextestct.evaluateWithObject(num) == true)
        || (regextestcu.evaluateWithObject(num) == true))
    {
        return true
    }
    else
    {
        return false
    }  
}



class CommonDefine: NSObject {
    
    static let DeviceToken = "deviceToken"
    
    static let UserName = "UserName"
    
    static let Passwd = "Passwd"
    
    static let UserType = "UserType"
    static let errorMsgs: [Int: String] =  [-1000:"mysql执行错误",
                                            -1001:"登陆json格式错误",
                                            -1002:"手机号格式有误",
                                            -1003:"手机号或密码错误",
                                            -1004:"获取附近导游json格式错误",
                                            -1005:"附近没有V领队",
                                            -1006:"心跳包json格式错误",
                                            -1007:"没有V领队",
                                            -1008:"推荐领队json格式错误",
                                            -1009:"没有推荐V领队",
                                            -1010:"邀约json格式错误",
                                            -1011:"修改密码json格式错误",
                                            -1012:"用户不在缓存",
                                            -1013:"旧密码错误",
                                            -1014:"聊天包json错误",
                                            -1015:"新建订单错误",
                                            -1016:"聊天记录json格式错误",
                                            -1017:"没有聊天记录",
                                            -1018:"获取验证码json格式错误",
                                            -1019:"注册账号json错误",
                                            -1020:"验证码过期",
                                            -1021:"验证码错误",
                                            -1022:"完善资料json错误",
                                            -1023:"我的行程json错误",
                                            -1024:"服务详情json错误",
                                            -1025:"没有该用户",
                                            -1026:"开票json错误",
                                            -1027:"没有改用户的设备号",
                                            -1028:"设备号错误",
                                            -1029:"消息读取json失败",
                                            -1030:"评价行程json错误",
                                            -1031:"回复邀约json错误",
                                            -1032:"订单状态有误",
                                            -1033:"开票记录json错误",
                                            -1034:"黑卡服务表无数据",
                                            -1035:"黑卡信息json错误",
                                            -1036:"黑卡消费记录json错误",
                                            -1037:"预约json错误",
                                            -1038:"已请求过开票了",
                                            -1039:"订单未支付完成",
                                            -1040:"当前没有在线客服",
                                            -1041:"发票详情json错误",
                                            -1042:"微信下单json错误",
                                            -1043:"下单金额有误",
                                            -1044:"客户端微信支付结果通知json错误",
                                            -1045:"身份证信息json错误",
                                            -1046:"V领队详情json错误",
                                            -1047:"身份认证状态json错误",
                                            -1048:"分享旅游列表json错误",
                                            -1049:"分享旅游详情json错误",
                                            -1050:"用户余额json错误",
                                            -1051:"身份认证状态json错误",
                                            -1052:"评价信息json错误",
                                            -1053:"没有评价信息:",
                                            -1054:"预约记录json错误",
                                            -1055:"预约记录为空（没有多记录了)",
                                            -1056:"技能分享详情json错误",
                                            -1057:"技能分享讨论json错误",
                                            -1058:"技能分享报名json错误",
                                            -1059:"请求数据错误",
                                            -1060:"微信服务回调错误",
                                            -1061:"微信下单失败",
                                            -1062:"验证密码 密码错误",
                                            -1063:"已经设置过支付密码了",
                                            -1064:"不能直接设置登录"]
    
    
    
    class BuriedPoint {
       
        static let register = "register"
        static let registerBtn = "registerBtn"
        static let registerNext = "registerNext"
        static let registerSure = "registerSure"
        static let login = "login"
        static let loginBtn = "loginBtn"
        static let loginAction = "loginAction"
        static let walletbtn = "walletbtn"
        static let rechargeBtn = "rechargeBtn"
        static let recharfeTextField = "recharfeTextField"
        static let paySureBtn = "paySureBtn"
        static let payWithWechat = "payWithWechat"
        static let paySuccess = "paySuccess"
        static let payForOrder = "payForOrder"
        static let payForOrderSuccess = "payForOrderSuccess"
        static let payForOrderFail = "payForOrderFail"
        static let vippage = "vippage"
        static let vipLvpay = "vipLvpay"

    }
    
    
}




