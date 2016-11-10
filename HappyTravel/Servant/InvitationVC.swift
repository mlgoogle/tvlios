//
//  InvitationVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/10.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class InvitationVC: UIViewController, AnnularProgressViewDelegate {
    
    var annularProgressView:AnnularProgressView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        view.frame = UIScreen.mainScreen().bounds
        
        initView()
    }

    func initView() {
        view.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.8)
        
        creatTimer()
        
        let tipsLabel = UILabel()
        tipsLabel.font = UIFont.systemFontOfSize(S18)
        tipsLabel.textAlignment = NSTextAlignment.Center
        tipsLabel.backgroundColor = UIColor.clearColor()
        tipsLabel.textColor = UIColor.whiteColor()
        tipsLabel.text = "等待对方同意邀约"
        view.addSubview(tipsLabel)
        tipsLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.annularProgressView!.snp_top).offset(-20)
            make.width.equalTo(view)
            make.height.equalTo(18)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消邀约", forState: UIControlState.Normal)
        cancelBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancelBtn.backgroundColor = UIColor.clearColor()
        cancelBtn.layer.borderColor = UIColor.whiteColor().CGColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.layer.masksToBounds = true
        cancelBtn.addTarget(self, action: #selector(cancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.annularProgressView!.snp_bottom).offset(40)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        
    }
    
    func creatTimer(){
        annularProgressView = AnnularProgressView()
        annularProgressView?.delegate = self
        annularProgressView!.maximumValue = 100
        view.addSubview(annularProgressView!)
        annularProgressView?.snp_makeConstraints(closure: { (make) in
            make.center.equalTo(self.view)
            make.width.equalTo(150)
            make.height.equalTo(150)
        })
    }
    
    func start() {
        XCGLogger.defaultInstance().debug("\(NSDate.init().timeIntervalSince1970)")
        annularProgressView?.startAnimation()
    }
    
    func cancel(sender: AnyObject?) {
        view.removeFromSuperview()
    }

    // MARK: - AnnularProgressViewDelegate
    func timeout() {
        XCGLogger.defaultInstance().debug("\(NSDate.init().timeIntervalSince1970)")
        view.removeFromSuperview()
    }
}


protocol AnnularProgressViewDelegate : NSObjectProtocol {
    
    func timeout()
    
}


class AnnularProgressView: UIView {
    
    weak var delegate:AnnularProgressViewDelegate?
    
    var timeLabel:UILabel?
    
    var value: CGFloat = 0 {
        didSet {
            timeLabel?.text = "\(maximumValue-value)秒"
            self.setNeedsDisplay()
        }
    }
    
    var maximumValue: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        opaque = false
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 150 / 2
        layer.masksToBounds = true
        initView()
    }
    
    func initView() {
        timeLabel = UILabel()
        timeLabel?.backgroundColor = UIColor.clearColor()
        timeLabel?.font = UIFont.systemFontOfSize(AtapteWidthValue(22))
        timeLabel?.textAlignment = NSTextAlignment.Center
        addSubview(timeLabel!)
        timeLabel?.snp_makeConstraints(closure: { (make) in
            make.center.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(22)
        })
    }
    
    func startAnimation() {
        value += 1
        if value == maximumValue {
            value = 0
            delegate?.timeout()
            return
        }
        performSelector(#selector(AnnularProgressView.startAnimation), withObject: self, afterDelay: 0.1)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let lineWidth: CGFloat = 4.0
        let radius = CGRectGetWidth(rect) / 2.0 - lineWidth
        let centerX = CGRectGetMidX(rect)
        let centerY = CGRectGetMidY(rect)
        let startAngle = CGFloat(-90 * M_PI / 180)
        let endAngle = CGFloat(((self.value / self.maximumValue) * 360 - 90) ) * CGFloat(M_PI) / 180
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1).CGColor)
        CGContextSetLineWidth(context, lineWidth)
        CGContextAddArc(context, centerX, centerY, radius, startAngle, endAngle, 0)
        CGContextStrokePath(context)
        CGContextSetStrokeColorWithColor(context, UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor)
        CGContextAddArc(context, centerX, centerY, radius, startAngle, endAngle, 1)
        CGContextStrokePath(context)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
