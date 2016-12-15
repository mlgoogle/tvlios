//
//  PhotoWallCell.swift
//  viossvc
//
//  Created by 陈奕涛 on 16/12/1.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import Foundation

protocol PhotoWallCellDelegate: NSObjectProtocol {
    
    func touchedPhotoItem(photoInfo: PhotoModel)
    
}

class PhotoWallCell: UITableViewCell {
    
    weak var delegate: PhotoWallCellDelegate?
    
    var photos:[PhotoModel]?
    
    var rightPhoto: UIImageView?
    var centerPhoto: UIImageView?
    var leftPhoto: UIImageView?
    var timeLine: UIView?
    
    let tags = ["bgView": 1001,
                "left": 1002,
                "center": 1003,
                "right": 1004]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        if timeLine == nil {
            timeLine = UIView()
            timeLine?.backgroundColor = colorWithHexString("#0x141f31")
            contentView.addSubview(timeLine!)
            timeLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(40)
                make.top.equalTo(contentView)
                make.bottom.equalTo(contentView)
                make.width.equalTo(3)
            })
        }
        
        var bgView = contentView.viewWithTag(tags["bgView"]!)
        if bgView == nil {
            bgView = UIView()
            bgView?.tag = tags["bgView"]!
            bgView?.backgroundColor = UIColor.clearColor()
            contentView.addSubview(bgView!)
            bgView?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(timeLine!.snp_right).offset(25)
                make.right.equalTo(contentView).offset(-20)
                make.top.equalTo(contentView).offset(5)
                make.bottom.equalTo(contentView).offset(-5)
                make.height.equalTo(80)
            })
        }
        
        if leftPhoto == nil {
            leftPhoto = UIImageView()
            leftPhoto?.userInteractionEnabled = true
            leftPhoto?.tag = tags["left"]!
            leftPhoto?.image = UIImage.init(named: "head_giry")
            contentView.addSubview(leftPhoto!)
            leftPhoto?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(bgView!)
                make.top.equalTo(bgView!)
                make.bottom.equalTo(bgView!)
                make.width.equalTo(80)
            })
            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(tapCellItem(_:)))
            leftPhoto?.addGestureRecognizer(tap)
        }
        
        if centerPhoto == nil {
            centerPhoto = UIImageView()
            centerPhoto?.userInteractionEnabled = true
            centerPhoto?.tag = tags["center"]!
            centerPhoto?.image = UIImage.init(named: "head_giry")
            contentView.addSubview(centerPhoto!)
            centerPhoto?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(leftPhoto!.snp_right).offset(10)
                make.top.equalTo(bgView!)
                make.bottom.equalTo(bgView!)
                make.width.equalTo(80)
            })
            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(tapCellItem(_:)))
            centerPhoto?.addGestureRecognizer(tap)
        }
        
        if rightPhoto == nil {
            rightPhoto = UIImageView()
            rightPhoto?.userInteractionEnabled = true
            rightPhoto?.tag = tags["right"]!
            rightPhoto?.image = UIImage.init(named: "head_giry")
            contentView.addSubview(rightPhoto!)
            rightPhoto?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(centerPhoto!.snp_right).offset(10)
                make.top.equalTo(bgView!)
                make.bottom.equalTo(bgView!)
                make.width.equalTo(80)
            })
            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(tapCellItem(_:)))
            rightPhoto?.addGestureRecognizer(tap)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(data: AnyObject!) {
        photos = data as? [PhotoModel]
        if photos != nil {
            leftPhoto?.hidden = photos!.count > 0 ? false : true
            centerPhoto?.hidden = photos!.count > 1 ? false : true
            rightPhoto?.hidden = photos!.count > 2 ? false : true
            
            for (index, photo) in photos!.enumerate() {
                switch index {
                case 0:
                    leftPhoto?.kf_setImageWithURL(NSURL(string: photo.photo_url_! + CommonDefine.qiniuImgStyle), placeholderImage: UIImage.init(named: "head_giry"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
                    
                case 1:
                    centerPhoto?.kf_setImageWithURL(NSURL(string: photo.photo_url_! + CommonDefine.qiniuImgStyle), placeholderImage: UIImage.init(named: "head_giry"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
                    
                case 2:
                    rightPhoto?.kf_setImageWithURL(NSURL(string: photo.photo_url_! + CommonDefine.qiniuImgStyle), placeholderImage: UIImage.init(named: "head_giry"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
                    
                default:
                    break
                }
            }
        }
        
    }
    
    func tapCellItem(sender: UIGestureRecognizer) {
        if sender.view != nil {
            let index = sender.view!.tag % 1000 - 2
            delegate?.touchedPhotoItem(photos![index])
        }
    }
    
}
