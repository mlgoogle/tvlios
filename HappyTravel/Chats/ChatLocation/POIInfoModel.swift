//
//  POIInfoModel.swift
//  TestAdress
//
//  Created by J-bb on 16/12/29.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import Foundation

class POIInfoModel: NSObject {

    
    
    var name:String?
    var detail:String?
    var latiude:Double = 0.0
    var longtiude:Double = 0.0
    
    var isSelect = false
    
    
    func modelToString()-> String {
        
        if name == nil {
            name = "位置分享"
        }
        if detail == nil {
            detail = "位置分享"
        }
        return name! + "," + detail! + "|" + String(latiude) + "," + String(longtiude)
    }
}

