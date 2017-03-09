//
//  MessageCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/25.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class MessageCell: UITableViewCell {
    
    var userInfo:UserInfoModel?
    
    var showDetailInfo:UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "appointment-detail")
        return imageView
    }()
    let titleLabel:UILabel = UILabel()
    func updeat(info: OrderListCellModel){
        //时间戳的转换
        let dateFormatter = NSDateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.dateFromString(info.order_time_!)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = dateFormatter.stringFromDate(date!)
        titleLabel.text = dateString + "成功购买" + info.to_uid_nickename_! + "的商务信息"
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-25)
            make.height.equalTo(16)
            make.top.equalTo(contentView).offset(14)
        }
//        titleLabel.text = "2017/02/27成功购买“淘梦优然”的商务123131231231"
        titleLabel.font = UIFont.systemFontOfSize(16)
        titleLabel.textAlignment = .Left
        
        
        
//        var view = contentView.viewWithTag(101)
//        if view == nil {
//            view = UIView()
//            view!.tag = 101
//            view?.backgroundColor = UIColor.whiteColor()
//            view?.layer.cornerRadius = 5
//            view?.layer.masksToBounds = true
//            contentView.addSubview(view!)
//            view?.snp_makeConstraints(closure: { (make) in
//                make.left.equalTo(contentView).offset(10)
//                make.top.equalTo(contentView).offset(10)
//                make.right.equalTo(contentView).offset(-10)
//                make.bottom.equalTo(contentView)
//            })
//        }
//        
//        var headImageView = view?.viewWithTag(1001) as? UIImageView
//        if headImageView == nil {
//            headImageView = UIImageView()
//            headImageView!.tag = 1001
//            headImageView?.layer.cornerRadius = 45 / 2.0
//            headImageView?.layer.masksToBounds = true
//            headImageView?.layer.borderWidth = 1
//            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
//            headImageView!.userInteractionEnabled = true
//            headImageView!.backgroundColor = UIColor.clearColor()
//            view!.addSubview(headImageView!)
//            headImageView!.snp_makeConstraints { (make) in
//                make.left.equalTo(view!).offset(14)
//                make.top.equalTo(view!).offset(13)
//                make.height.equalTo(45)
//                make.width.equalTo(45)
//            }
//        }
//        
//        var nickNameLab = view?.viewWithTag(1002) as? UILabel
//        if nickNameLab == nil {
//            nickNameLab = UILabel()
//            nickNameLab?.tag = 1002
//            nickNameLab?.backgroundColor = UIColor.clearColor()
//            nickNameLab?.textAlignment = .Left
//            nickNameLab?.font = UIFont.systemFontOfSize(S15)
//            view?.addSubview(nickNameLab!)
//            nickNameLab?.snp_makeConstraints(closure: { (make) in
//                make.left.equalTo(headImageView!.snp_right).offset(10)
//                make.top.equalTo(view!).offset(16)
//            })
//        }
//        
//        var timeLab = view?.viewWithTag(1003) as? UILabel
//        if timeLab == nil {
//            timeLab = UILabel()
//            timeLab?.tag = 1003
//            timeLab?.backgroundColor = UIColor.clearColor()
//            timeLab?.textAlignment = .Left
//            timeLab?.textColor = UIColor.grayColor()
//            timeLab?.font = UIFont.systemFontOfSize(S13)
//            view?.addSubview(timeLab!)
//            timeLab?.snp_makeConstraints(closure: { (make) in
//                make.right.equalTo(view!).offset(-14)
//                make.bottom.equalTo(nickNameLab!)
//            })
//        }
//        
//        var unreadCntLab = view?.viewWithTag(1103) as? UILabel
//        if unreadCntLab == nil {
//            unreadCntLab = UILabel()
//            unreadCntLab?.tag = 1103
//            unreadCntLab?.backgroundColor = UIColor.redColor()
//            unreadCntLab?.textAlignment = .Center
//            unreadCntLab?.textColor = UIColor.whiteColor()
//            unreadCntLab?.font = UIFont.systemFontOfSize(S10)
//            unreadCntLab?.layer.cornerRadius = 18 / 2.0
//            unreadCntLab?.layer.masksToBounds = true
//            view?.addSubview(unreadCntLab!)
//            unreadCntLab?.snp_makeConstraints(closure: { (make) in
//                make.right.equalTo((timeLab?.snp_right)!).offset(-20)
//                make.top.equalTo(timeLab!.snp_bottom).offset(10)
//                make.width.equalTo(18)
//                make.height.equalTo(18)
//            })
//            unreadCntLab?.hidden = true
//        }
//        
//        var msgLab = view?.viewWithTag(1004) as? UILabel
//        if msgLab == nil {
//            msgLab = UILabel()
//            msgLab?.tag = 1004
//            msgLab?.backgroundColor = UIColor.clearColor()
//            msgLab?.textAlignment = .Left
//            msgLab?.font = UIFont.systemFontOfSize(S13)
//            msgLab?.textColor = UIColor.grayColor()
////            msgLab?.numberOfLines = 0
//            msgLab?.numberOfLines = 2
//            view?.addSubview(msgLab!)
//            msgLab?.snp_makeConstraints(closure: { (make) in
//                make.left.equalTo(nickNameLab!)
//                make.top.equalTo(nickNameLab!.snp_bottom).offset(12)
//                make.right.equalTo((unreadCntLab?.snp_left)!)
//                make.bottom.equalTo(view!).offset(-13)
//            })
//        }
//        
//        view?.addSubview(showDetailInfo)
//        showDetailInfo.snp_makeConstraints { (make) in
//            make.top.equalTo((timeLab?.snp_bottom)!).offset(10)
//            make.right.equalTo(timeLab!)
//        }
        
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
