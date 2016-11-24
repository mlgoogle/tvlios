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
    
    func serviceTouched(_ service: CenturionCardServiceInfo)
    func buyNowButtonTouched()
}


class CenturionCardServerItem: UICollectionViewCell {
    lazy var iconBtn: UIButton = {
        let iconBtn = UIButton.init(type: .custom)
        iconBtn.isUserInteractionEnabled = false
        return iconBtn
    }()
    var titleLabel: UILabel = {
        let label = UILabel.init(text: "", font: UIFont.systemFont(ofSize: S12), textColor: colorWithHexString("#666666"))
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconBtn)
        iconBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(AtapteWidthValue(10))
            make.size.equalTo(CGSizeMake(AtapteWidthValue(40), AtapteWidthValue(40)))
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(iconBtn.snp.bottom).offset(AtapteWidthValue(4))
            make.height.equalTo(S12)
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
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: (ScreenWidth-20)/4, height: AtapteWidthValue(80))
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(CenturionCardServerItem.classForCoder(), forCellWithReuseIdentifier: "CenturionCardServerItem")
        collectionView.isScrollEnabled = false
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "cardFooterView")
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "buyBtnFooterView")
        return collectionView
    }()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services == nil ? 0 : services!.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item: CenturionCardServerItem = collectionView.dequeueReusableCell(withReuseIdentifier: "CenturionCardServerItem", for: indexPath) as! CenturionCardServerItem
        let service  = services![indexPath.row]
        let url = service.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ? service.privilege_pic_yes_ : service.privilege_pic_no_
        item.iconBtn.kf_setBackgroundImageWithURL(URL(string: url!), forState: .Normal, placeholderImage: UIImage.init(named: "face-btn"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        item.titleLabel.text = service.privilege_name_!
        return item
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate!.serviceTouched(services![indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        if services == nil || services?.count == 0 {
            return CGSize.zero
        }
        
        let service  = services![0]
        return service.privilege_lv_ <= DataManager.currentUser!.centurionCardLv ?  CGSize.init(width: ScreenWidth, height: AtapteWidthValue(250)) : CGSize.init(width: ScreenWidth, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return UICollectionReusableView()
        }
        
        if services == nil || services?.count == 0 {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath)
            return footerView
        }
        let service  = services![indexPath.row]
        if service.privilege_lv_ <= DataManager.currentUser!.centurionCardLv {
            
            let sectionFooter: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "cardFooterView", for: indexPath)
            
            let blackCardImage = BlackCardView.init(frame: CGRect.zero)
            blackCardImage.layer.cornerRadius = 8
            blackCardImage.layer.masksToBounds = true
            blackCardImage.stars = DataManager.currentUser!.centurionCardLv
            sectionFooter.addSubview(blackCardImage)
            blackCardImage.snp.makeConstraints({ (make) in
                make.bottom.equalTo(-10)
                make.left.equalTo(AtapteWidthValue(20))
                make.right.equalTo(-AtapteWidthValue(20))
                make.height.equalTo(AtapteWidthValue(200))
            })
            sectionFooter.reloadInputViews()
            return sectionFooter
        }
        
        let sectionFooter: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "buyBtnFooterView", for: indexPath)
        let buyBtn: UIButton = UIButton.init(type: .custom)
        buyBtn.addTarget(self, action: #selector(buyNowButtonAction(_:)), for: .touchUpInside)
        buyBtn.backgroundColor = UIColor.white
        buyBtn.setTitle("购买此服务", for: UIControlState())
        buyBtn.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), for: UIControlState())
        buyBtn.layer.masksToBounds = true
        buyBtn.layer.cornerRadius = 5
        buyBtn.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
        buyBtn.layer.borderWidth = 1
        buyBtn.isHidden = service.privilege_lv_ > DataManager.currentUser!.centurionCardLv ? false : true
        sectionFooter.addSubview(buyBtn)
        buyBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.height.equalTo(44)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
        return sectionFooter
    }

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.white
        backgroundColor = UIColor.white
        
        contentCollection.delegate = self
        contentCollection.dataSource = self
        contentView.addSubview(contentCollection)
        contentCollection.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
    }
    
    func setInfo(_ services: Results<CenturionCardServiceInfo>?) {
       
        self.services = services
        if services!.count == 0 {
            let noDataLabel = UILabel.init(text: "只接受内部邀请\n\n\n\n", font: UIFont.systemFont(ofSize: S15), textColor: colorWithHexString("#666666"))
            noDataLabel.textAlignment = .center
            noDataLabel.backgroundColor = UIColor.white
            contentView.addSubview(noDataLabel)
            noDataLabel.snp.makeConstraints({ (make) in
                make.edges.equalTo(contentView)
            })
            contentView.bringSubview(toFront: noDataLabel)
            return
        }else{
            contentView.bringSubview(toFront: contentCollection)
        }
        
        contentCollection.reloadData()
        
    }

    func buyNowButtonAction(_ sender:UIButton) {
        guard delegate != nil else { return }
        delegate!.buyNowButtonTouched()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
