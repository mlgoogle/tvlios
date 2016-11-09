//
//  AppointmentRecordCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/8.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

class AppointmentRecordCell: DistanceOfTravelCell {
    
    func setRecordInfo(recordInfo: AppointmentInfo?) {
        let view = contentView.viewWithTag(101)
        if let headView = view!.viewWithTag(1001) as? UIImageView {
            headView.image = UIImage(named: "default-head")
        }
        
        if let nickNameLab = view!.viewWithTag(1002) as? UILabel {
//            if recordInfo?.is_other_ == 1 {
//                
//                nickNameLab.text = recordInfo?.other_name_
//
//                
//            } else {
//                
//                nickNameLab.text = DataManager.currentUser?.nickname
//            }
            nickNameLab.text = "预约服务"
        }
        
        if let serviceTitleLab = view!.viewWithTag(1003) as? UILabel {
            
            if let cityCode = recordInfo?.city_code_ {
                
                let results = DataManager.getData(CityInfo.self, filter: "cityCode = \(cityCode)") as! Results<CityInfo>
                
                
                
                if let cityInfo = results.first  {
                    
                    if recordInfo?.is_other_ == 1 {
                        
                        serviceTitleLab.text = cityInfo["cityName"] as! String + "(代订)"
                    } else {
                        
                        serviceTitleLab.text = cityInfo["cityName"] as? String
                    }
                }
                
            }
            
            
            
        }
        
        if let payLab = view!.viewWithTag(1004) as? UILabel {
            payLab.text = "待定"
        }
        
        if let timeLab = view!.viewWithTag(1005) as? UILabel {
            dateFormatter.dateStyle = .ShortStyle
//            dateFormatter.timeStyle = .ShortStyle
            timeLab.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double((recordInfo?.start_time_)!)))
        }
        
        if let statusLab = view!.viewWithTag(1006) as? UILabel {
                        statusLab.text = statusDict[OrderStatus(rawValue: (recordInfo?.status_)!)!]
                        statusLab.textColor = statusColor[OrderStatus(rawValue: (recordInfo?.status_)!)!]
        }
    }

}
