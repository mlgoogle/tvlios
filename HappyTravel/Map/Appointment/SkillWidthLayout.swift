//
//  SkillWidthLayout.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
protocol SkillWidthLayoutDelegate : NSObjectProtocol {

    func autoLayout(_ layout:SkillWidthLayout, atIndexPath:IndexPath)->Float
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

    
   fileprivate var currentX:Float = 0.0
   fileprivate var currentY:Float = 0.0
   fileprivate var currentMaxX:Float = 0.0
   fileprivate var attributedAry:Array<UICollectionViewLayoutAttributes>?
    
    
    
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
    
    
    override func prepare() {
        currentX = Float(skillSectionInset.left)
        currentY = Float(skillSectionInset.top)
        currentMaxX = currentX
        attributedAry?.removeAll()
        if let count = collectionView?.numberOfItems(inSection: 0) {
            for index in 0..<count {
                let atr = layoutAttributesForItem(at: IndexPath(item: index, section: 0))
                
                attributedAry?.append(atr!)
                
            }
        }

    }
    
    /**
     
     判断是否需要重新计算layout
     - parameter newBounds:
     
     - returns:
     */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {

        let oldBounds = collectionView?.bounds
        if oldBounds!.width != newBounds.width {
            
            return true
        } else {
            return false
        }
    }
    
    /**
     计算collectionView的Contensize
     
     - returns:
     */
    override var collectionViewContentSize : CGSize {
        
        if let atr = attributedAry?.last {
            
            let frame = atr.frame
            let height = frame.maxY + skillSectionInset.bottom
            return CGSize(width: 0, height: height)
        }
        return CGSize(width: 0, height: 0)
    }
    /**
     
    返回每个cell的layout
     - parameter indexPath:
     
     - returns:
     */
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let maxWidth = collectionView?.frame.size.width
        
        
        let itemW = delegate!.autoLayout(self, atIndexPath:indexPath)
        
        let atr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        atr.frame = CGRect(x: CGFloat(currentX), y: CGFloat(currentY), width: CGFloat(itemW), height: itemHeight)
        currentMaxX = currentX + itemW + Float(skillSectionInset.right)
        if currentMaxX - Float(maxWidth!) > 0 {
            currentX = Float(skillSectionInset.left)
            currentY = currentY + Float(itemHeight) + Float(rowMargin)
            atr.frame = CGRect(x: CGFloat(currentX), y: CGFloat(currentY), width: CGFloat(itemW), height: itemHeight)
            currentX = currentX + itemW + Float(columnMargin)
        } else {
            currentX = currentX + itemW + Float(columnMargin)
        }
        return atr
    }
    
    /**
     
     layout数据源
     - parameter rect:
     
     - returns:
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributedAry
    }
    
}

