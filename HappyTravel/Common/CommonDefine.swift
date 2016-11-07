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

let ScreenWidth = UIScreen.mainScreen().bounds.size.width
let ScreenHeight = UIScreen.mainScreen().bounds.size.height
let Timestamp = NSDate().timeIntervalSince1970
func  AtapteValue(value: CGFloat) -> CGFloat {
    let mate = ScreenWidth/375.0
    let atapteValue = value*mate
    return atapteValue
}


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
    
}




