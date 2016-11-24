//
//  SkillInfo.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/26.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

enum SkillType : Int {
    
    case Common = 1
    case Business = 2
    
}

class SkillInfo: Object {
    
    dynamic var skill_id_ = 0
    
    dynamic var skill_name_:String?
    
    dynamic var skill_type_ = SkillType.Common.rawValue
    
    dynamic var labelWidth:Float = 0.0
    
    func setInfo(info: SkillInfo) {
        skill_id_ = info.skill_id_
        
        skill_name_ = info.skill_name_
        
        skill_type_ = info.skill_type_
        
        labelWidth = info.labelWidth
    }
    
}

