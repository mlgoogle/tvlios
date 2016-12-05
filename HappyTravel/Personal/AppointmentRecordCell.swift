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



    /**
     结束时间
     */
    lazy private var endTimeLabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Left
        label.textColor = UIColor.grayColor()
        label.font = UIFont.systemFontOfSize(AtapteWidthValue(13))
        return label
    }()
    
    lazy private var lineView:UIView = {
       
        let view = UIView()
        view.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
        return view
    }()
    /**
     代订信息
     */
    lazy private var infoLabel:UILabel = {
        
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(AtapteWidthValue(15))
        label.textAlignment = .Center
        label.textColor = UIColor.init(red: 245/255.0, green: 146/255.0, blue: 49/255.0, alpha: 1)
        return label
    }()
    lazy private var infoView:UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 父类UI检测 
        guard let view = contentView.viewWithTag(101) else { return }
        guard let timeLab = view.viewWithTag(1005) as? UILabel else { return }
        guard let nickNameLab = view.viewWithTag(1002) as? UILabel else { return }
        guard let serviceTitleLab = view.viewWithTag(1003) as? UILabel else { return }
        guard let payLabel = view.viewWithTag(1004) as? UILabel else { return }
        guard let statusLabel = view.viewWithTag(1006) as? UILabel else { return }

        view.addSubview(infoView)
        view.addSubview(endTimeLabel)
        infoView.addSubview(lineView)
        infoView.addSubview(infoLabel)
        
        
        timeLab.snp_remakeConstraints { (make) in
            make.top.equalTo(serviceTitleLab.snp_bottom).offset(11)
            make.left.equalTo(nickNameLab)
        }
        
        endTimeLabel.snp_makeConstraints { (make) in
            make.top.equalTo(timeLab.snp_bottom).offset(AtapteHeightValue(5))
            make.left.equalTo(timeLab)
        }
        
        statusLabel.snp_remakeConstraints { (make) in
            make.bottom.equalTo(endTimeLabel)
            make.right.equalTo(view).offset(AtapteWidthValue(-10))
        }
        
        payLabel.snp_remakeConstraints { (make) in
            
            make.bottom.equalTo(statusLabel.snp_top).offset(AtapteHeightValue(-5))
            make.right.equalTo(view).offset(AtapteWidthValue(-10))
            
        }
        infoView.snp_makeConstraints { (make) in
            make.top.equalTo(endTimeLabel.snp_bottom).offset(AtapteHeightValue(10))
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        lineView.snp_makeConstraints { (make) in
            make.top.equalTo(infoView)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(1)
        }
        infoLabel.snp_makeConstraints { (make) in
            make.top.equalTo(lineView.snp_bottom).offset(AtapteHeightValue(10))
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(infoView.snp_bottom).offset(-10)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setRecordInfo(recordInfo: AppointmentInfo?) {
        let view = contentView.viewWithTag(101)
        if let headView = view!.viewWithTag(1001) as? UIImageView {
            if recordInfo?.to_head_ != nil {
                
                headView.kf_setImageWithURL(NSURL(string: (recordInfo?.to_head_)!), placeholderImage: UIImage(named: "touxiang_women"), optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                    
                })

            } else {
                
                headView.image = UIImage(named: "touxiang_women")
            }
        }
        
        if let nickNameLab = view!.viewWithTag(1002) as? UILabel {
            
            if recordInfo?.status_ > 2 {
                nickNameLab.text = recordInfo?.service_name_
            } else {
                
                nickNameLab.text = DataManager.currentUser?.nickname
            }
        }
        
        if let serviceTitleLab = view!.viewWithTag(1003) as? UILabel {
            
            if let cityCode = recordInfo?.city_code_ {
                
                let results = DataManager.getData(CityInfo.self, filter: "cityCode = \(cityCode)") as! Results<CityInfo>
                
                if let cityInfo = results.first  {
                    serviceTitleLab.text = cityInfo.cityName
                }
                
            }
            
        }
        
        if let payLab = view!.viewWithTag(1004) as? UILabel {
            payLab.text = recordInfo?.order_price_ == -1 ? "待定" : String(Double((recordInfo?.order_price_)!) / 100)
        }
        
        if let timeLab = view!.viewWithTag(1005) as? UILabel {
            var serviceTime = "09:00-21:00"
            
            if recordInfo?.status_ > 2 {
              
                serviceTime = getTime((recordInfo?.service_start_)!, end: (recordInfo?.service_end_)!)
            }
            dateFormatter.dateStyle = .ShortStyle

            timeLab.text = "开始 : " + dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double((recordInfo?.start_time_)!))) + " " + serviceTime
            endTimeLabel.text = "结束 : " + dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double((recordInfo?.end_time_)!))) + " " + serviceTime
        }
        
        if let statusLab = view!.viewWithTag(1006) as? UILabel {
            statusLab.text = statusDict[OrderStatus(rawValue: (recordInfo?.status_)!)!]
            statusLab.textColor = statusColor[OrderStatus(rawValue: (recordInfo?.status_)!)!]
        }
        /**
         *  根据是否代订 更改约束
         */
        if recordInfo?.is_other_ == 1  {
         
            infoView.snp_remakeConstraints { (make) in
                make.top.equalTo(endTimeLabel.snp_bottom).offset(AtapteHeightValue(10))
                make.left.equalTo(view!)
                make.right.equalTo(view!)
                make.bottom.equalTo(view!.snp_bottom)
            }
            infoView.hidden = false
            infoLabel.text = "代订 : " + (recordInfo?.other_name_)! + " " + (recordInfo?.other_phone_)!
        } else {
            infoView.hidden = true
            infoView.snp_remakeConstraints(closure: { (make) in
                make.top.equalTo(endTimeLabel.snp_bottom).offset(AtapteHeightValue(10))
                make.left.equalTo(view!)
                make.right.equalTo(view!)
                make.height.equalTo(0.001)
                make.bottom.equalTo(view!.snp_bottom)
            })
        }
        
    }

    
    func getTime(start:Int, end:Int)->String {
        dateFormatter.dateFormat = "HH:mm"

        
        let startTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(start)))
        let endTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(end)))
        
        return "\(startTime)-\(endTime)"
        
    }
    
}
