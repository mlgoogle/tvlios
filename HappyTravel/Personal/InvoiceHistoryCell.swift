//
//  InvoiceHistoryCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

//public let ScreenScale = UIScreen.mainScreen().bounds.size.width / 375.0
import UIKit

class InvoiceHistoryCell: UITableViewCell {

    var priceLabel:UILabel?
    var dateLabel:UILabel?
    var statusLabel:UILabel?
    var bottomLine:UIView?
    var dateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override  init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.backgroundColor = UIColor.white
        accessoryType = .disclosureIndicator
        
        if priceLabel == nil {
            priceLabel = UILabel()
            priceLabel?.backgroundColor = UIColor.clear
            priceLabel?.textAlignment = .left
            priceLabel?.textColor = UIColor(red: 184 / 255.0, green: 37 / 255.0, blue: 37 / 255.0, alpha: 1.0)
            priceLabel?.font = UIFont.systemFont(ofSize: S15)
            contentView.addSubview(priceLabel!)
            priceLabel?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView).offset(20)
                make.top.equalTo(contentView).offset(13)
            })
        }
        priceLabel!.text = "1111111元"

        if dateLabel == nil {
            dateLabel = UILabel()
            dateLabel?.backgroundColor = UIColor.clear
            dateLabel?.textAlignment = .left
            dateLabel?.textColor = UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
            dateLabel?.font = UIFont.systemFont(ofSize: S12)
            contentView.addSubview(dateLabel!)
            dateLabel?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(priceLabel!)
                make.bottom.equalTo(contentView).offset(-10)
            })
            
        }
     
        dateLabel?.text = "10月27日 周四 12:01"
        
        if statusLabel == nil {
            statusLabel = UILabel()
            statusLabel?.backgroundColor = UIColor.clear
            statusLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
            statusLabel?.textAlignment = .center
            statusLabel?.font = UIFont.systemFont(ofSize: S13)
            statusLabel?.layer.borderWidth = 1
            statusLabel?.layer.borderColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0).cgColor
            statusLabel?.layer.cornerRadius = 12
            contentView.addSubview(statusLabel!)
            statusLabel?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(contentView).offset(-10)
                make.centerY.equalTo(contentView)
                make.width.equalTo(60)
                make.height.equalTo(25)
            })
        }
        statusLabel?.text = "待开票"

        
        if bottomLine == nil {
            
            bottomLine = UIView()
            bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)
            contentView.addSubview(bottomLine!)
            bottomLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(priceLabel!)
                make.bottom.equalTo(contentView)
                make.right.equalTo(contentView)
                make.height.equalTo(1)
            })
        }
        
        
        
    }
    
    
    
    
    /**
     
     数据填充
     - parameter info:
     - parameter last: 最后一个需隐藏
     */
    func setupDatawith(_ info:InvoiceHistoryInfo?,last:Bool) {
        if priceLabel != nil {

            priceLabel?.text = String(Double(info!.invoice_price_) / 100) + "元"
        }
        
        if dateLabel != nil {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateLabel?.text =  dateFormatter.string(from: Date(timeIntervalSince1970: Double(info!.invoice_time_)))
        }
        
        if statusLabel != nil {
            statusLabel?.text = info!.invoice_status_ == 0 ? "待开票" : "已开票"
        }
        
        if bottomLine != nil {
            
            bottomLine?.isHidden = last
        }
        

    }
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
