//
//  IdentCommentCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger


class IdentCommentCell: UITableViewCell, UITextViewDelegate {
    
    var servantInfo:UserInfo?
    
    var hodometerInfo:HodometerInfo?
    
    var serviceStar = 0
    var servantStar = 0
    var comment = ""
    var serviceStars: [UIButton] = []
    var userStars: [UIButton] = []
    
    
    let tags = ["bgView": 1001,
                "headImageView": 1002,
                "textView": 1003,
                "lineView": 1004,
                "starBGView":1005,
                "lineTitleLab": 1006]
    
    var serviceSocre:Int? {
        didSet{
            for i in 0...Int((serviceStars.count)-1){
                let star = serviceStars[i]
                star.selected = i <= serviceSocre! - 1
                star.userInteractionEnabled = false
            }
        }
    }
    
    
    var userScore:Int? {
        didSet{
            for i in 0...Int((userStars.count)-1){
                let star = userStars[i]
                star.selected = i <= userScore! - 1
                star.userInteractionEnabled = false
            }
        }
    }
    
    var remark:String? {
        didSet{
            let textView = contentView.viewWithTag(tags["textView"]!) as! UITextView
            textView.text = remark
            textView.userInteractionEnabled = false
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
        contentView.userInteractionEnabled = true
        userInteractionEnabled = true
        
        var bgView = contentView.viewWithTag(tags["bgView"]!)
        if bgView == nil {
            bgView = UIView()
            bgView!.tag = tags["bgView"]!
            bgView?.backgroundColor = UIColor.whiteColor()
            bgView?.userInteractionEnabled = true
            bgView?.layer.cornerRadius = 5
            bgView?.layer.masksToBounds = true
            contentView.addSubview(bgView!)
            bgView?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView)
            })
        }

        let lineTitles = ["PAPI酱 全天游 评价", "服务者评价", "评论"]
        var lastLineView:UIView?
        for i in 0...2 {
            var lineView = bgView?.viewWithTag(tags["lineView"]! * 10 + i)
            if lineView == nil {
                lineView = UIView()
                lineView?.tag = tags["lineView"]! * 10 + i
                lineView?.backgroundColor = UIColor.init(decR: 230, decG: 230, decB: 230, a: 1)
                bgView?.addSubview(lineView!)
                lineView?.snp_makeConstraints(closure: { (make) in
                    make.top.equalTo(bgView!).offset(25 + 90 * i)
                    make.left.equalTo(bgView!).offset(40)
                    make.right.equalTo(bgView!).offset(-40)
                    make.height.equalTo(1)
                })
            }
            lastLineView = lineView
            
            var lineTitleLab = bgView?.viewWithTag(tags["lineTitleLab"]! * 10 + i) as? UILabel
            if lineTitleLab == nil {
                lineTitleLab = UILabel()
                lineTitleLab?.tag = tags["lineTitleLab"]! * 10 + i
                lineTitleLab?.backgroundColor = UIColor.whiteColor()
                lineTitleLab?.textColor = UIColor.grayColor()
                lineTitleLab?.textAlignment = .Center
                lineTitleLab?.font = UIFont.systemFontOfSize(S15)
                bgView?.addSubview(lineTitleLab!)
                lineTitleLab?.snp_makeConstraints(closure: { (make) in
                    make.center.equalTo(lineView!)
                })
            }
            lineTitleLab?.text = lineTitles[i]
            
            if i < 2 {
                var starBGView = bgView?.viewWithTag(tags["starBGView"]! * 10 + i)
                if starBGView == nil {
                    starBGView = UIView()
                    starBGView?.tag = tags["starBGView"]! * 10 + i
                    starBGView?.backgroundColor = UIColor.clearColor()
                    starBGView?.userInteractionEnabled = true
                    bgView?.addSubview(starBGView!)
                    starBGView?.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(bgView!).offset(60)
                        make.right.equalTo(bgView!).offset(-60)
                        make.top.equalTo(lineTitleLab!.snp_bottom).offset(16)
                        make.height.equalTo(25)
                    })
                }
                for j in 0...4 {
                    var star = starBGView!.viewWithTag(starBGView!.tag * 10 + j) as? UIButton
                    if star == nil {
                        star = UIButton()
                        star!.backgroundColor = .clearColor()
                        star!.tag = starBGView!.tag * 10 + j
                        star?.addTarget(self, action: #selector(IdentCommentCell.starAction(_:)), forControlEvents: .TouchUpInside)
                        starBGView!.addSubview(star!)
                        star!.snp_makeConstraints(closure: { (make) in
                            if j == 0 {
                                make.left.equalTo(starBGView!)
                            } else {
                                let width = UIScreen.mainScreen().bounds.size.width - 120 - 20
                                make.left.equalTo((starBGView!.viewWithTag(starBGView!.tag * 10 + j - 1) as? UIButton)!.snp_right).offset((width - 25*5) / 4.0)
                            }
                            make.top.equalTo(starBGView!)
                            make.bottom.equalTo(starBGView!)
                        })
                    }
                    star?.setImage(UIImage.init(named: "star-common-hollow"), forState: .Normal)
                    star?.setImage(UIImage.init(named: "star-common-fill"), forState: .Selected)
                    
                    if i == 0 {
                        serviceStars.append(star!)
                    }else{
                        userStars.append(star!)
                    }
                }
            }
        }
        
        var textView = bgView?.viewWithTag(tags["textView"]!) as? UITextView
        if textView == nil {
            textView = UITextView()
            textView?.tag = tags["textView"]!
            textView?.delegate = self
            textView?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
            textView?.textAlignment = .Left
            textView?.textColor = UIColor.init(decR: 100, decG: 100, decB: 100, a: 1)
            textView?.font = UIFont.systemFontOfSize(S15)
            textView?.layer.cornerRadius = 5
            textView?.layer.masksToBounds = true
            textView?.returnKeyType = .Done
            bgView?.addSubview(textView!)
            textView?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(bgView!).offset(10)
                make.right.equalTo(bgView!).offset(-10)
                make.top.equalTo(lastLineView!.snp_bottom).offset(25)
                make.height.equalTo(90)
                make.bottom.equalTo(bgView!).offset(-25)
            })
            textView?.text = "来一两句吧......"
        }
        
    }
    
    func setInfo(info: HodometerInfo?) {
        hodometerInfo = info
        let bgView = contentView.viewWithTag(tags["bgView"]!)
        if let lineTitleLab = bgView?.viewWithTag(tags["lineTitleLab"]! * 10 + 0) as? UILabel {
            lineTitleLab.text = "\(info!.service_name_!) 评价"
        }
    }
    
    func starAction(sender: UIButton) {
        XCGLogger.debug("\(sender.tag)")
        let tmp = sender.tag / ((tags["starBGView"]! * 10 + 1) * 10)
        if tmp == 0 {
            servantStar = sender.tag % ((tags["starBGView"]! * 10) * 10) + 1
        } else {
            serviceStar = sender.tag % ((tags["starBGView"]! * 10 + 1) * 10) + 1
        }
        let tag = sender.tag % 100
        if let bgView = contentView.viewWithTag(tags["bgView"]!) {
            if let starBGView = bgView.viewWithTag(tags["starBGView"]! * 10 + (tag < 10 ? 0 : 1)) {
                for i in 0...4 {
                    if let star = starBGView.viewWithTag(starBGView.tag * 10 + i) as? UIButton {
                        star.selected = star.tag <= sender.tag ? true : false
                    }
                }
            }
            
        }
        
    }
    
    //MARK: - TextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "来一两句吧......" {
            textView.text = ""
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if range.location > 255 {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        comment = textView.text!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
