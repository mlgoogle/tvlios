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

    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        if nicknameLabel == nil {
            nicknameLabel = UILabel()
            nicknameLabel?.backgroundColor = UIColor.clearColor()
            nicknameLabel?.textAlignment = .Left
            nicknameLabel?.font = UIFont.systemFontOfSize(15)
            nicknameLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        }

        nicknameLabel?.text = "二郎神"

        
        if serviceNameLabel == nil {
            serviceNameLabel = UILabel()
            serviceNameLabel?.backgroundColor = UIColor.clearColor()
            serviceNameLabel?.textAlignment = .Left
            serviceNameLabel?.font = UIFont.systemFontOfSize(15)
            serviceNameLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        }

        serviceNameLabel?.text = "服务服务"
        
        if servicePriceLabel == nil {
            servicePriceLabel = UILabel()
            servicePriceLabel?.backgroundColor = UIColor.clearColor()
            servicePriceLabel?.textAlignment = .Left
            servicePriceLabel?.font = UIFont.systemFontOfSize(15)
            servicePriceLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        }
        servicePriceLabel?.text = "120.00元"
        
        if serviceDateLabel == nil {
            serviceDateLabel = UILabel()
            serviceDateLabel?.backgroundColor = UIColor.clearColor()
            serviceDateLabel?.textAlignment = .Right
            serviceDateLabel?.font = UIFont.systemFontOfSize(12)
            serviceDateLabel?.textColor = UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
        }
        serviceDateLabel?.text = "10月28日 周六 21：25"
        
        if serviceTypeLabel == nil {
            
            serviceTypeLabel = UILabel()
            serviceTypeLabel?.backgroundColor = UIColor.clearColor()
            serviceTypeLabel?.textAlignment = .Right
            serviceTypeLabel?.font = UIFont.systemFontOfSize(12)
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

        addSubViewConstraints()
    }
    
    /**
     添加约束
     */
    func addSubViewConstraints() {
        nicknameLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(13)
            
        })
        
        serviceNameLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(nicknameLabel!.snp_right).offset(10)
            make.centerY.equalTo(nicknameLabel!)
        })
        
        serviceDateLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(nicknameLabel!)
            make.bottom.equalTo(contentView).offset(-10)
        })
        
        servicePriceLabel?.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(nicknameLabel!)
            make.right.equalTo(contentView).offset(-10)
        })
        serviceTypeLabel?.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(servicePriceLabel!)
            make.centerY.equalTo(serviceDateLabel!)
        })
        bottomLine?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(nicknameLabel!)
            make.bottom.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(1)
        })
        
    }
    
    

    func setupData() {
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}