//
//  UpdateManager.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/30.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation


class UpdateManager {
    
    /**
     检查并提示更新
     
     - parameter lastVer:  最新版本号（默认： x.x.x 形式）
     - parameter buildVer: 最新构建版本号（默认：整形数字字符串）
     - parameter forced:   强制更新
     - parameter result:   动作回调
     */
    static func checking4Update(lastVer: String, buildVer: String, forced: Bool, result:((gotoUpdate:Bool) -> (Void))?) {
        UpdateModule.checking4Update(lastVer, buildVer: buildVer, forced: forced, result: result)
    }
    
}
