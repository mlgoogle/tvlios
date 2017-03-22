//
//  ServantReportCell.swift
//  HappyTravel
//
//  Created by 千山暮雪 on 2017/3/22.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit

class ServantReportCell: UITableViewCell {
    
    var titleLabel:UILabel?
    var selectImage:UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.whiteColor()
        
        addViews()
    }
    
    func addViews() {
        
        titleLabel = UILabel.init()
        titleLabel?.font = UIFont.systemFontOfSize(16)
        titleLabel?.textAlignment = .Left
        titleLabel?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        self.addSubview(titleLabel!)
        
        selectImage = UIImageView.init()
        selectImage?.image = UIImage.init(named: "selected")
        selectImage?.hidden = true
        self.addSubview(selectImage!)
        
        titleLabel?.snp_makeConstraints(closure: { (make) in
            make.top.bottom.equalTo(self)
            make.left.equalTo(25)
            make.width.equalTo(150)
        })
        
        selectImage?.snp_makeConstraints(closure: { (make) in
            make.height.equalTo(14)
            make.width.equalTo(16)
            make.right.equalTo(self).offset(-25)
            make.centerY.equalTo(self.snp_centerY)
        })
        
    }
    
    // 添加数据
    func addTitle(title:String) {
        titleLabel?.text = title
    }
    // 选中状态
    func didSelected() {
        titleLabel?.textColor = UIColor.init(decR: 252, decG: 163, decB: 17, a: 1)
        selectImage?.hidden = false
    }
    
    func didDisselecd() {
        titleLabel?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        selectImage?.hidden = true
    }
}
