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
    
    func attentionAction(sender:UIButton)
    func addMyWechatAccount()
}

class ServantHeaderView: UIView {
    
    var headerView:UIImageView?
    var nameLabel:UILabel?
    var attentionNum:UILabel?
    var starsView:UIView?
    var tagView:UIView?// 标签条
    var attenBtn:UIButton?
    
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
        
        let middleView:UIView = UIView.init(frame: CGRectMake(30, 150, ScreenWidth - 60, 145))
        self.addSubview(middleView)
        
        middleView.snp_makeConstraints { (make) in
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self).offset(-30)
            make.top.equalTo(self).offset(150)
            make.height.equalTo(145)
        }
        
        middleView.backgroundColor = UIColor.whiteColor()
        middleView.layer.borderWidth = 1.0
        middleView.layer.borderColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1).CGColor
        
        headerView = UIImageView.init(frame: CGRectMake(15, 15, 60, 60))
        headerView!.layer.masksToBounds = true
        headerView!.layer.cornerRadius = 30
        middleView.addSubview(headerView!)
        
        let vipImage:UIImageView = UIImageView()
        vipImage.image = UIImage.init(named: "attentionList_certified")
        vipImage.contentMode = .ScaleAspectFill
        vipImage.backgroundColor = colorWithHexString("#fca311")
        vipImage.layer.masksToBounds = true
        vipImage.layer.cornerRadius = 6
        headerView?.addSubview(vipImage)
        vipImage.snp_makeConstraints { (make) in
            make.bottom.equalTo((headerView?.snp_bottom)!).offset(-6)
            make.right.equalTo((headerView?.snp_right)!).offset(-6)
            make.width.height.equalTo(12)
        }
        
        attenBtn = UIButton.init(type: .Custom)
        middleView.addSubview(attenBtn!)
        attenBtn!.snp_makeConstraints { (make) in
            make.top.equalTo(middleView).offset(20)
            make.right.equalTo(middleView).offset(-15)
            make.width.equalTo(75)
            make.height.equalTo(33)
        }
        attenBtn!.layer.masksToBounds = true
        attenBtn!.layer.cornerRadius = 16.5
        attenBtn!.layer.borderWidth = 1
        attenBtn?.setImage(UIImage.init(named: "Add"), forState: .Normal)
        attenBtn?.setImage(UIImage.init(named: "nav-translucent-bg"), forState: .Selected)
        attenBtn?.setTitle("关注", forState: .Normal)
        attenBtn?.setTitle("已关注", forState: .Selected)
        attenBtn?.titleLabel?.font = UIFont.systemFontOfSize(14)
        attenBtn?.setTitleColor(UIColor.init(decR: 252, decG: 163, decB: 17, a: 1), forState: .Normal)
        attenBtn?.setTitleColor(UIColor.init(decR: 252, decG: 163, decB: 17, a: 1), forState: .Selected)
        attenBtn?.addTarget(self, action: #selector(ServantHeaderView.payAttention(_:)), forControlEvents: .TouchUpInside)
        
        nameLabel = UILabel.init()
        nameLabel!.font = UIFont.systemFontOfSize(18)
        nameLabel!.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        middleView.addSubview(nameLabel!)
        nameLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((headerView?.snp_right)!).offset(10)
            make.right.equalTo((attenBtn?.snp_left)!).offset(-10)
            make.top.equalTo((headerView?.snp_top)!)
            make.height.equalTo(30)
        })

        tagView = UIView.init(frame: CGRectMake((nameLabel?.Left)!, (nameLabel?.Bottom)! + 3, (nameLabel?.Width)!, (headerView?.Height)! - (nameLabel?.Bottom)! - 3))
        middleView.addSubview(tagView!)
        
        let sw:UIButton = UIButton.init(type: .Custom)
        sw.setBackgroundImage(UIImage.init(named: "attentionList_serviceTag"), forState: .Normal)
        sw.setTitle("商务", forState: .Normal)
        sw.titleLabel?.font = UIFont.systemFontOfSize(S10)
        sw.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, -1)
        sw.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        middleView.addSubview(sw)
        
        sw.snp_makeConstraints { (make) in
            make.left.equalTo((nameLabel?.snp_left)!)
            make.top.equalTo((nameLabel?.snp_bottom)!)
            make.width.equalTo(27)
            make.height.equalTo(25)
        }
        
        let xx:UIButton = UIButton.init(type: .Custom)
        xx.setBackgroundImage(UIImage.init(named: "attentionList_serviceTag"), forState: .Normal)
        xx.setTitle("休闲", forState: .Normal)
        xx.titleLabel?.font = UIFont.systemFontOfSize(S10)
        xx.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, -1)
        xx.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        middleView.addSubview(xx)
        
        xx.snp_makeConstraints { (make) in
            make.left.equalTo(sw.snp_right).offset(5)
            make.top.equalTo((nameLabel?.snp_bottom)!)
            make.width.equalTo(27)
            make.height.equalTo(25)
        }
        
        attentionNum = UILabel.init()
        attentionNum!.textAlignment = .Center
        attentionNum!.textColor = UIColor.init(decR: 102, decG: 102, decB: 102, a: 1)
        attentionNum!.font = UIFont.systemFontOfSize(12)
        attentionNum?.text = "0粉丝"
        middleView.addSubview(attentionNum!)
        attentionNum?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((attenBtn?.snp_bottom)!).offset(8)
            make.left.right.equalTo(attenBtn!)
            make.height.equalTo(15)
        })
        
        let lineLabel:UILabel = UILabel.init()
        middleView.addSubview(lineLabel)
        lineLabel.text = "好评度"
        lineLabel.font = UIFont.systemFontOfSize(11)
        lineLabel.textColor = UIColor.init(decR: 102, decG: 102, decB: 102, a: 1)
        lineLabel.textAlignment = .Center
        // 自适应宽度
        let attribute:NSMutableAttributedString = NSMutableAttributedString.init(string: "好评度")
        attribute.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(11), range: NSMakeRange(0, attribute.length))
        let option:NSStringDrawingOptions = .UsesLineFragmentOrigin
        let boundingRect:CGRect = attribute.boundingRectWithSize(CGSizeMake(200, 15), options: option, context: nil)
        lineLabel.frame = CGRectMake(middleView.Width / 2.0 - boundingRect.width / 2.0 , middleView.Height - 54, boundingRect.width, 15)
        
        let leftLine = UIView.init(frame: CGRectMake(15, lineLabel.Top + 7.5, lineLabel.Left - 25, 1))
        leftLine.backgroundColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1)
        middleView.addSubview(leftLine)
        
        let rightLine = UIView.init(frame: CGRectMake(lineLabel.Right + 10, leftLine.Top, middleView.Width - lineLabel.Right - 25, 1))
        rightLine.backgroundColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1)
        middleView.addSubview(rightLine)
        
        starsView = UIView.init(frame: CGRectMake((middleView.Width - 140)/2.0, lineLabel.Bottom + 8, 140, 20))
        starsView?.backgroundColor = UIColor.whiteColor()
        middleView.addSubview(starsView!)
        
    }
    
    // 设置底部按钮
    func bottomBtns() {
        
        let wechatBtn = UIButton.init(type: .Custom)
        self.addSubview(wechatBtn)
        
        wechatBtn.snp_makeConstraints { (make) in
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self).offset(-30)
            make.height.equalTo(44)
            make.bottom.equalTo(self).offset(-20)
        }
        wechatBtn.backgroundColor = UIColor.init(decR: 140, decG: 197, decB: 30, a: 1)
        wechatBtn.layer.masksToBounds = true
        wechatBtn.layer.cornerRadius = 22
        
        wechatBtn.setImage(UIImage.init(named: "wechat-white"), forState: .Normal)
        wechatBtn.setTitle("加我微信", forState: .Normal)
        wechatBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        wechatBtn.titleLabel?.textColor = UIColor.whiteColor()
        wechatBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6)
        wechatBtn.addTarget(self, action: #selector(ServantHeaderView.addWechat), forControlEvents: .TouchUpInside)
        
        let lineView:UIView = UIView.init(frame: CGRectMake(0, wechatBtn.Bottom + 19, ScreenWidth, 1))
        lineView.backgroundColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1)
        self.addSubview(lineView)
        lineView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(1)
            make.bottom.equalTo(self).offset(0)
        }
        
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
        if detailInfo.register_status_ == 0 {
            attenBtn?.selected = false
            attenBtn?.layer.borderColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1).CGColor
        }else {
            attenBtn?.selected = true
            attenBtn?.layer.borderColor = UIColor.init(decR: 252, decG: 163, decB: 17, a: 1).CGColor
        }
    }
    
    // 更新是否关注状态
    func uploadAttentionStatus(status:Bool) {
        
        if status {
            attenBtn?.selected = true
            attenBtn?.layer.borderColor = UIColor.init(decR: 252, decG: 163, decB: 17, a: 1).CGColor
        }else {
            attenBtn?.selected = false
            attenBtn?.layer.borderColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1).CGColor
        }
    }
    // 更新粉丝数量
    func updateFansCount(count:Int) {
        attentionNum?.text = String(count) + "粉丝"
    }
    
    func payAttention(sender:UIButton) {
        
        headerDelegate?.attentionAction(sender)
    }
    
    func addWechat() {
        headerDelegate?.addMyWechatAccount()
    }
    
}
