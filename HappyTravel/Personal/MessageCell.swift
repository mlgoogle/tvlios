//
//  MessageCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/25.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class MessageCell: UITableViewCell {
    
    var userInfo:UserInfo?
    
    var msgInfo:PushMessage?
    var showDetailInfo:UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "appointment-detail")
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        var view = contentView.viewWithTag(101)
        if view == nil {
            view = UIView()
            view!.tag = 101
            view?.backgroundColor = UIColor.white
            view?.layer.cornerRadius = 5
            view?.layer.masksToBounds = true
            contentView.addSubview(view!)
            view?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView)
            })
        }
        
        var headImageView = view?.viewWithTag(1001) as? UIImageView
        if headImageView == nil {
            headImageView = UIImageView()
            headImageView!.tag = 1001
            headImageView?.layer.cornerRadius = 45 / 2.0
            headImageView?.layer.masksToBounds = true
            headImageView?.layer.borderWidth = 1
            headImageView?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            headImageView!.isUserInteractionEnabled = true
            headImageView!.backgroundColor = UIColor.clear
            view!.addSubview(headImageView!)
            headImageView!.snp.makeConstraints { (make) in
                make.left.equalTo(view!).offset(14)
                make.top.equalTo(view!).offset(13)
                make.height.equalTo(45)
                make.width.equalTo(45)
            }
        }
        
        var nickNameLab = view?.viewWithTag(1002) as? UILabel
        if nickNameLab == nil {
            nickNameLab = UILabel()
            nickNameLab?.tag = 1002
            nickNameLab?.backgroundColor = UIColor.clear
            nickNameLab?.textAlignment = .left
            nickNameLab?.font = UIFont.systemFont(ofSize: S15)
            view?.addSubview(nickNameLab!)
            nickNameLab?.snp.makeConstraints({ (make) in
                make.left.equalTo(headImageView!.snp.right).offset(10)
                make.top.equalTo(view!).offset(16)
            })
        }
        
        var timeLab = view?.viewWithTag(1003) as? UILabel
        if timeLab == nil {
            timeLab = UILabel()
            timeLab?.tag = 1003
            timeLab?.backgroundColor = UIColor.clear
            timeLab?.textAlignment = .left
            timeLab?.textColor = UIColor.gray
            timeLab?.font = UIFont.systemFont(ofSize: S13)
            view?.addSubview(timeLab!)
            timeLab?.snp.makeConstraints({ (make) in
                make.right.equalTo(view!).offset(-14)
                make.bottom.equalTo(nickNameLab!)
            })
        }
        
        var unreadCntLab = view?.viewWithTag(1103) as? UILabel
        if unreadCntLab == nil {
            unreadCntLab = UILabel()
            unreadCntLab?.tag = 1103
            unreadCntLab?.backgroundColor = UIColor.red
            unreadCntLab?.textAlignment = .center
            unreadCntLab?.textColor = UIColor.white
            unreadCntLab?.font = UIFont.systemFont(ofSize: S10)
            unreadCntLab?.layer.cornerRadius = 18 / 2.0
            unreadCntLab?.layer.masksToBounds = true
            view?.addSubview(unreadCntLab!)
            unreadCntLab?.snp.makeConstraints({ (make) in
                make.right.equalTo((timeLab?.snp.right)!).offset(-20)
                make.top.equalTo(timeLab!.snp.bottom).offset(10)
                make.width.equalTo(18)
                make.height.equalTo(18)
            })
            unreadCntLab?.isHidden = true
        }
        
        var msgLab = view?.viewWithTag(1004) as? UILabel
        if msgLab == nil {
            msgLab = UILabel()
            msgLab?.tag = 1004
            msgLab?.backgroundColor = UIColor.clear
            msgLab?.textAlignment = .left
            msgLab?.font = UIFont.systemFont(ofSize: S13)
            msgLab?.textColor = UIColor.gray
            msgLab?.numberOfLines = 0
            view?.addSubview(msgLab!)
            msgLab?.snp.makeConstraints({ (make) in
                make.left.equalTo(nickNameLab!)
                make.top.equalTo(nickNameLab!.snp.bottom).offset(12)
                make.right.equalTo(timeLab!)
                make.bottom.equalTo(view!).offset(-13)
            })
        }
        
        view?.addSubview(showDetailInfo)
        showDetailInfo.snp.makeConstraints { (make) in
            make.top.equalTo((timeLab?.snp.bottom)!).offset(10)
            make.right.equalTo(timeLab!)
        }
    }
    
    func setInfo(_ message: PushMessage?, unreadCnt: Int) {
        msgInfo = message
        if msgInfo?.msg_type_ == 2231 {
            
            showDetailInfo.isHidden = false
            setAppointmentInfo(message, unreadCnt: unreadCnt)
        }else {
            showDetailInfo.isHidden = true
            let view = contentView.viewWithTag(101)
            if let headView = view!.viewWithTag(1001) as? UIImageView {
                var uid = 0
                if message!.from_uid_ == DataManager.currentUser!.uid {
                    uid = message!.to_uid_
                } else {
                    uid = message!.from_uid_
                }
                if let user = DataManager.getUserInfo(uid) {
                    userInfo = user
                    headView.kf_setImageWithURL(URL(string: userInfo!.headUrl!), placeholderImage: UIImage(named: "touxiang_women"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                        
                    }
                    if let nickNameLab = view!.viewWithTag(1002) as? UILabel {
                        nickNameLab.text = userInfo!.nickname!
                    }
                    
                    if let msgLab = view!.viewWithTag(1004) as? UILabel {
                        var nickname:String?
                        if message!.from_uid_ == DataManager.currentUser!.uid {
                            nickname = DataManager.currentUser?.nickname
                        } else {
                            nickname = userInfo?.nickname
                        }
                        msgLab.text = "\(nickname!) : \((message?.content_!)!)"
                    }
                }
                
                if let timeLab = view!.viewWithTag(1003) as? UILabel {
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    dateFormatter.dateStyle = .short
                    let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: NSNumber.init(value: message!.msg_time_ as Int64).doubleValue))
                    timeLab.text = dateStr
                }
                
                if let unreadCntLab = view!.viewWithTag(1103) as? UILabel {
                    
                    if unreadCnt > 0 {
                        unreadCntLab.isHidden = false
                        unreadCntLab.text = "\(unreadCnt)"
                    } else {
                        unreadCntLab.isHidden = true
                    }
                }
                
            }
        }
        
    }
    
    func setAppointmentInfo(_ message: PushMessage?, unreadCnt: Int) {
        
        let view = contentView.viewWithTag(101)
        if let headView = view!.viewWithTag(1001) as? UIImageView {
            headView.image = UIImage(named: "touxiang_women")
                if let nickNameLab = view!.viewWithTag(1002) as? UILabel {
                    nickNameLab.text = "预约推荐"
                }
                if let msgLab = view!.viewWithTag(1004) as? UILabel {
                    msgLab.text = message?.content_

                }
            }
            
            if let timeLab = view!.viewWithTag(1003) as? UILabel {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .short
                let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: NSNumber.init(value: message!.msg_time_ as Int64).doubleValue))
                timeLab.text = dateStr
            }
            
            if let unreadCntLab = view!.viewWithTag(1103) as? UILabel {
                if unreadCnt > 0 {
                    unreadCntLab.isHidden = false
                    unreadCntLab.text = "\(unreadCnt)"
                } else {
                    unreadCntLab.isHidden = true
                }
            }
            
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
