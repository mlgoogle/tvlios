//
//  CentuionCardPriceInfo.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/22.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class CentuionCardPriceInfo: Object {
    dynamic var blackcard_lv_: Int = 0
    dynamic var blackcard_price_: Int = 0
    
    func setInfo(info: CentuionCardPriceInfo) {
        blackcard_lv_ = info.blackcard_lv_
        blackcard_price_ = info.blackcard_price_
    }
}
