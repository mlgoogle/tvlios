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
        imageView.layer.cornerRadius = 20.5
        return imageView
    }()
    
    lazy var vip:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "attentionList_certified")
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFill
        imageView.backgroundColor = colorWithHexString("#fca311")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    lazy var nickname:UILabel = {
        let label = UILabel.init(text: "", font: UIFont.systemFontOfSize(S16), textColor: colorWithHexString("#333333"))
        return label
    }()
    
    lazy var business:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.init(named: "attentionList_serviceTag"), forState: .Normal)
        button.setTitle("商务", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(S10)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, -1)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        return button
    }()
    
    lazy var leisure:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.init(named: "attentionList_serviceTag"), forState: .Normal)
        button.setTitle("休闲", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(S10)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, -1)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        return button
    }()
    
    lazy var followTitle:UILabel = {
        let label = UILabel.init(text: "粉丝数", font: UIFont.systemFontOfSize(S10), textColor: colorWithHexString("#666666"))
        label.textAlignment = .Center
        return label
    }()
    
    lazy var follow:UILabel = {
        let label = UILabel.init(text: "", font: UIFont.systemFontOfSize(S16), textColor: colorWithHexString("#333333"))
        label.textAlignment = .Center
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .DisclosureIndicator
        selectionStyle = .None
        initView()
    }
    
    func initView() {
        contentView.addSubview(head)
        head.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(contentView).offset(13)
            make.bottom.equalTo(contentView).offset(-13)
            make.width.equalTo(41)
            make.height.equalTo(41)
        })
        
        contentView.addSubview(vip)
        vip.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(head).offset(-3)
            make.bottom.equalTo(head).offset(-1)
            make.width.equalTo(10)
            make.height.equalTo(10)
        })
        
        contentView.addSubview(nickname)
        nickname.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(head.snp_right).offset(5)
            make.centerY.equalTo(contentView)
            make.height.equalTo(16)
        })
        
        contentView.addSubview(business)
        business.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(nickname.snp_right).offset(14)
            make.centerY.equalTo(nickname.snp_centerY)
            make.width.equalTo(29)
            make.height.equalTo(23)
        })
        
        contentView.addSubview(leisure)
        leisure.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(business.snp_right).offset(5)
            make.centerY.equalTo(business)
            make.width.equalTo(29)
            make.height.equalTo(23)
        })
        
        contentView.addSubview(followTitle)
        followTitle.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(contentView.snp_centerY).offset(2.5)
            make.width.equalTo(50)
            make.height.equalTo(10)
        })
        
        contentView.addSubview(follow)
        follow.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(followTitle)
            make.bottom.equalTo(contentView.snp_centerY).offset(-2.5)
            make.width.equalTo(50)
            make.height.equalTo(16)
        })
    }
    
    func update(info: FollowListCellModel) {
        if info.head_url_ != nil {
            head.kf_setImageWithURL(NSURL.init(string: info.head_url_!))
        }
        
        nickname.text = info.nickname_ ?? "加载失败"
        
        follow.text = "\(info.follow_count_)"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
