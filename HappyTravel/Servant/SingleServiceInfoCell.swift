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
    
    func countsPlus(cell:SingleServiceInfoCell)
    func countsReduce(cell:SingleServiceInfoCell)
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
        selectionStyle = .None
        var selectBtn = contentView.viewWithTag(tags["selectBtn"]!) as? UIButton
        if selectBtn == nil {
            selectBtn = UIButton()
            selectBtn?.tag = tags["selectBtn"]!
            selectBtn?.setBackgroundImage(UIImage.init(named: "service-unselect"), forState: .Normal)
            selectBtn?.setBackgroundImage(UIImage.init(named: "service-selected"), forState: .Selected)
            selectBtn?.backgroundColor = UIColor.clearColor()
            contentView.addSubview(selectBtn!)
            selectBtn?.snp_makeConstraints(closure: { (make) in
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
            priceLab?.backgroundColor = UIColor.clearColor()
            priceLab?.textAlignment = .Right
            priceLab?.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            priceLab?.font = UIFont.systemFontOfSize(S15)
            contentView.addSubview(priceLab!)
            priceLab!.snp_makeConstraints(closure: { (make) in
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
            descLab?.backgroundColor = UIColor.clearColor()
            descLab?.textAlignment = .Left
            descLab?.numberOfLines = 0
            descLab?.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.size.width / 5.0 * 3
            descLab?.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            descLab?.font = UIFont.systemFontOfSize(S15)
            contentView.addSubview(descLab!)
            descLab!.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(selectBtn!.snp_right).offset(15)
                make.top.equalTo(contentView).offset(10)
                make.bottom.equalTo(contentView).offset(-10)
            })
        }
        
        var plusOrReduceView = contentView.viewWithTag(tags["plusOrReduceView"]!)
        if  plusOrReduceView == nil {
            plusOrReduceView = UIView()
            plusOrReduceView?.tag = tags["plusOrReduceView"]!
            plusOrReduceView?.backgroundColor = UIColor.clearColor()
            contentView.addSubview(plusOrReduceView!)
            plusOrReduceView?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo((descLab?.snp_right)!)
                make.right.equalTo((priceLab?.snp_left)!)
                make.top.equalTo((descLab)!)
                make.bottom.equalTo(descLab!)
            })
            
        }

        var plusButton = contentView.viewWithTag(tags["plusButton"]!) as? UIButton
        if plusButton == nil {
            plusButton = UIButton(type: .Custom)
            plusButton?.tag = tags["plusButton"]!
            plusButton!.setTitleColor(UIColor.redColor(), forState: .Normal)
            plusOrReduceView?.addSubview(plusButton!)
            plusButton?.backgroundColor = UIColor.clearColor()
            plusButton?.layer.borderWidth = 1
            plusButton?.layer.cornerRadius = 15
            plusButton?.layer.borderColor = UIColor.redColor().CGColor
            plusButton?.setTitle("+", forState: .Normal)
            plusButton?.addTarget(self, action: #selector(SingleServiceInfoCell.plus), forControlEvents: .TouchUpInside)
            plusButton!.snp_makeConstraints(closure: { (make) in
                
                make.right.equalTo((plusOrReduceView?.snp_right)!)
                make.width.equalTo(30)
                make.height.equalTo(30)
                make.top.equalTo(plusOrReduceView!)
            })
            
            
        }
        var countLabel  = contentView.viewWithTag(tags["countLabel"]!) as? UILabel
        
        if countLabel == nil {
            countLabel = UILabel()
            countLabel!.text = "1 天"
            countLabel?.tag = tags["countLabel"]!
            countLabel!.textAlignment = .Center
            countLabel!.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            countLabel!.font = UIFont.systemFontOfSize(S15)
            plusOrReduceView?.addSubview(countLabel!)
            countLabel!.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(descLab!)
                make.bottom.equalTo(descLab!)
                make.right.equalTo((plusButton?.snp_left)!).offset(-5)
            })
        }

        
        var reduceButton = contentView.viewWithTag(tags["reduceButton"]!) as? UIButton
        
        if reduceButton == nil {
            reduceButton = UIButton(type: .Custom)
            reduceButton?.tag = tags["reduceButton"]!
            reduceButton?.backgroundColor = UIColor.clearColor()
            reduceButton?.setTitle("-", forState: .Normal)
            reduceButton?.layer.borderWidth = 1
            reduceButton?.layer.cornerRadius = 15
            reduceButton?.layer.borderColor = UIColor.redColor().CGColor
            reduceButton!.addTarget(self, action: #selector(SingleServiceInfoCell.reduce), forControlEvents: .TouchUpInside)
            reduceButton!.setTitleColor(UIColor.redColor(), forState: .Normal)
            plusOrReduceView?.addSubview(reduceButton!)
            reduceButton!.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(30)
                make.height.equalTo(30)
                make.right.equalTo((countLabel?.snp_left)!).offset(-5)
                make.top.equalTo(plusOrReduceView!)
            })
        }
    }
    
    

    func setupInfo(service:ServiceInfo,count:Int, isNormal:Bool) {
        

        if let descLab = contentView.viewWithTag(tags["descLab"]!) as? UILabel {
            descLab.text = "\(service.service_name_!)    \(service.service_time_!)"
        }
        guard isNormal else {
            let plusOrReduceView = contentView.viewWithTag(tags["plusOrReduceView"]!)
            
            plusOrReduceView?.hidden = true
            return
        }
        if let countLabel  = contentView.viewWithTag(tags["countLabel"]!) as? UILabel {
            countLabel.text = String(count) + " 天"
        }
        if let priceLab = contentView.viewWithTag(tags["priceLab"]!) as? UILabel {
            priceLab.text = "\(service.service_price_ * count) 元"
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
