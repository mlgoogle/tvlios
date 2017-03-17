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

typealias TouchBlock = () ->()

class NewPersonMaskView: UIView {
    weak var delegate:TouchViewDelegate?
    var touchedEndBlock:TouchBlock?
    
    lazy var guideImageView:UIImageView = {
       let imageView = UIImageView()
        
        return imageView
    }()
    
    lazy var infoImageView:UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    var mainGuideInfos:[[String: Any?]]?
    var secGuideInfos:[[String: Any?]]?
    
    var count = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.8)
        addSubview(guideImageView)
        addSubview(infoImageView)
    }
    
    /**
     开始蒙版提示
     */
    func startGuide() {
        count = 0
        guard mainGuideInfos != nil else { return }
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        guide()

    }
    
    func guide() {
        resetView(guideImageView, infos: mainGuideInfos!)
        
        if secGuideInfos != nil {
            resetView(infoImageView, infos: secGuideInfos!)
        }

    }
    
    func resetView(imgView: UIImageView, infos: [[String: Any?]]) {
        if let imgName = infos[count]["image"] as? String {
            imgView.image = UIImage(named: imgName)
            imgView.snp_remakeConstraints(closure: { (make) in
                if let size = infos[count]["size"] as? CGSize {
                    make.size.equalTo(size)
                }
                let view = infos[count]["view"] as? UIView
                if let insets = infos[count]["insets"] as? UIEdgeInsets {
                    if insets.left != 8888 {
                        make.left.equalTo(view ?? self).offset(insets.left)
                    }
                    if insets.right != 8888 {
                        make.right.equalTo(view ?? self).offset(insets.right)
                    }
                    if insets.top != 8888 {
                        make.top.equalTo(view ?? self).offset(insets.top)
                    }
                    if insets.bottom != 8888 {
                        make.bottom.equalTo(view ?? self).offset(insets.bottom)
                    }
                }
                
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        count += 1
        if count == mainGuideInfos!.count {
            delegate?.touchedEndMaskView!()
            touchedEndBlock?()
            return
        }
        guide()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
