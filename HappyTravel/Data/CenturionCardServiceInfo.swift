//
//  CenturionCardServiceInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/19.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class CenturionCardServiceInfo: Object {
    
    dynamic var privilege_bg_:String?
    
    dynamic var privilege_details_:String?
    
    dynamic var privilege_id_ = 0
    
    dynamic var privilege_lv_ = 0
    
    dynamic var privilege_name_:String?
    
    dynamic var privilege_pic_yes_:String?
    
    dynamic var privilege_pic_no_:String?
    
    dynamic var privilege_summary_:String?
    
    
    func setInfo(_ info: CenturionCardServiceInfo) {
        privilege_bg_ = info.privilege_bg_
        
        privilege_details_ = info.privilege_details_
        
        privilege_id_ = info.privilege_id_
        
        privilege_lv_ = info.privilege_lv_
        
        privilege_name_ = info.privilege_name_
        
        privilege_pic_yes_ = info.privilege_pic_yes_
        
        privilege_pic_no_ = info.privilege_pic_no_
        
        privilege_summary_ = info.privilege_summary_
        
    }
    
}
