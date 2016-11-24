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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        view.frame = UIScreen.main.bounds
        
        initView()
    }

    func initView() {
        view.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.8)
        
        creatTimer()
        
        let tipsLabel = UILabel()
        tipsLabel.font = UIFont.systemFont(ofSize: S18)
        tipsLabel.textAlignment = NSTextAlignment.center
        tipsLabel.backgroundColor = UIColor.clear
        tipsLabel.textColor = UIColor.white
        tipsLabel.text = "等待对方同意邀约"
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.annularProgressView!.snp.top).offset(-20)
            make.width.equalTo(view)
            make.height.equalTo(18)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消邀约", for: UIControlState())
        cancelBtn.setTitleColor(UIColor.white, for: UIControlState())
        cancelBtn.backgroundColor = UIColor.clear
        cancelBtn.layer.borderColor = UIColor.white.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.layer.masksToBounds = true
        cancelBtn.addTarget(self, action: #selector(cancel(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.annularProgressView!.snp.bottom).offset(40)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        
    }
    
    func creatTimer(){
        annularProgressView = AnnularProgressView()
        annularProgressView?.delegate = self
        annularProgressView!.maximumValue = 100
        view.addSubview(annularProgressView!)
        annularProgressView?.snp.makeConstraints({ (make) in
            make.center.equalTo(self.view)
            make.width.equalTo(150)
            make.height.equalTo(150)
        })
    }
    
    func start() {
        XCGLogger.debug("\(Date.init().timeIntervalSince1970)")
        annularProgressView?.startAnimation()
    }
    
    func cancel(_ sender: AnyObject?) {
        view.removeFromSuperview()
    }

    // MARK: - AnnularProgressViewDelegate
    func timeout() {
        XCGLogger.debug("\(Date.init().timeIntervalSince1970)")
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
        isOpaque = false
        backgroundColor = UIColor.white
        layer.cornerRadius = 150 / 2
        layer.masksToBounds = true
        initView()
    }
    
    func initView() {
        timeLabel = UILabel()
        timeLabel?.backgroundColor = UIColor.clear
        timeLabel?.font = UIFont.systemFont(ofSize: AtapteWidthValue(22))
        timeLabel?.textAlignment = NSTextAlignment.center
        addSubview(timeLabel!)
        timeLabel?.snp.makeConstraints({ (make) in
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
        perform(#selector(AnnularProgressView.startAnimation), with: self, afterDelay: 0.1)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let lineWidth: CGFloat = 4.0
        let radius = rect.width / 2.0 - lineWidth
        let centerX = rect.midX
        let centerY = rect.midY
        let startAngle = CGFloat(-90 * M_PI / 180)
        let endAngle = CGFloat(((self.value / self.maximumValue) * 360 - 90) ) * CGFloat(M_PI) / 180
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1).cgColor)
        context?.setLineWidth(lineWidth)
        CGContextAddArc(context, centerX, centerY, radius, startAngle, endAngle, 0)
        context?.strokePath()
        context?.setStrokeColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor)
        CGContextAddArc(context, centerX, centerY, radius, startAngle, endAngle, 1)
        context?.strokePath()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
