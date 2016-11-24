//
//  BlackCardView.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/16.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit


class BlackCardView: UIView {

    lazy var bgImage: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "blackCardFrontBg"))
        return imageView
    }()
    
    lazy var iconImage: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "blackCardIcon"))
        return imageView
    }()
    
    lazy var yudianLabel: UILabel = {
       let label = UILabel.init(text: "YUNDIAN BLACK CARD CLUB\n YUNDIAN MEMBERSHIP", font: UIFont.boldSystemFont(ofSize: S12), textColor: colorWithHexString("#dfd1ad"))
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel.init(text: "NAME" , font: UIFont.boldSystemFont(ofSize: S12), textColor: colorWithHexString("#dfd1ad"))
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let fromDate: Date = Date.init(timeIntervalSince1970: TimeInterval(DataManager.currentUser!.centurionCardStartTime))
        let moneth = fromDate.yt_month() > 9 ? "\(fromDate.yt_month())" : "0\(fromDate.yt_month())"
        let day = fromDate.yt_day() > 9 ? "\(fromDate.yt_day())" : "0\(fromDate.yt_day())"
        let label = UILabel.init(text: "\(moneth)/\(day)", font: UIFont.boldSystemFont(ofSize: AtapteWidthValue(11)), textColor: colorWithHexString("#dfd1ad"))
        label.textAlignment = .center
        return label
    }()
    
    lazy var rightNmberLabel : UILabel = {
        let label = UILabel.init(text: "8888", font: UIFont.boldSystemFont(ofSize: S18), textColor: colorWithHexString("#dfd1ad"))
        return label
    }()
    
    lazy var leftNumberLabel : UILabel = {
        let label = UILabel.init(text: "8888", font: UIFont.boldSystemFont(ofSize: S18), textColor: colorWithHexString("#dfd1ad"))
        return label
    }()
    
    var stars: NSInteger?{
        didSet{
            for i in 0...4 {
                let startImage = viewWithTag(100+i) as! UIImageView
                let imageName = 5 - i <= stars! ? "yellowStart" : "whiteStart"
                startImage.image = UIImage.init(named: imageName)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        let contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        bgImage.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(35)
            make.left.equalTo(AtapteWidthValue(50))
            make.right.equalTo(-AtapteWidthValue(45))
            make.bottom.equalTo(-35)
        }
        
        contentView.addSubview(yudianLabel)
        yudianLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView)
            make.top.equalTo(contentView)
        }
        
        for i in 0...4 {
            let startImage = UIImageView.init(image: UIImage.init(named:"whiteStart"))
            startImage.tag = 100 + i
            contentView.addSubview(startImage)
            startImage.snp.makeConstraints({ (make) in
                make.right.equalTo(-16*i)
                make.bottom.equalTo(yudianLabel.snp.bottom).offset(-2)
                make.size.equalTo(CGSize.init(width: 12, height: 12))
            })
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView)
        }
        let name = pinyin(DataManager.currentUser?.centurionCardName == nil ? "" : (DataManager.currentUser?.centurionCardName)!)
        nameLabel.text = name.uppercased()
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.width.equalTo(88)
        }
        
        let dateTitleLabel = UILabel.init(text: "MONTH/YEAR", font: UIFont.boldSystemFont(ofSize: S10), textColor: colorWithHexString("#dfd1ad"))
        dateTitleLabel.textAlignment = .center
        contentView.addSubview(dateTitleLabel)
        dateTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(dateLabel.snp.top)
            make.width.equalTo(88)
            make.left.equalTo(dateLabel)
        }
        
        contentView.addSubview(iconImage)
        iconImage.snp.makeConstraints { (make) in
            make.center.equalTo(contentView)
            make.size.equalTo(CGSizeMake(AtapteWidthValue(50), AtapteWidthValue(50)))
        }
    
        var blackCardNum = "\(DataManager.currentUser!.centurionCardId)" as NSString
        if blackCardNum.length < 8 {
            for _ in 0...(8-blackCardNum.length) {
                blackCardNum = "0\(blackCardNum)" as NSString
            }
        }
        let frontNum = blackCardNum.substring(to: 4)
        let backNum = blackCardNum.substring(with: NSRange.init(location: 5, length: 4))
        
        contentView.addSubview(leftNumberLabel)
        leftNumberLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(iconImage.snp.left).offset(-AtapteWidthValue(10))
        }
        leftNumberLabel.text = frontNum
        
        contentView.addSubview(rightNmberLabel)
        rightNmberLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(iconImage.snp.right).offset(AtapteWidthValue(10))
        }
        rightNmberLabel.text = backNum
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pinyin(_ str: String) -> String {
        
        let chinese = NSMutableString(string: str) as CFMutableString
        if CFStringTransform(chinese, nil, kCFStringTransformToLatin, false) {
            if CFStringTransform(chinese, nil, kCFStringTransformStripDiacritics, false){
                
            }
        }
        return chinese as String
    }
}
