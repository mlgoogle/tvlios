//
//  InvoiceHistoryDetailCustomCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
/// 最下面 非常规cell
class InvoiceHistoryDetailCustomCell: UITableViewCell {

    
    var titleLabel:UILabel?
    var dateLabel:UILabel?
    var dateFormatter = NSDateFormatter()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None
        accessoryType = .DisclosureIndicator
        if titleLabel == nil {
            titleLabel = UILabel()
            titleLabel?.font = UIFont.systemFontOfSize(15)
            titleLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        
            titleLabel?.textAlignment = .Left
            titleLabel?.backgroundColor = UIColor.clearColor()
           contentView.addSubview(titleLabel!)
        }
        titleLabel?.text = "所含服务（100）"
        

        
        if dateLabel == nil {
            dateLabel = UILabel()
            dateLabel?.font = UIFont.systemFontOfSize(12)
            dateLabel?.textAlignment = .Left
            dateLabel?.backgroundColor = UIColor.clearColor()
            dateLabel?.textColor = UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
            contentView.addSubview(dateLabel!)
            
        }
        dateLabel?.text = "2016.10.28 08:05-2016.10.28 08:05"
        
        addSubViewConstraints()
    }
    
    /**
     添加约束
     */
    func addSubViewConstraints() {
        
        titleLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(15)
        })
        dateLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(titleLabel!)
            make.bottom.equalTo(contentView).offset(-15)
        })
    }
    
   
    func setupData() {
        
        dateFormatter.dateFormat = "YYYY.MM.DD hh:mm"
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
/// 上面 常规cell
class InvoiceHistoryDetailNormalCell: UITableViewCell {
    
    
    var titleLabel:UILabel?
    var infoLabel:UILabel?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        if titleLabel == nil {
            titleLabel = UILabel()
            titleLabel?.backgroundColor = UIColor.clearColor()
            titleLabel?.font = UIFont.systemFontOfSize(15)
            titleLabel?.textColor =  UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
        }
        if infoLabel == nil {
            infoLabel = UILabel()
            infoLabel?.backgroundColor = UIColor.clearColor()
            infoLabel?.font = UIFont.systemFontOfSize(15)
            infoLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)

        }
        
        contentView.addSubview(titleLabel!)
        contentView.addSubview(infoLabel!)
        
        addSubViewConstraints()
    }
    
    
    
    func setTitleLabelText(text:String) {
        
        titleLabel?.text = text
    }
    
    func setInfoLabelText(text:String) {
        infoLabel?.text = text
    }
    
    
    
    /**
     添加约束
     */
    func addSubViewConstraints() {
        titleLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(contentView).offset(10)
            make.centerY.equalTo(contentView)
        })
        infoLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(90)
            make.centerY.equalTo(titleLabel!)
        })
    
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
