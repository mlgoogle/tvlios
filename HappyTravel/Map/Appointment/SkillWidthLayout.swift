//
//  SkillWidthLayout.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
protocol SkillWidthLayoutDelegate : NSObjectProtocol {

    func autoLayout(layout:SkillWidthLayout, atIndexPath:NSIndexPath)->CGFloat
}

class SkillWidthLayout: UICollectionViewFlowLayout {

    
    /**
     默认属性 可外部修改
     */

    var columnMargin:CGFloat = 0.0
    var rowMargin:CGFloat = 6.0
    var skillSectionInset = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
    var itemHeight:CGFloat = 24.0
    /*
     需实现代理方法获取width 
     */
    weak var delegate:SkillWidthLayoutDelegate?

    
   private var currentX:CGFloat = 0.0
   private var currentY:CGFloat = 0.0
   private var currentMaxX:CGFloat = 0.0
   private var attributedAry:Array<UICollectionViewLayoutAttributes>?
    
    
    
    override init() {
        super.init()
        
         columnMargin = 10.0
         rowMargin = 10.0
         skillSectionInset = UIEdgeInsetsMake(10.0, 16.0, 16.0, 16.0)
         itemHeight = 24.0
        attributedAry =  Array()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
        重写layout
     */
    
    
    override func prepareLayout() {
        currentX = skillSectionInset.left
        currentY = skillSectionInset.top
        currentMaxX = currentX
        attributedAry?.removeAll()
        if let count = collectionView?.numberOfItemsInSection(0) {
            for index in 0..<count {
                let atr = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))
                
                attributedAry?.append(atr!)
                
            }
        }

    }
    
    /**
     
     判断是否需要重新计算layout
     - parameter newBounds:
     
     - returns:
     */
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {

        let oldBounds = collectionView?.bounds
        if CGRectGetWidth(oldBounds!) != CGRectGetWidth(newBounds) {
            
            return true
        } else {
            return false
        }
    }
    
    /**
     计算collectionView的Contensize
     
     - returns:
     */
    override func collectionViewContentSize() -> CGSize {
        
        if let atr = attributedAry?.last {
            
            let frame = atr.frame
            let height = CGRectGetMaxY(frame) + skillSectionInset.bottom
            return CGSizeMake(0, height)
        }
        return CGSizeMake(0, 0)
    }
    /**
     
    返回每个cell的layout
     - parameter indexPath:
     
     - returns:
     */
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let maxWidth = collectionView?.frame.size.width
        
        
        let itemW = delegate!.autoLayout(self, atIndexPath:indexPath)
        
        let atr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        atr.frame = CGRectMake(currentX, currentY, itemW, itemHeight)
        currentMaxX = currentX + itemW + skillSectionInset.right
        if currentMaxX - maxWidth! > 0 {
            currentX = skillSectionInset.left
            currentY = currentY + itemHeight + rowMargin
            atr.frame = CGRectMake(currentX, currentY, itemW, itemHeight)
            currentX = currentX + itemW + columnMargin
        } else {
            currentX = currentX + itemW + columnMargin
        }
        return atr
    }
    
    /**
     
     layout数据源
     - parameter rect:
     
     - returns:
     */
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributedAry
    }
    
}

