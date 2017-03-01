//
//  FollowCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/3/1.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation

class FollowCell: UITableViewCell {
    
    lazy var head:UIImageView = {
        let imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFill
        imageView.backgroundColor = UIColor.grayColor()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.layer.borderColor = UIColor.redColor().CGColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    lazy var vip:UIImageView = {
        let imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFill
        imageView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 7
        imageView.layer.borderColor = UIColor.redColor().CGColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    lazy var nickname:UILabel = {
        let label = UILabel.init(text: "", font: UIFont.systemFontOfSize(S15), textColor: colorWithHexString("#666666"))
        return label
    }()
    
    lazy var leisure:UILabel = {
        let label = UILabel.init(text: "休闲", font: UIFont.systemFontOfSize(S12), textColor: colorWithHexString("#dd0011"))
        label.layer.borderWidth = 1
        label.layer.borderColor = colorWithHexString("#dd0011").CGColor
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.textAlignment = .Center
        return label
    }()
    
    lazy var business:UILabel = {
        let label = UILabel.init(text: "商务", font: UIFont.systemFontOfSize(S12), textColor: colorWithHexString("#dd0011"))
        label.layer.borderWidth = 1
        label.layer.borderColor = colorWithHexString("#dd0011").CGColor
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.textAlignment = .Center
        return label
    }()
    
    lazy var follow:UILabel = {
        let label = UILabel.init(text: "关注数:", font: UIFont.systemFontOfSize(S15), textColor: colorWithHexString("#666666"))
        label.textAlignment = .Right
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        initView()
    }
    
    func initView() {
        contentView.addSubview(head)
        head.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(contentView).offset(20)
            make.top.equalTo(contentView).offset(20)
            make.bottom.equalTo(contentView).offset(-20)
            make.width.equalTo(60)
            make.height.equalTo(60)
        })
        
        contentView.addSubview(vip)
        vip.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(head)
            make.bottom.equalTo(head)
            make.width.equalTo(14)
            make.height.equalTo(14)
        })
        
        contentView.addSubview(nickname)
        nickname.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(head.snp_right).offset(10)
            make.bottom.equalTo(head)
            make.width.equalTo(80)
            make.height.equalTo(30)
        })
        
        contentView.addSubview(leisure)
        leisure.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(nickname.snp_right).offset(10)
            make.bottom.equalTo(head.snp_centerY).offset(-5)
            make.width.equalTo(40)
            make.height.equalTo(25)
        })
        
        contentView.addSubview(business)
        business.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(nickname.snp_right).offset(10)
            make.top.equalTo(head.snp_centerY).offset(5)
            make.width.equalTo(40)
            make.height.equalTo(25)
        })
        
        contentView.addSubview(follow)
        follow.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(contentView).offset(-10)
            make.top.equalTo(head)
            make.left.equalTo(business.snp_right).offset(10)
            make.height.equalTo(25)
        })
    }
    
    func update(info: FollowListCellModel) {
        if info.head_url_ != nil {
            head.kf_setImageWithURL(NSURL.init(string: info.head_url_!))
        }
        
        nickname.text = info.nickname_ ?? "加载失败"
        
        follow.text = "关注数: \(info.follow_count_)"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
