//
//  SingleServiceInfoCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/14.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD
import XCGLogger

protocol DaysCountDelegate:NSObjectProtocol {
    
    func countsPlus(_ cell:SingleServiceInfoCell)
    func countsReduce(_ cell:SingleServiceInfoCell)
}

class SingleServiceInfoCell: UITableViewCell {
    let tags = ["selectBtn": 1001,
                "priceLab": 1002,
                "descLab": 1003,
                "plusOrReduceView":1004,
                "countLabel":1005,
                "reduceButton":1006,
                "plusButton":1007]
    
    var count = 1
    weak var delegate:DaysCountDelegate?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        var selectBtn = contentView.viewWithTag(tags["selectBtn"]!) as? UIButton
        if selectBtn == nil {
            selectBtn = UIButton()
            selectBtn?.tag = tags["selectBtn"]!
            selectBtn?.setBackgroundImage(UIImage.init(named: "service-unselect"), for: UIControlState())
            selectBtn?.setBackgroundImage(UIImage.init(named: "service-selected"), for: .selected)
            selectBtn?.backgroundColor = UIColor.clear
            contentView.addSubview(selectBtn!)
            selectBtn?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(15)
                make.top.equalTo(contentView).offset(20)
                make.width.equalTo(20)
                make.bottom.equalTo(contentView).offset(-20)
                
            })
        }
        
        var priceLab = contentView.viewWithTag(tags["priceLab"]!) as? UILabel
        if priceLab == nil {
            priceLab = UILabel()
            priceLab?.tag = tags["priceLab"]!
            priceLab?.backgroundColor = UIColor.clear
            priceLab?.textAlignment = .right
            priceLab?.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            priceLab?.font = UIFont.systemFont(ofSize: S15)
            contentView.addSubview(priceLab!)
            priceLab!.snp.makeConstraints({ (make) in
                make.right.equalTo(contentView).offset(-15)
                make.top.equalTo(selectBtn!)
                make.bottom.equalTo(selectBtn!)
                make.width.equalTo(60)
            })
        }
        
        var descLab = contentView.viewWithTag(tags["descLab"]!) as? UILabel
        if descLab == nil {
            descLab = UILabel()
            descLab?.tag = tags["descLab"]!
            descLab?.backgroundColor = UIColor.clear
            descLab?.textAlignment = .left
            descLab?.numberOfLines = 0
            descLab?.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width / 5.0 * 3
            descLab?.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            descLab?.font = UIFont.systemFont(ofSize: S15)
            contentView.addSubview(descLab!)
            descLab!.snp.makeConstraints({ (make) in
                make.left.equalTo(selectBtn!.snp.right).offset(15)
                make.top.equalTo(contentView).offset(10)
                make.bottom.equalTo(contentView).offset(-10)
            })
        }

    }
    
    

    func setupInfo(_ service:ServiceInfo,count:Int, isNormal:Bool) {
        
        if let priceLab = contentView.viewWithTag(tags["priceLab"]!) as? UILabel {
            priceLab.text = "\(Double(service.service_price_) / 100) 元"
        }

        if let descLab = contentView.viewWithTag(tags["descLab"]!) as? UILabel {
            descLab.text = "\(service.service_name_!)    \(service.service_time_!)"
        }
    }
    
    
    func plus() {
        
        guard delegate != nil else {
            
            XCGLogger.error("DaysCountDelegate: delegate为空")
            return
        }
        
        delegate!.countsPlus(self)
    }
    
    func reduce() {
        
        guard delegate != nil else {
            
            XCGLogger.error("DaysCountDelegate: delegate为空")
            return
        }
        
        delegate!.countsReduce(self)

        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
