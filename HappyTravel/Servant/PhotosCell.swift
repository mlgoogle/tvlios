//
//  PhotosCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift

protocol PhotosCellDelegate : NSObjectProtocol {
    
    func spreadAction(_ sender: AnyObject?)
    
}

open class PhotosCell : UITableViewCell {
    
    var spread = false
    var photosInfo:AnyObject?
    weak var delegate:PhotosCellDelegate?
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        var view = viewWithTag(101)
        if view == nil {
            view = UIView()
            view!.tag = 101
            view?.backgroundColor = UIColor.clear
            view?.isUserInteractionEnabled = true
            contentView.addSubview(view!)
            view?.snp_makeConstraints({ (make) in
                make.left.equalTo(self.contentView).offset(10)
                make.top.equalTo(self.contentView).offset(10)
                make.right.equalTo(self.contentView).offset(-10)
                make.bottom.equalTo(self.contentView).offset(-10)
            })
        }
        
        var moreBtn = contentView.viewWithTag(1002) as? UIButton
        if moreBtn == nil {
            moreBtn = UIButton(frame: CGRect.zero)
            moreBtn?.tag = 1002
            moreBtn?.contentMode = UIViewContentMode.scaleAspectFit
            moreBtn!.addTarget(self, action: #selector(PhotosCell.moreAction(_:)), for: UIControlEvents.touchUpInside)
            moreBtn!.setImage(UIImage.init(named: "guide-detail-arrows"), for: UIControlState())
            view!.addSubview(moreBtn!)
            moreBtn!.snp_makeConstraints({ (make) in
                make.bottom.equalTo(view!)
                make.height.equalTo(7)
                make.width.equalTo(14)
                make.centerX.equalTo(view!)
            })
        }
        
        var nonePhotosLabel = contentView.viewWithTag(1003) as? UILabel
        if nonePhotosLabel == nil {
            nonePhotosLabel = UILabel()
            nonePhotosLabel?.tag = 1003
            nonePhotosLabel!.font = UIFont.systemFont(ofSize: AtapteWidthValue(24))
            nonePhotosLabel?.textAlignment = .center
            nonePhotosLabel!.text = "无照片"
            nonePhotosLabel!.textColor = UIColor.gray
            nonePhotosLabel!.backgroundColor = UIColor.clear
            view!.addSubview(nonePhotosLabel!)
            nonePhotosLabel?.snp_makeConstraints({ (make) in
                make.top.equalTo(view!).offset(10)
                make.left.equalTo(view!)
                make.right.equalTo(view!)
                make.bottom.equalTo(moreBtn!.snp_top).offset(-10)
            })
        }
        
    }
    
    func setInfo(_ photos: List<PhotoUrl>?, setSpread spd: Bool) {
        let view = contentView.viewWithTag(101)
        let nonePhotosLabel = view!.viewWithTag(1003) as? UILabel
        if photos!.count != 0 {
            nonePhotosLabel?.isHidden = true
            for (index, photoURL) in photos!.enumerated() {
                var photoView = nonePhotosLabel?.viewWithTag(1003 * 10 + index) as? UIImageView
                if photoView == nil {
                    photoView = UIImageView()
                    photoView?.backgroundColor = UIColor.clear
                    photoView?.tag = 1003 * 10 + index
                    view?.addSubview(photoView!)
                }
                photoView!.kf_setImageWithURL(NSURL(string: photoURL.photoUrl!), placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                    
                }
                var previousView:UIImageView?
                let row = index / 4
                let col = index % 4
                if index != 0 {
                    previousView = view?.viewWithTag(1003 * 10 + index - 1) as? UIImageView
                }
                photoView?.snp_makeConstraints({ (make) in
                    if col == 0 {
                        make.left.equalTo(nonePhotosLabel!)
                    } else {
                        make.left.equalTo(previousView!.snp_right).offset(10)
                    }
                    if row == 0 {
                        make.top.equalTo(nonePhotosLabel!)
                    } else {
                        make.top.equalTo(previousView!.snp_bottom).offset(10)
                    }
                    let photoWidth = (UIScreen.main.bounds.size.width - 50) / 4.0
                    make.width.equalTo(photoWidth)
                    make.height.equalTo(photoWidth)
                    if index + 1 == photos?.count {
                        let moreBtn = contentView.viewWithTag(1002) as? UIButton
                        moreBtn?.snp_remakeConstraints({ (make) in
                            make.top.equalTo(photoView!.snp_bottom).offset(10)
                            make.bottom.equalTo(view!)
                            make.width.equalTo(40)
                            make.centerX.equalTo(view!)
                        })
                    }
                })
                
            }
        } else {
            nonePhotosLabel?.isHidden = false
        }
        
    }
    
    func moreAction(_ sender: AnyObject?) {
        XCGLogger.defaultInstance().debug("detailAction")
    }
    
    func selectAction(_ sender: AnyObject?) {
        XCGLogger.defaultInstance().debug("selectAction:\(sender!.tag)")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

