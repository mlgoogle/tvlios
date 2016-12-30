//
//  UpdateManager.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/30.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation


class UpdateManager {
    
    enum VerCompare : Int {
        case Low = -1
        case Equal = 0
        case Height = 1
    }
    
    static var share = UpdateManager()
    
    /**
     检查并提示更新
     
     - parameter lastVer:  最新版本号（默认： x.x.x 形式）
     - parameter buildVer: 最新构建版本号（默认：整形数字字符串）
     - parameter forced:   强制更新
     */
    func checking4Update(lastVer: String, buildVer: String, forced: Bool) {
        let curVer = getVer()
        let curBuildVer = getBuildVer()
        var needUpdate = false
        let verStatus = verCompare(lastVer, ver2: curVer!)
        switch verStatus {
        case .Height:
            needUpdate = true
        case .Equal:
            needUpdate = Int.init(buildVer)! > Int.init(curBuildVer!)
        default:
            break
        }
        if needUpdate {
            let alert = UIAlertController.init(title: "升级提示", message: "有新的版本", preferredStyle: .Alert)
        }
    }
    
    /**
     比较版本高低
     
     - parameter ver1: 版本1
     - parameter ver2: 版本2
     
     - returns: 版本1 > 版本2
     */
    private func verCompare(ver1: String, ver2: String) -> VerCompare {
        let ver1SubVer = ver1.componentsSeparatedByString(".")
        let ver2SubVer = ver2.componentsSeparatedByString(".")
        if ver1SubVer.count == 3 && ver2SubVer.count == 3 {
            for i in 0..<3 {
                let v1 = Int.init(ver1SubVer[i])!
                let v2 = Int.init(ver2SubVer[i])!
                guard v1 == v2 else { return v1 > v2 ? .Height : .Low }
            }
        }
        return .Equal
    }
    
    private func getVer() -> String? {
        if let info = getAppInfo() {
            return info["CFBundleShortVersionString"] as? String
        }
        return nil
    }
    
    private func getBuildVer() -> String? {
        if let info = getAppInfo() {
            return info["CFBundleVersion"] as? String
        }
        return nil
    }
    
    private func getAppInfo() -> [String: AnyObject]? {
        return NSBundle.mainBundle().infoDictionary
    }
    
}
