//
//  ServantHeaderView.swift
//  HappyTravel
//
//  Created by 巩婧奕 on 2017/3/3.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import Foundation

protocol ServantHeaderViewDelegate : NSObjectProtocol {
    
    func attentionAction()
    func addMyWechatAccount()
}

class ServantHeaderView: UIView {
    
    var headerView:UIImageView?
    var nameLabel:UILabel?
    var attentionNum:UILabel?
    var starsView:UIView?
    var tagView:UIView?// 标签条
    
    
    var headerDelegate:ServantHeaderViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
        
        topBgImage()
        
        middleView()
        
        bottomBtns()
    }
    
    // 设置顶部图片
    func topBgImage() {
        let bgImgView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, ScreenWidth, 200))
        self.addSubview(bgImgView)
        bgImgView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(200)
        }
        bgImgView.image = UIImage.init(named: "servant-header-bg")
    }
    
    // 设置中间卡片
    func middleView() {
        
        let middleView:UIView = UIView.init(frame: CGRectMake(30, 150, ScreenWidth - 60, 125))
        self.addSubview(middleView)
        
        middleView.snp_makeConstraints { (make) in
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self).offset(-30)
            make.top.equalTo(self).offset(170)
            make.height.equalTo(125)
        }
        
        middleView.backgroundColor = UIColor.whiteColor()
        middleView.layer.borderWidth = 1.0
        middleView.layer.borderColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1).CGColor
        
        headerView = UIImageView.init(frame: CGRectMake(15, 15, 60, 60))
        headerView!.layer.masksToBounds = true
        headerView!.layer.cornerRadius = 30
        middleView.addSubview(headerView!)
        
        nameLabel = UILabel.init(frame: CGRectMake(85, 15,ScreenWidth - 230 , 30))
        nameLabel!.font = UIFont.systemFontOfSize(18)
        nameLabel!.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        middleView.addSubview(nameLabel!)
        
        tagView = UIView.init(frame: CGRectMake((nameLabel?.Left)!, (nameLabel?.Bottom)! + 3, (nameLabel?.Width)!, (headerView?.Height)! - (nameLabel?.Bottom)! - 3))
        middleView.addSubview(tagView!)
        
        attentionNum = UILabel.init(frame: CGRectMake(nameLabel!.Right + 10, nameLabel!.Top, middleView.Width - nameLabel!.Right - 30, 20))
        attentionNum!.textAlignment = .Center
        attentionNum!.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        attentionNum!.font = UIFont.systemFontOfSize(14)
        middleView.addSubview(attentionNum!)
        
        let attenLabel:UILabel = UILabel.init(frame: CGRectMake(attentionNum!.Left, attentionNum!.Bottom + 3, attentionNum!.Width, 15))
        attenLabel.textColor = UIColor.init(decR: 102, decG: 102, decB: 102, a: 1)
        attenLabel.textAlignment = .Center
        attenLabel.text = "粉丝数"
        attenLabel.font = UIFont.systemFontOfSize(10)
        middleView.addSubview(attenLabel)
        
        let line:UIView = UIView.init(frame: CGRectMake(15, middleView.Height - 34, middleView.Width - 30, 1.0))
        line.backgroundColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1)
        middleView.addSubview(line)
        
        starsView = UIView.init(frame: CGRectMake((middleView.Width - 140)/2.0, line.Bottom + 8, 140, 20))
        starsView?.backgroundColor = UIColor.whiteColor()
        middleView.addSubview(starsView!)
    }
    
    // 设置底部按钮
    func bottomBtns() {
        
        let leftBtn:UIButton = UIButton.init(type: .Custom)
        leftBtn.frame = CGRectMake(15, 315, (ScreenWidth - 40)/2.0, 44)
        leftBtn.layer.masksToBounds = true
        leftBtn.layer.cornerRadius = 22.0
        leftBtn.backgroundColor = UIColor.whiteColor()
        leftBtn.layer.borderColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1).CGColor
        leftBtn.layer.borderWidth = 1.0
        leftBtn.setTitleColor(UIColor.init(decR: 51, decG: 51, decB: 51, a: 1), forState: .Normal)
        leftBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        leftBtn.addTarget(self, action: #selector(ServantHeaderView.payAttention), forControlEvents: .TouchUpInside)
        // 具体判断是关注还是取消关注
        leftBtn.setTitle("关注", forState: .Normal)
        leftBtn.setImage(UIImage.init(named: "Add"), forState: .Normal)
        self.addSubview(leftBtn)
        
        
        let rightBtn:UIButton = UIButton.init(type: .Custom)
        rightBtn.frame = CGRectMake(ScreenWidth / 2.0 + 5 , 315, (ScreenWidth - 40)/2.0, 44)
        rightBtn.layer.masksToBounds = true
        rightBtn.layer.cornerRadius = 22.0
        rightBtn.backgroundColor = UIColor.whiteColor()
        rightBtn.layer.borderColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1).CGColor
        rightBtn.layer.borderWidth = 1.0
        rightBtn.setTitleColor(UIColor.init(decR: 51, decG: 51, decB: 51, a: 1), forState: .Normal)
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        rightBtn.setTitle("加我微信", forState: .Normal)
        rightBtn.setImage(UIImage.init(named: "Wechat"), forState: .Normal)
        self.addSubview(rightBtn)
        rightBtn.addTarget(self, action: #selector(ServantHeaderView.addWechat), forControlEvents: .TouchUpInside)
    }
    
    // 更新UI数据
    func didAddNewUI(detailInfo:UserInfoModel) {
        headerView?.kf_setImageWithURL(NSURL.init(string: detailInfo.head_url_!))
        nameLabel?.text = detailInfo.nickname_
        attentionNum?.text = String(detailInfo.follow_count_)
        
        let count:Int = Int(detailInfo.service_score_)
        
        for i in 0..<count {

            let starImage:UIImageView = UIImageView.init(frame: CGRectMake( CGFloat(Float(i)) * 30.0, 0, 20, 20))
            starsView!.addSubview(starImage)
            starImage.image = UIImage.init(named: "star-select")
        }
        // 空心的星星
        for i in count ..< 5 {
            let starImage:UIImageView = UIImageView.init(frame: CGRectMake( CGFloat(Float(i)) * 30.0, 0, 20, 20))
            starsView!.addSubview(starImage)
            starImage.image = UIImage.init(named: "star-emp")
        }
        
        // 根据状态调整按钮标题
        
    }
    
    func payAttention() {
        headerDelegate?.attentionAction()
    }
    
    func addWechat() {
        headerDelegate?.addMyWechatAccount()
    }
    
}
