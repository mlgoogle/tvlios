//
//  ServantPersonalCell.swift
//  HappyTravel
//
//  Created by 巩婧奕 on 2017/3/3.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit

protocol ServantPersonalCellDelegate {
    
    func servantIsLikedAction(sender:UIButton,model:servantDynamicModel)
    func servantImageDidClicked(model:servantDynamicModel, index:Int)
}

class ServantPersonalCell: UITableViewCell {
    
    var headerView:UIImageView?
    var nameLabel:UILabel?
    var thumbUpBtn:UIButton?
    var delegate:ServantPersonalCellDelegate?
    var personModel:servantDynamicModel?
    
    
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
        thumbUpBtn?.setTitleColor(UIColor.init(decR: 153, decG: 153, decB: 153, a: 1), forState: .Normal)
        thumbUpBtn?.setTitleColor(UIColor.init(decR: 252, decG: 163, decB: 17, a: 1), forState: .Selected)
        thumbUpBtn?.titleLabel?.font = UIFont.systemFontOfSize(12)
        thumbUpBtn?.setImage(UIImage.init(named: "thumbUp-normal"), forState: .Normal)
        thumbUpBtn?.setImage(UIImage.init(named: "thumbUp-selected"), forState: .Selected)
        thumbUpBtn?.addTarget(self, action: #selector(ServantPersonalCell.islikeAction(_:)), forControlEvents: .TouchUpInside)
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
    
    func islikeAction(sender:UIButton) {
        delegate?.servantIsLikedAction(sender, model: personModel!)
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
        
        imgView?.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.imageAction(_:)))
        imgView?.addGestureRecognizer(tap)
    }
    // 图片点击了
    func imageAction(tap:UITapGestureRecognizer) {
        
        delegate?.servantImageDidClicked(personModel!, index: 0)
    }
    
    func updateImage(model:servantDynamicModel) {
        
        personModel = model
        
        let isliked = model.is_liked_
        let likeCount = model.dynamic_like_count_
        if isliked == 0 {
            thumbUpBtn?.selected = false
            thumbUpBtn?.setTitle(String(likeCount), forState: .Normal)
        }else {
            thumbUpBtn?.selected = true
            thumbUpBtn?.setTitle(String(likeCount), forState: .Selected)
        }
        
        
        
        let imageUrls = model.dynamic_url_
        imgView?.kf_setImageWithURL(NSURL.init(string: imageUrls!))
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
    
    func updateLabelText(model:servantDynamicModel) {
        
        personModel = model
        
        let isliked = model.is_liked_
        let likeCount = model.dynamic_like_count_
        if isliked == 0 {
            thumbUpBtn?.selected = false
            thumbUpBtn?.setTitle(String(likeCount), forState: .Normal)
        }else {
            thumbUpBtn?.selected = true
            thumbUpBtn?.setTitle(String(likeCount), forState: .Selected)
        }
        
        let textString = model.dynamic_text_
        detailLabel?.text = textString
    }
}

class ServantPicAndLabelCell: ServantPersonalCell {
    
    var detailLabel:UILabel?
    var imageContianer:UIView?
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addLabelAndImgView()
    }
    
    func addLabelAndImgView() {
        
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
        })
        
        imageContianer = UIView.init()
        imageContianer?.backgroundColor = UIColor.whiteColor()
        self.addSubview(imageContianer!)
        
        imageContianer?.snp_makeConstraints(closure: { (make) in
            
            make.left.equalTo((headerView?.snp_right)!).offset(5)
            make.top.equalTo((detailLabel?.snp_bottom)!).offset(10)
            make.right.equalTo(-15)
            make.bottom.equalTo(-45)
        })
        
    }
    
    func updateUI(model:servantDynamicModel) {
        
        personModel = model
        
        let isliked = model.is_liked_
        let likeCount = model.dynamic_like_count_
        if isliked == 0 {
            thumbUpBtn?.selected = false
            thumbUpBtn?.setTitle(String(likeCount), forState: .Normal)
        }else {
            thumbUpBtn?.selected = true
            thumbUpBtn?.setTitle(String(likeCount), forState: .Selected)
        }
        
        let detailString = model.dynamic_text_
        detailLabel?.text = detailString
        
        let imgUrlString = model.dynamic_url_
        let urlArray = imgUrlString!.componentsSeparatedByString(",")
        
        let count = urlArray.count
        print(count)
        
        let imageWidth = (self.Width - (headerView?.Right)! - 30) / 3.0
        
        // 移除子视图，防止cell复用
        for subView in (imageContianer?.subviews)! {
            subView.removeFromSuperview()
        }
        
        for i in 0..<count {
            
            let imageUrl = urlArray[i]
            let row = i / 3 // 行
            let col = i % 3 // 列
            
            print(row, col)
            
            let imgV:UIImageView = UIImageView.init()
            imageContianer?.addSubview(imgV)
            imgV.tag = 30000 + i
            // 加图片链接
            imgV.kf_setImageWithURL(NSURL.init(string: imageUrl))
            
            imgV.userInteractionEnabled = true
            let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.imageAction(_:)))
            imgV.addGestureRecognizer(tap)
            
            // 加约束
            imgV.snp_makeConstraints(closure: { (make) in
                make.width.height.equalTo(imageWidth)
                
                switch row {
                    case 0:
                        make.top.equalTo((imageContianer?.snp_top)!)
                        break
                    
                    case 1:
                        make.top.equalTo((imageContianer?.snp_top)!).offset(imageWidth + 5)
                        break
                        
                    case 2:
                        make.top.equalTo((imageContianer?.snp_top)!).offset(2*imageWidth + 10)
                        break
                    
                    default:
                        break
                }
                
                switch col {
                    case 0:
                        make.left.equalTo((imageContianer?.snp_left)!)
                        break
                    
                    case 1:
                        make.left.equalTo((imageContianer?.snp_left)!).offset(imageWidth + 5)
                        break
                    
                    case 2:
                        make.left.equalTo((imageContianer?.snp_left)!).offset(2*imageWidth + 10)
                        make.right.equalTo((imageContianer?.snp_right)!)
                        break
                    
                    default:
                        break
                }
                
                if i == count - 1 {
                    make.bottom.equalTo((imageContianer?.snp_bottom)!).offset(-5)
                }
                
            })
        }
    }
    
    func imageAction(tap:UITapGestureRecognizer) {
        
        let index:Int = (tap.view?.tag)! - 30000
        
        delegate?.servantImageDidClicked(personModel!, index: index)
    }
    
}

