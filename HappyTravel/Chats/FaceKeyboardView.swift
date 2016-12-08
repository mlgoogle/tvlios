//
//  FaceKeyboardView.swift
//  viossvc
//
//  Created by abx’s mac on 2016/12/6.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
protocol FaceKeyboardViewDelegate :NSObjectProtocol{
    func faceKeyboardView(faceKeyboardView:FaceKeyboardView ,didKeyCode keyCode : String)

}
class FaceKeyboardView: UIView ,UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var pageControl : UIPageControl!
    var faceDelegate : FaceKeyboardViewDelegate?
     let identifierCell = "FaceCollectionCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.registerClass(FaceCollectionCell.classForCoder() , forCellWithReuseIdentifier: identifierCell)
        self.pageControl.pageIndicatorTintColor = UIColor.grayColor();
        self.pageControl.currentPageIndicatorTintColor =  UIColor.darkGrayColor();
        self.pageControl.numberOfPages = EmojiFaceHelper.shared.getFaceArray().count / 28
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmojiFaceHelper.shared.getFaceArray().count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifierCell, forIndexPath: indexPath) as! FaceCollectionCell
        cell.update(EmojiFaceHelper.shared.getFaceArray()[indexPath.row])
        return cell;
    }
   func collectionView(collectionView: UICollectionView, layout collectionViewLayout :UICollectionViewLayout ,   sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
      return  CGSizeMake(UIScreen.mainScreen().bounds.size.width / 7.0, 45);
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if faceDelegate != nil {
            faceDelegate?.faceKeyboardView(self, didKeyCode: EmojiFaceHelper.shared.getFaceArray()[indexPath.row])
        }

    }
    
}

class FaceCollectionCell: UICollectionViewCell{
    var faceLabel :UILabel?
    private var _imageView : UIImageView?
    var imageView :UIImageView {
        set {
            _imageView = newValue
        }
        get {
            if _imageView == nil {
                _imageView = UIImageView()
                _imageView!.image = UIImage(named:"cm_emojiDelete")
                _imageView!.contentMode = .Center;
                _imageView!.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
                self.addSubview(_imageView!)
            }
            return _imageView!
        }
        
    }
    
    func update(data: AnyObject!) {
       let string = data as! String
        faceLabel?.text = string
        if faceLabel?.text?.characters.count == 0 {

            imageView.hidden = false;
            faceLabel?.hidden = true;
        }
        else {
            imageView.hidden = true;
            faceLabel?.hidden = false;
        }
    }
    
    override var frame: CGRect{
        didSet {
            if faceLabel == nil{
                faceLabel = UILabel();
                faceLabel!.textAlignment = .Center;
                faceLabel!.font = UIFont.systemFontOfSize(32)
                self.addSubview(faceLabel!)
            }
            faceLabel!.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        }
        
    }
    
    
    

}
