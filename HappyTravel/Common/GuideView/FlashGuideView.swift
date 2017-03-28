//
//  FlashGuideView.swift
//  TestAdress
//
//  Created by J-bb on 17/1/14.
//  Copyright © 2017年 J-bb. All rights reserved.
//

import UIKit

protocol ShowHomePageActionDelegate:NSObjectProtocol {
    
    func selectAtLastPage()
}

class FlashGuideView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, FlashGuideCellDelegate {
    
    var images:Array<UIImage>?
    var imagesUrl:Array<String>?
    weak var delegate:ShowHomePageActionDelegate?
    /// Source is image or imageUrl. default is true.
    var isImage = true
    lazy var collectionView:UICollectionView = {
    
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .Horizontal
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.pagingEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    convenience init(imagesUrlArray:Array<String>) {
        
        self.init(frame:UIScreen.mainScreen().bounds)
        addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        imagesUrl = imagesUrlArray
        isImage = false
        collectionView.contentSize = CGSizeMake((UIScreen.mainScreen().bounds.size.width * CGFloat(imagesUrl!.count - 1)), 0)
        collectionView.delegate = self

        collectionView.dataSource = self
        collectionView.registerClass(FlashGuideCell.self, forCellWithReuseIdentifier: "FlashGuideCell")
        collectionView.reloadData()
    }
    convenience init(imagesArray:Array<UIImage>) {
        self.init(frame:UIScreen.mainScreen().bounds)
        addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        images = imagesArray
        isImage = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(FlashGuideCell.self, forCellWithReuseIdentifier: "FlashGuideCell")
        collectionView.reloadData()
    }
    
    
    //MARK: -
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isImage {
            
            return images?.count ?? 0
        }
        
        return imagesUrl?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlashGuideCell", forIndexPath: indexPath) as! FlashGuideCell
        cell.delegate = self
        var count = 0
        if isImage {
            cell.setImage(images![indexPath.item])
            count = images!.count
        } else {
            count = imagesUrl!.count
            cell.setImageUrl(imagesUrl![indexPath.item])
        }
        if indexPath.item == count - 1 {
            cell.showHomeButton.hidden = true
            cell.showHomeButton.addTarget(self, action: #selector(FlashGuideView.showHomePage), forControlEvents: .TouchUpInside)
            
        } else {
            cell.showHomeButton.hidden = true

        }
        
        cell.ignoreButton.hidden = indexPath.item == count - 1
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if isImage {
            
            if  indexPath.item == images!.count - 1 {
                showHomePage()
            }
            
        } else {
            if  indexPath.item == imagesUrl!.count - 1 {
                showHomePage()
            }
        }
        
    }
    
    func showHomePage() {
        delegate?.selectAtLastPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func ignore() {
        delegate?.selectAtLastPage()
    }

}
