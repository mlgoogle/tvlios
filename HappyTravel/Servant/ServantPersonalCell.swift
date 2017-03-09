//
//  ServantPersonalCell.swift
//  HappyTravel
//
//  Created by 巩婧奕 on 2017/3/3.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit

class ServantPersonalCell: UITableViewCell {
    
    var headerView:UIImageView?
    var nameLabel:UILabel?
    var thumbUpBtn:UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.whiteColor()
        addViews()
    }
    
    func addViews() {
        
        headerView = UIImageView.init()
        headerView?.layer.masksToBounds = true
        headerView?.layer.cornerRadius = 21.0
        self.addSubview(headerView!)
        
        headerView?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(10)
            make.top.equalTo(20)
            make.width.height.equalTo(42)
        })
        
        nameLabel = UILabel.init()
        nameLabel?.numberOfLines = 1
        nameLabel?.textAlignment = .Left
        nameLabel?.textColor = UIColor.init(decR: 102, decG: 102, decB: 102, a: 1)
        nameLabel?.font = UIFont.systemFontOfSize(14)
        self.addSubview(nameLabel!)
        
        nameLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((headerView?.snp_right)!).offset(5)
            make.top.equalTo(headerView!)
            make.right.equalTo(-15)
            make.height.equalTo(21)
        })
        
        thumbUpBtn = UIButton.init(type: .Custom)
        thumbUpBtn?.backgroundColor = UIColor.clearColor()
        thumbUpBtn?.setImage(UIImage.init(named: "thumbUp-normal"), forState: .Normal)
        thumbUpBtn?.setImage(UIImage.init(named: "thumbUp-selected"), forState: .Selected)
        self.addSubview(thumbUpBtn!)
        
        thumbUpBtn?.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(-15)
            make.bottom.equalTo(-15)
            make.width.equalTo(40)
            make.height.equalTo(18)
        })
        
        let lineView:UIView = UIView.init()
        lineView.backgroundColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1)
        self.addSubview(lineView)
        lineView.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(1)
            make.bottom.equalTo(-1)
        }
    }
}


class ServantOnePicCell: ServantPersonalCell {
    
    var imgView:UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgView = UIImageView.init()
        self.addSubview(imgView!)
        
        imgView?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((headerView?.snp_right)!).offset(5)
            make.top.equalTo((headerView?.snp_bottom)!).offset(8)
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.bottom.equalTo(-45)
        })
    }
    
    func updateImg(urls:String) {
        
        let urlArray = urls.componentsSeparatedByString(",")
        let url = urlArray[0] 
        
        imgView?.kf_setImageWithURL(NSURL.init(string: url))
    }
}

class ServantOneLabelCell: ServantPersonalCell {
    
    var detailLabel:UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        detailLabel = UILabel.init()
        detailLabel?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        detailLabel?.textAlignment = .Left
        detailLabel?.numberOfLines = 0
        detailLabel?.font = UIFont.systemFontOfSize(16)
        self.addSubview(detailLabel!)
        
        detailLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((headerView?.snp_right)!).offset(5)
            make.right.equalTo(-15)
            make.top.equalTo((nameLabel?.snp_bottom)!)
            make.bottom.equalTo(-45)
        })
    }
}

class ServantPicAndLabelCell: ServantPersonalCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}

