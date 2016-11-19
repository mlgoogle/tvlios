//
//  AppointmentDetailCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/10.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import RealmSwift

class AppointmentDetailCell: UITableViewCell {
    
    
    var serviceTypes = [0:"未指定", 1:"高端游", 2:"商务游"]

    lazy private var dateFormatter:NSDateFormatter = {
        var dateFomatter = NSDateFormatter()
        dateFomatter.dateFormat = "YYYY/MM/dd"
        
        return dateFomatter
    }()
    
    lazy private var iconImageView:UIImageView = {
       let imageView = UIImageView()
        imageView.layer.cornerRadius = AtapteWidthValue(45) / 2
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "default-head")
        return imageView
    }()
    var nicknameLabel:UILabel = {
       let label = UILabel()
        label.text = "二郎神"
        label.font = UIFont.systemFontOfSize(S15)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = colorWithHexString("#131f32")
        return label
    }()
    var serviceTypeLabel:UILabel = {
       
        let label = UILabel()
        label.text = "【二郎神】"
        label.font = UIFont.systemFontOfSize(S15)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = colorWithHexString("#131f32")
        return label
    }()
    var dateLabel:UILabel = {
       let label = UILabel()
                label.text = "2016/03/04 - 2016/03/04"
        label.font = UIFont.systemFontOfSize(S15)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = colorWithHexString("#131f32")
        return label
    }()
    var cityLabel:UILabel = {
        let label = UILabel()
        label.text = "杭州"
        label.font = UIFont.systemFontOfSize(S12)
        label.textColor = colorWithHexString("#999999")
        return label
    }()
    var cityImageView:UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "map_meet")
        return imageView
    }()
    var detailIconImageView:UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "appointment-detail")
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        contentView.addSubview(iconImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(serviceTypeLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(cityImageView)
        contentView.addSubview(cityLabel)
        contentView.addSubview(detailIconImageView)
        addSubviewContraints()
    }
    
    /**
     添加约束
     */
    func addSubviewContraints() {
        iconImageView.snp_makeConstraints { (make) in
            make.top.equalTo(contentView).offset(AtapteHeightValue(13))
            make.left.equalTo(contentView).offset(AtapteWidthValue(15))
            make.height.equalTo(AtapteWidthValue(45))
            make.width.equalTo(AtapteHeightValue(45))
        }
        nicknameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(contentView).offset(AtapteHeightValue(24))
            make.left.equalTo(iconImageView.snp_right).offset(AtapteWidthValue(20))
        }
        serviceTypeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp_left).offset(-7)
            make.top.equalTo(nicknameLabel.snp_bottom).offset(AtapteHeightValue(9))
        }
        dateLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel)
            make.top.equalTo(serviceTypeLabel.snp_bottom).offset(AtapteHeightValue(13))
        }
        cityImageView.snp_makeConstraints { (make) in
            make.left.equalTo(dateLabel)
            make.width.equalTo(22 / 1.5)
            make.height.equalTo(30 / 1.5)
            make.top.equalTo(dateLabel.snp_bottom).offset(AtapteHeightValue(17))
            make.bottom.equalTo(contentView).offset(AtapteHeightValue(0))
        }
        cityLabel.snp_makeConstraints { (make) in
            make.left.equalTo(cityImageView.snp_right).offset(10)
            make.centerY.equalTo(cityImageView)
        }
        detailIconImageView.snp_makeConstraints { (make) in
            make.top.equalTo(nicknameLabel)
            make.right.equalTo(contentView.snp_right).offset(AtapteWidthValue(-15))
        }
        
    }
    
    
    
    
    /**
     详情顶部处理  
     */
    func hideCityInfo() {

        cityImageView.snp_remakeConstraints { (make) in
            make.left.equalTo(dateLabel)
            make.width.equalTo(22 / 1.5)
            make.height.equalTo(30 / 1.5)
            make.top.equalTo(dateLabel.snp_bottom).offset(AtapteHeightValue(17))
            make.bottom.equalTo(contentView).offset(AtapteHeightValue(-10))
        }
    }
    /**
     之前逻辑有问题 弃用 2016年11月16日19:41:52
     - parameter info:
     */
    func setupDataWithInfo(info:UserInfo) {
        

        iconImageView.kf_setImageWithURL(NSURL(string: (info.headUrl)!), placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        nicknameLabel.text = info.nickname
        
    }
    
    
    /**
     
     预约界面使用时 数据填充
     - parameter info:
     */
    func setApponimentInfo(info:AppointmentInfo) {
        nicknameLabel.text = info.to_name_
        iconImageView.kf_setImageWithURL(NSURL(string: (info.to_head_)!), placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)


        serviceTypeLabel.text =  "【" + serviceTypes[info.service_type_]! + "】"
        let startTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(info.start_time_)))
        let endTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(info.end_time_)))
        dateLabel.text = startTime + "-" + endTime
        

            
            let results = DataManager.getData(CityInfo.self, filter: "cityCode = \(info.city_code_)") as! Results<CityInfo>
            
            if let cityInfo = results.first  {
                cityLabel.text = cityInfo.cityName
            }
            
    
    }
    
    
    /**
     
     邀约界面使用时 数据填充
     - parameter info:
     */
    func setServiceInfo(info:HodometerInfo) {
        
        nicknameLabel.text = info.to_name_
        iconImageView.kf_setImageWithURL(NSURL(string: (info.to_head_)!), placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        serviceTypeLabel.text = "【" + serviceTypes[info.service_type_]! + "】"
        let startTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(info.start_)))
        let endTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(info.start_) + Double(3600 * 24 * info.days_)))

    
        dateLabel.text = startTime + "-" + endTime
        cityLabel.text = info.order_addr
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
