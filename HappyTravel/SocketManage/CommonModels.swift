//
//  CommonModels.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/6.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift


class SkillModel: Object {
    
    dynamic var skill_id_:Int = 0
    
    dynamic var skill_name_:String?
    
    dynamic var skill_type_ = 0
    
    var labelWidth:Float {
        let string:NSString = skill_name_!
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        let rect = string.boundingRectWithSize(CGSizeMake(0, 24),
                                               options: options,
                                               attributes: [NSFontAttributeName : UIFont.systemFontOfSize(AtapteWidthValue(12))],
                                               context: nil)
        let labelWidth = Float(rect.size.width) + 30
        return labelWidth
    }
}

class SkillsModel: Object {
    
    let skills_list_ = List<SkillModel>()
}
