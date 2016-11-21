//
//  NSDateExt.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/21.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

extension NSDate{
    
    
    /**
     *  字符串转日期
     */
    public func yt_convertDateStrToStr(dateStr: String, format: String) -> NSDate {
        let formatter = NSDateFormatter.init()
        formatter.dateFormat = format
        return formatter.dateFromString(dateStr)!
    }
    
    /**
     *  日期转字符串
     */
    public func yt_convertDateToStr(date: NSDate, format: String) -> String {
        let formatter = NSDateFormatter.init()
        formatter.dateFormat = format
        return formatter.stringFromDate(date)
    }
    
    /**
     *  时间戳转日期
     */
    func yt_convertDateStrWithTimestemp(timeStemp: Int, format: String) -> String {
        let formatter = NSDateFormatter.init()
        formatter.dateFormat = format
        formatter.timeZone = NSTimeZone.localTimeZone()
        let date = NSDate.init(timeIntervalSince1970: Double(timeStemp)/1000 as NSTimeInterval)
        return yt_convertDateToStr(date, format: format)
    }
    
    
    /**
     *  获取当前月份
     */
    func yt_month() -> Int {
        let compents: NSDateComponents = NSCalendar.currentCalendar().components(.Month, fromDate: self)
        return compents.month
    }
    
    /**
     *  获取当前年份
     */
    func yt_year() -> Int {
        let compents: NSDateComponents = NSCalendar.currentCalendar().components(.Year, fromDate: self)
        return compents.year
    }
    
    /**
     *  获取当前日期
     */
    func yt_day() -> Int {
        let compents: NSDateComponents = NSCalendar.currentCalendar().components(.Day, fromDate: self)
        return compents.day
    }
}