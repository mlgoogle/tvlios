//
//  NSDateExt.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/21.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

extension Date{
    
    
    /**
     *  字符串转日期
     */
    public func yt_convertDateStrToStr(_ dateStr: String, format: String) -> Date {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        return formatter.date(from: dateStr)!
    }
    
    /**
     *  日期转字符串
     */
    public func yt_convertDateToStr(_ date: Date, format: String) -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /**
     *  时间戳转日期
     */
    func yt_convertDateStrWithTimestemp(_ timeStemp: Int, format: String) -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.autoupdatingCurrent
        let date = Date.init(timeIntervalSince1970: Double(timeStemp)/1000 as TimeInterval)
        return yt_convertDateToStr(date, format: format)
    }
    
    
    /**
     *  获取当前月份
     */
    func yt_month() -> Int {
        let compents: DateComponents = (Calendar.current as NSCalendar).components(.month, from: self)
        return compents.month!
    }
    
    /**
     *  获取当前年份
     */
    func yt_year() -> Int {
        let compents: DateComponents = (Calendar.current as NSCalendar).components(.year, from: self)
        return compents.year!
    }
    
    /**
     *  获取当前日期
     */
    func yt_day() -> Int {
        let compents: DateComponents = (Calendar.current as NSCalendar).components(.day, from: self)
        return compents.day!
    }
}
