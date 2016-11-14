//
//  CenturionCardServicesCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/13.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift


protocol CenturionCardServicesCellDelegate : NSObjectProtocol {
    
    func serviceTouched(service: CenturionCardServiceInfo)
    func buyNowButtonTouched()
}


class CenturionCardServerItem: UICollectionViewCell {
    lazy var iconBtn: UIButton = {
        let iconBtn = UIButton.init(type: .Custom)
        iconBtn.userInteractionEnabled = false
        return iconBtn
    }()
    var titleLabel: UILabel = {
        let label = UILabel.init(text: "", font: UIFont.systemFontOfSize(S12), textColor: colorWithHexString("#666666"))
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconBtn)
        iconBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(AtapteWidthValue(10))
            make.size.equalTo(CGSizeMake(AtapteWidthValue(40), AtapteWidthValue(40)))
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(iconBtn.snp_bottom).offset(AtapteWidthValue(4))
            make.height.equalTo(S12)
            make.bottom.equalTo(AtapteWidthValue(-12))
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CenturionCardServicesCell : UITableViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    weak var delegate:CenturionCardServicesCellDelegate?
    
    var services:Results<CenturionCardServiceInfo>?
    
    //collectionView
    lazy var contentCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSizeMake((ScreenWidth-20)/4, AtapteWidthValue(80))
        let collectionView = UICollectionView.init(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(CenturionCardServerItem.classForCoder(), forCellWithReuseIdentifier: "CenturionCardServerItem")
        collectionView.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        return collectionView
    }()
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services == nil ? 0 : services!.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item: CenturionCardServerItem = collectionView.dequeueReusableCellWithReuseIdentifier("CenturionCardServerItem", forIndexPath: indexPath) as! CenturionCardServerItem
        let service  = services![indexPath.row]
        let url = service.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ? service.privilege_pic_yes_ : service.privilege_pic_no_
        item.iconBtn.kf_setBackgroundImageWithURL(NSURL(string: url!), forState: .Normal, placeholderImage: UIImage.init(named: "face-btn"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        item.titleLabel.text = service.privilege_name_!
        return item
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate!.serviceTouched(services![indexPath.row])
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return DataManager.currentUser!.centurionCardLv <= 0 ? CGSize.init(width: ScreenWidth, height: 80) : CGSizeZero
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return UICollectionReusableView()
        }
        
        if services == nil || services?.count == 0 {
            return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", forIndexPath: indexPath)
        }
        
        let sectionFooter: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", forIndexPath: indexPath)
        let service  = services![indexPath.row]
        let buyBtn: UIButton = UIButton.init(type: .Custom)
        buyBtn.addTarget(self, action: #selector(buyNowButtonAction(_:)), forControlEvents: .TouchUpInside)
        buyBtn.backgroundColor = UIColor.whiteColor()
        buyBtn.setTitle("购买此服务", forState: .Normal)
        buyBtn.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), forState: .Normal)
        buyBtn.layer.masksToBounds = true
        buyBtn.layer.cornerRadius = 5
        buyBtn.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
        buyBtn.layer.borderWidth = 1
        buyBtn.hidden = service.privilege_lv_ > DataManager.currentUser!.centurionCardLv ? false : true
        sectionFooter.addSubview(buyBtn)
        buyBtn.snp_makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.height.equalTo(44)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
        return sectionFooter
    }

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.whiteColor()
        backgroundColor = UIColor.whiteColor()
        
        contentCollection.delegate = self
        contentCollection.dataSource = self
        contentView.addSubview(contentCollection)
        contentCollection.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(-10)
            make.bottom.equalTo(0)
        }

    }
    
    func setInfo(services: Results<CenturionCardServiceInfo>?) {
       
        self.services = services
        if services!.count == 0 {
            let noDataLabel = UILabel.init(text: "只接受内部邀请\n\n\n\n", font: UIFont.systemFontOfSize(S15), textColor: colorWithHexString("#666666"))
            noDataLabel.textAlignment = .Center
            noDataLabel.backgroundColor = UIColor.whiteColor()
            contentView.addSubview(noDataLabel)
            noDataLabel.snp_makeConstraints(closure: { (make) in
                make.edges.equalTo(contentView)
            })
            contentView.bringSubviewToFront(noDataLabel)
            return
        }else{
            contentView.bringSubviewToFront(contentCollection)
        }
        
        contentCollection.reloadData()
        
    }

    func buyNowButtonAction(sender:UIButton) {
        guard delegate != nil else { return }
        delegate!.buyNowButtonTouched()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
