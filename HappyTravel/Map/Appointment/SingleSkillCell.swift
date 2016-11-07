//
//  SingleSkillCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class SingleSkillCell: UICollectionViewCell {
    
    private lazy var deleteButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clearColor()
        button.setTitle("-", forState: .Normal)
        button.layer.borderColor =  UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
        button.setTitleColor( UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), forState: .Normal)
        return button
    }()
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.textAlignment = .Center
        label.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
        label.layer.borderWidth = 1.0
        label.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
        label.font = UIFont.systemFontOfSize(17)
        return label
    }()
    
    
   override  init(frame: CGRect) {
        super.init(frame: frame)
    contentView.addSubview(deleteButton)
    contentView.addSubview(titleLabel)
    
    }
    override func layoutSubviews() {
        titleLabel.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    
    
    
    
    /**
     根据style 来设置
     
     - parameter name:
     - parameter style:
     */
    func setupDataWith(name:String, style:SkillsCellStyle) {
        
        titleLabel.text = name
        
        switch style {
        case .Normal :

            setUpWith(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), borderColor: UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor, cornerRadius: 12.0, isDelete: false)
            break
        case .AddNew :
            setUpWith(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), borderColor: UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor, cornerRadius:  12.0 ,isDelete: false)
            break
        case .Select :
            setUpWith(UIColor.grayColor(), borderColor: UIColor.grayColor().CGColor, cornerRadius:  12.0, isDelete: false)
            break
        case .Delete :
            setUpWith(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), borderColor: UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor, cornerRadius:  12.0, isDelete: true)

            break
         default:
            break
        }
        
    }

    /**
     设置圆角、边框颜色、字体颜色、deleteButton隐藏
     
     - parameter textColor:
     - parameter borderColor:
     - parameter cornerRadius:
     - parameter isDelete:
     */
    private func  setUpWith(textColor:UIColor, borderColor:CGColor, cornerRadius:CGFloat, isDelete:Bool) {
        titleLabel.textColor = textColor
        titleLabel.layer.borderColor = borderColor
        titleLabel.layer.cornerRadius = cornerRadius

        deleteButton.hidden = !isDelete
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
