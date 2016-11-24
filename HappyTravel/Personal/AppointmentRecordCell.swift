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
    lazy fileprivate var endTimeLabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: AtapteWidthValue(13))
        return label
    }()
    
    lazy fileprivate var lineView:UIView = {
       
        let view = UIView()
        view.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
        return view
    }()
    /**
     代订信息
     */
    lazy fileprivate var infoLabel:UILabel = {
        
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: AtapteWidthValue(15))
        label.textAlignment = .center
        label.textColor = UIColor.init(red: 245/255.0, green: 146/255.0, blue: 49/255.0, alpha: 1)
        return label
    }()
    lazy fileprivate var infoView:UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
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
        
        
        timeLab.snp.remakeConstraints { (make) in
            make.top.equalTo(serviceTitleLab.snp.bottom).offset(11)
            make.left.equalTo(nickNameLab)
        }
        
        endTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLab.snp.bottom).offset(AtapteHeightValue(5))
            make.left.equalTo(timeLab)
        }
        
        statusLabel.snp.remakeConstraints { (make) in
            make.bottom.equalTo(endTimeLabel)
            make.right.equalTo(view).offset(AtapteWidthValue(-10))
        }
        
        payLabel.snp.remakeConstraints { (make) in
            
            make.bottom.equalTo(statusLabel.snp.top).offset(AtapteHeightValue(-5))
            make.right.equalTo(view).offset(AtapteWidthValue(-10))
            
        }
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(endTimeLabel.snp.bottom).offset(AtapteHeightValue(10))
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(infoView)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(1)
        }
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(AtapteHeightValue(10))
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(infoView.snp.bottom).offset(-10)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setRecordInfo(_ recordInfo: AppointmentInfo?) {
        let view = contentView.viewWithTag(101)
        if let headView = view!.viewWithTag(1001) as? UIImageView {
            if recordInfo?.to_head_ != nil {
                
                headView.kf.setImage(with: URL(string: (recordInfo?.to_head_)!), placeholder: UIImage(named: "touxiang_women"), options: nil, progressBlock: nil, completionHandler: nil)
//                headView.kf_setImageWithURL(URL(string: (recordInfo?.to_head_)!), placeholderImage: UIImage(named: "touxiang_women"), optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
//                    
//                })

            } else {
                
                headView.image = UIImage(named: "touxiang_women")
            }
        }
        
        if let nickNameLab = view!.viewWithTag(1002) as? UILabel {
            
            if recordInfo?.status_ == 2 || recordInfo?.status_ == 4 {
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
            dateFormatter.dateStyle = .short
            timeLab.text = "开始 : " + dateFormatter.string(from: Date(timeIntervalSince1970: Double((recordInfo?.start_time_)!))) + " 09:00-21:00"
            endTimeLabel.text = "结束 : " + dateFormatter.string(from: Date(timeIntervalSince1970: Double((recordInfo?.end_time_)!))) + " 09:00-21:00"
        }
        
        if let statusLab = view!.viewWithTag(1006) as? UILabel {
            statusLab.text = statusDict[OrderStatus(rawValue: (recordInfo?.status_)!)!]
            statusLab.textColor = statusColor[OrderStatus(rawValue: (recordInfo?.status_)!)!]
        }
        /**
         *  根据是否代订 更改约束
         */
        if recordInfo?.is_other_ == 1  {
         
            infoView.snp.remakeConstraints { (make) in
                make.top.equalTo(endTimeLabel.snp.bottom).offset(AtapteHeightValue(10))
                make.left.equalTo(view!)
                make.right.equalTo(view!)
                make.bottom.equalTo(view!.snp.bottom)
            }
            infoView.isHidden = false
            infoLabel.text = "代订 : " + (recordInfo?.other_name_)! + " " + (recordInfo?.other_phone_)!
        } else {
            infoView.isHidden = true
            infoView.snp.remakeConstraints({ (make) in
                make.top.equalTo(endTimeLabel.snp.bottom).offset(AtapteHeightValue(10))
                make.left.equalTo(view!)
                make.right.equalTo(view!)
                make.height.equalTo(0.001)
                make.bottom.equalTo(view!.snp.bottom)
            })
        }
        
    }

}
