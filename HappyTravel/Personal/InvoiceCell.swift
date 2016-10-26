//
//  InvoiceCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class InvoiceCell: UITableViewCell {
    
    var dateFormatter = NSDateFormatter()
    
    var userInfo:UserInfo?
    
    var msgInfo:PushMessage?
    
    var hodometerInfo:HodometerInfo?
    
    let tags = ["selectBtn": 1001,
                "nameLab": 1002,
                "titleLab": 1003,
                "priceLab": 1004,
                "timeLab": 1005,
                "typeLab": 1006,
                "bottomLine": 1007]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.whiteColor()
        backgroundColor = UIColor.clearColor()
        
        var selectBtn = contentView.viewWithTag(tags["selectBtn"]!) as? UIButton
        if selectBtn == nil {
            selectBtn = UIButton()
            selectBtn?.tag = tags["selectBtn"]!
            selectBtn?.backgroundColor = UIColor.clearColor()
            selectBtn?.setImage(UIImage.init(named: "service-unselect"), forState: .Normal)
            selectBtn?.setImage(UIImage.init(named: "service-selected"), forState: .Selected)
            contentView.addSubview(selectBtn!)
            selectBtn?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView).offset(20)
                make.top.equalTo(contentView).offset(10)
                make.width.equalTo(20)
                make.height.equalTo(20)
            })
        }
        
        var nameLab = contentView.viewWithTag(tags["nameLab"]!) as? UILabel
        if nameLab == nil {
            nameLab = UILabel()
            nameLab?.tag = tags["nameLab"]!
            nameLab?.backgroundColor = UIColor.clearColor()
            nameLab?.textAlignment = .Left
            nameLab?.font = UIFont.systemFontOfSize(15)
            contentView.addSubview(nameLab!)
            nameLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(selectBtn!.snp_right).offset(10)
                make.centerY.equalTo(selectBtn!.snp_centerY)
            })
        }
        nameLab?.text = "PAPI酱"
        
        var titleLab = contentView.viewWithTag(tags["titleLab"]!) as? UILabel
        if titleLab == nil {
            titleLab = UILabel()
            titleLab?.tag = tags["titleLab"]!
            titleLab?.backgroundColor = UIColor.clearColor()
            titleLab?.textAlignment = .Left
            titleLab?.font = UIFont.systemFontOfSize(15)
            contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(nameLab!.snp_right).offset(10)
                make.centerY.equalTo(selectBtn!.snp_centerY)
            })
        }
        titleLab?.text = "全天服务"

        var priceLab = contentView.viewWithTag(tags["priceLab"]!) as? UILabel
        if priceLab == nil {
            priceLab = UILabel()
            priceLab?.tag = tags["priceLab"]!
            priceLab?.backgroundColor = UIColor.clearColor()
            priceLab?.textAlignment = .Right
            priceLab?.font = UIFont.systemFontOfSize(15)
            contentView.addSubview(priceLab!)
            priceLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(titleLab!.snp_right).offset(10)
                make.right.equalTo(contentView).offset(-20)
                make.centerY.equalTo(selectBtn!.snp_centerY)
            })
        }
        priceLab?.text = "1200元"

        var timeLab = contentView.viewWithTag(tags["timeLab"]!) as? UILabel
        if timeLab == nil {
            timeLab = UILabel()
            timeLab?.tag = tags["timeLab"]!
            timeLab?.backgroundColor = UIColor.clearColor()
            timeLab?.textAlignment = .Left
            timeLab?.textColor = UIColor.grayColor()
            timeLab?.font = UIFont.systemFontOfSize(13)
            contentView.addSubview(timeLab!)
            timeLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(nameLab!)
                make.top.equalTo(nameLab!.snp_bottom).offset(10)
                make.bottom.equalTo(contentView).offset(-10)
            })
        }
        timeLab?.text = "8月31日 星期六 21.15"
        
        var typeLab = contentView.viewWithTag(tags["typeLab"]!) as? UILabel
        if typeLab == nil {
            typeLab = UILabel()
            typeLab?.tag = tags["typeLab"]!
            typeLab?.backgroundColor = UIColor.clearColor()
            typeLab?.textAlignment = .Right
            typeLab?.textColor = UIColor.grayColor()
            typeLab?.font = UIFont.systemFontOfSize(13)
            contentView.addSubview(typeLab!)
            typeLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(timeLab!.snp_right)
                make.right.equalTo(priceLab!)
                make.centerY.equalTo(timeLab!)
            })
        }
        typeLab?.text = "商务游"
        
        var bottomLine = contentView.viewWithTag(tags["bottomLine"]!)
        if bottomLine == nil {
            bottomLine = UIView()
            bottomLine?.tag = tags["bottomLine"]!
            bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
            contentView.addSubview(bottomLine!)
            bottomLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(selectBtn!)
                make.bottom.equalTo(contentView)
                make.right.equalTo(contentView)
                make.height.equalTo(1)
            })
        }
        
    }
    
    func setInfo(info: HodometerInfo?, selected: Bool, last: Bool) {
        hodometerInfo = info
        
        if let selectBtn = contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
            selectBtn.selected = selected
        }
        
        if let nameLab = contentView.viewWithTag(tags["nameLab"]!) as? UILabel {
            nameLab.text = info!.to_name_!
        }
        
        if let titleLab = contentView.viewWithTag(tags["titleLab"]!) as? UILabel {
            titleLab.text = info!.service_name_!
        }
        
        if let priceLab = contentView.viewWithTag(tags["priceLab"]!) as? UILabel {
            priceLab.text = "\(info!.service_price_) 元"
        }
        
        if let timeLab = contentView.viewWithTag(tags["timeLab"]!) as? UILabel {
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            timeLab.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(info!.start_)))
        }
        
        if let typeLab = contentView.viewWithTag(tags["typeLab"]!) as? UILabel {
            typeLab.text = info!.service_type_ == 0 ? "商务游" : "高端游"
        }
        
        if let bottomLine = contentView.viewWithTag(tags["bottomLine"]!) {
            bottomLine.hidden = last
        }
        
    }
    
    func selectAction() -> Bool {
        if let selectBtn = contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
            selectBtn.selected = !selectBtn.selected
            return selectBtn.selected
        }
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
