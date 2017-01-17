//
//  NewPersonMaskView.swift
//  HappyTravel
//
//  Created by J-bb on 17/1/12.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit

@objc protocol TouchViewDelegate:NSObjectProtocol {
    
    
    optional func touchedEndMaskView()
}

enum GuideDirection:Int {
    case Top = 1
    case Bottom = 2
    case Right = 3
    case Left = 4
}
typealias TouchBlock = () ->()
class NewPersonMaskView: UIView {
    weak var delegate:TouchViewDelegate?
    var touchedEndBlock:TouchBlock?
    
    var margin = 70
    lazy var guideImageView:UIImageView = {
       let imageView = UIImageView()
        
        return imageView
    }()
    
    lazy var infoImageView:UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    var infoImages: Array<String>?
    var guideImages: Array<String>?
    
    /// 在文字信息下面 或者上面
    var guideTypes:Array<GuideDirection>?
    
    /// 文字信息在guideImage的相对位置
    var infoTypes:Array<GuideDirection>?
    /// 取frame的X Y 为guideImages的X Y
    var frameXYs:Array<CGRect>?
    
    var count = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.8)
        addSubview(guideImageView)
        addSubview(infoImageView)
    }
    

    /**
     填充蒙版照片信息
     
     - parameter guideImages:
     - parameter infoImages:
     */
    func setImages(guideImages:Array<String>, infoImages:Array<String>) {
        self.guideImages = guideImages
        self.infoImages = infoImages
    }
    /**
     设置需要展示的图片相对于info的位置
     
     - parameter guideTypes:
     - parameter infoTypes:
     */
    func setTypes(guideTypes:Array<GuideDirection>, infoTypes:Array<GuideDirection>) {
        self.guideTypes = guideTypes
        self.infoTypes = infoTypes
    }
    /**
     设置需要展示的图片的位置
     
     - parameter frames:
     */
    func setFrames(frames:Array<CGRect>) {
        frameXYs = frames
    }
    /**
     开始蒙版提示
     */
    func startGuide() {
        count = 0
        guard guideTypes != nil && infoTypes != nil else {return}
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        guide()

    }
    func guide() {
        guideImageView.image = UIImage(named: guideImages![count])
        infoImageView.image = UIImage(named: infoImages![count])
        setGuideImageViewFrameXY(frameXYs![count], showViewType: guideTypes![count], infoType: infoTypes![count])
    }
    
    func setGuideImageViewFrameXY(frame:CGRect, showViewType:GuideDirection?, infoType:GuideDirection?) {
       
        guideImageView.snp_remakeConstraints(closure: { (make) in
            make.left.equalTo(frame.origin.x)
            make.top.equalTo(frame.origin.y)
            make.size.equalTo((guideImageView.image?.size)!)
        })
        
        infoImageView.snp_remakeConstraints(closure: { (make) in
            if showViewType == GuideDirection.Bottom {
                make.bottom.equalTo(guideImageView.snp_top).offset(-20)
            } else if showViewType == GuideDirection.Top {
                make.top.equalTo(guideImageView.snp_bottom).offset(20)
            }
            make.centerX.equalTo(self)
        })
    }


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        count += 1
        if count == guideImages!.count {
            delegate?.touchedEndMaskView!()
            touchedEndBlock?()
            return
        }
        guide()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
