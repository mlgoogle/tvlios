//
//  InvouiceHistoryDetailHeader.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class InvouiceHistoryDetailHeader: UIView {
    
    var statusLabel:UILabel?
    var sendOutTimeLabel:UILabel?
    
    var dateFormatter:DateFormatter = {
        var dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "YYYY.MM.dd"
        return dateFomatter
    }()
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = UIColor(red: 255 / 255.0, green: 247 / 255.0, blue: 228 / 255.0, alpha: 1.0)
        if statusLabel == nil {
            statusLabel = UILabel()
            statusLabel?.backgroundColor = UIColor.clear
            statusLabel?.textColor = UIColor(red: 19 / 255.0, green: 31 / 255.0, blue: 50 / 255.0, alpha: 1.0)
            statusLabel?.font = UIFont.systemFont(ofSize: S15)
            statusLabel?.textAlignment = .center
            addSubview(statusLabel!)
            
            statusLabel?.text = "待开票"
            if sendOutTimeLabel == nil {
                sendOutTimeLabel = UILabel()
                sendOutTimeLabel?.textColor = UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
                sendOutTimeLabel?.backgroundColor = UIColor.clear
                sendOutTimeLabel?.font = UIFont.systemFont(ofSize: S12)
                sendOutTimeLabel?.textAlignment = .center
                addSubview(sendOutTimeLabel!)
            }
            sendOutTimeLabel?.text = "预计最晚发出时间：2016.10.28 后一个工作日"
        }
        
        addSubViewConstraint()
    }
    /**
     添加约束
     */
    func addSubViewConstraint() {
        statusLabel?.snp_makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(14)
        })
        sendOutTimeLabel?.snp_makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-14)
        })
        
        
    }
    
    func setupInfo(_ date:Int, invoiceSatus:Int) {
        if statusLabel != nil {
            
            statusLabel?.text = invoiceSatus == 0 ? "待开票" : "已开票"
        }
        if sendOutTimeLabel != nil {
            
            let dateStrig = dateFormatter.string(from: Date(timeIntervalSince1970: Double(date)))
            sendOutTimeLabel?.text = "预计最晚发出时间：\(dateStrig) 后一个工作日"
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
