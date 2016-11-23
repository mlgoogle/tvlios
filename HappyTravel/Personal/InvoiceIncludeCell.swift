//
//  InvoiceIncludeCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class InvoiceIncludeCell: UITableViewCell {

    
    var nicknameLabel:UILabel?
    var serviceNameLabel:UILabel?
    var serviceDateLabel:UILabel?
    var serviceTypeLabel:UILabel?
    var servicePriceLabel:UILabel?
    var bottomLine:UIView?

    var serviceTypes = [0:"未指定", 1:"高端游", 2:"商务游"]
     var dateFormatter = DateFormatter()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        if nicknameLabel == nil {
            nicknameLabel = UILabel()
            nicknameLabel?.backgroundColor = UIColor.clear
            nicknameLabel?.textAlignment = .left
            nicknameLabel?.font = UIFont.systemFont(ofSize: S15)
            nicknameLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        }

        nicknameLabel?.text = "二郎神"

        
        if serviceNameLabel == nil {
            serviceNameLabel = UILabel()
            serviceNameLabel?.backgroundColor = UIColor.clear
            serviceNameLabel?.textAlignment = .left
            serviceNameLabel?.font = UIFont.systemFont(ofSize: S15)
            serviceNameLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        }

        serviceNameLabel?.text = "服务服务"
        
        if servicePriceLabel == nil {
            servicePriceLabel = UILabel()
            servicePriceLabel?.backgroundColor = UIColor.clear
            servicePriceLabel?.textAlignment = .left
            servicePriceLabel?.font = UIFont.systemFont(ofSize: S15)
            servicePriceLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        }
        servicePriceLabel?.text = "120.00元"
        
        if serviceDateLabel == nil {
            serviceDateLabel = UILabel()
            serviceDateLabel?.backgroundColor = UIColor.clear
            serviceDateLabel?.textAlignment = .right
            serviceDateLabel?.font = UIFont.systemFont(ofSize: S12)
            serviceDateLabel?.textColor = UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
        }
        serviceDateLabel?.text = "10月28日 周六 21：25"
        
        if serviceTypeLabel == nil {
            
            serviceTypeLabel = UILabel()
            serviceTypeLabel?.backgroundColor = UIColor.clear
            serviceTypeLabel?.textAlignment = .right
            serviceTypeLabel?.font = UIFont.systemFont(ofSize: S12)
            serviceTypeLabel?.textColor = UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
            
        }
        serviceTypeLabel?.text = "商务游"
        
        if bottomLine == nil {
            
            bottomLine = UIView()
            bottomLine?.backgroundColor = UIColor.init(decR: 231, decG: 231, decB: 231, a: 1)

        }
        
        
        contentView.addSubview(nicknameLabel!)
        contentView.addSubview(serviceNameLabel!)
        contentView.addSubview(serviceDateLabel!)
        contentView.addSubview(serviceTypeLabel!)
        contentView.addSubview(servicePriceLabel!)
        contentView.addSubview(bottomLine!)

    }
    
    /**
     添加约束
     */
    func addSubViewConstraints() {
        nicknameLabel?.snp_makeConstraints({ (make) in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(13)
            
        })
        
        serviceNameLabel?.snp_makeConstraints({ (make) in
            make.left.equalTo(nicknameLabel!.snp_right).offset(10)
            make.centerY.equalTo(nicknameLabel!)
        })
        
        serviceDateLabel?.snp_makeConstraints({ (make) in
            make.left.equalTo(nicknameLabel!)
            make.bottom.equalTo(contentView).offset(-10)
        })
        
        servicePriceLabel?.snp_makeConstraints({ (make) in
            make.centerY.equalTo(nicknameLabel!)
            make.right.equalTo(contentView).offset(-10)
        })
        serviceTypeLabel?.snp_makeConstraints({ (make) in
            make.right.equalTo(servicePriceLabel!)
            make.centerY.equalTo(serviceDateLabel!)
        })
        bottomLine?.snp_makeConstraints({ (make) in
            make.left.equalTo(nicknameLabel!)
            make.bottom.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(1)
        })
        
    }
    
    override func layoutSubviews() {
        addSubViewConstraints()
    }
    /**
     数据填充
     
     - parameter info:
     - parameter isLast: 最后一个需要隐藏分割线
     */
    func setupData(_ info:InvoiceServiceInfo, isLast:Bool) {
        if nicknameLabel != nil {
            
            nicknameLabel?.text = info.nick_name_
        }
        if serviceNameLabel != nil {
            
            serviceNameLabel?.text = info.service_name_
        }
        if serviceTypeLabel != nil {
            
            serviceTypeLabel?.text = info.service_type_
        }
        if servicePriceLabel != nil {
            
            servicePriceLabel?.text = String(info.service_price_) + "元"
        }
        if serviceDateLabel != nil {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            serviceDateLabel?.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(info.order_time_)))
        }
        if bottomLine != nil {
            bottomLine?.isHidden = isLast
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
