//
//  ServiceCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

protocol ServiceCellDelegate : NSObjectProtocol {
    
    func spreadAction(sender: AnyObject?)
    
}

public class ServiceCell : UITableViewCell {
    
    let tags = ["view": 1001,
                "serviceLabel": 1002,
                "detailBtn": 1003,
                "bottomControl": 1004,
                "svcView": 1005]
    
    var spread = false
    var servicesInfo:Array<Dictionary<String, AnyObject>>?
    weak var delegate:ServiceCellDelegate?
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = UIColor.clearColor()
        
        var view = contentView.viewWithTag(tags["view"]!)
        if view == nil {
            view = UIView()
            view!.tag = tags["view"]!
            view!.userInteractionEnabled = true
            contentView.addSubview(view!)
            view!.snp_makeConstraints { (make) in
                make.top.equalTo(self.contentView)
                make.left.equalTo(self.contentView)
                make.right.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView)
            }
        }
        
        var serviceLabel = view!.viewWithTag(tags["serviceLabel"]!) as? UILabel
        if serviceLabel == nil {
            let line = UIView()
            line.backgroundColor = UIColor.blackColor()
            view!.addSubview(line)
            line.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(view!).offset(15)
                make.top.equalTo(view!).offset(10)
                make.width.equalTo(2)
                make.height.equalTo(25)
            })
            
            serviceLabel = UILabel(frame: CGRectZero)
            serviceLabel!.tag = tags["serviceLabel"]!
            serviceLabel!.font = UIFont.systemFontOfSize(18)
            serviceLabel!.userInteractionEnabled = true
            serviceLabel!.backgroundColor = UIColor.whiteColor()
            view!.addSubview(serviceLabel!)
            serviceLabel!.snp_remakeConstraints { (make) in
                make.top.equalTo(view!).offset(10)
                make.left.equalTo(line).offset(12)
                make.right.equalTo(view!).offset(-60)
                make.height.equalTo(25)
            }
            serviceLabel!.text = "查看Ta的商务服务"
        }
        
        var detailBtn = view?.viewWithTag(tags["detailBtn"]!) as? UIButton
        if detailBtn == nil {
            detailBtn = UIButton(frame: CGRectZero)
            detailBtn?.tag = tags["detailBtn"]!
            detailBtn!.backgroundColor = UIColor.clearColor()
            detailBtn!.setImage(UIImage.init(named: "guide-detail-arrows"), forState: .Normal)
            detailBtn!.setImage(UIImage.init(named: "guide-detail-arrows-up"), forState: .Selected)
            detailBtn?.contentMode = .ScaleAspectFit
            detailBtn!.addTarget(self, action: #selector(ServiceCell.detailAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            view!.addSubview(detailBtn!)
            detailBtn!.snp_remakeConstraints { (make) in
                make.centerY.equalTo(serviceLabel!)
                make.right.equalTo(view!).offset(-15)
                make.height.equalTo(25)
                make.width.equalTo(25)
            }
        }
        
        var bottomControl = view!.viewWithTag(tags["bottomControl"]!)
        if bottomControl == nil {
            bottomControl = UIView()
            bottomControl!.tag = tags["bottomControl"]!
            bottomControl!.backgroundColor = UIColor.clearColor()
            view!.addSubview(bottomControl!)
            bottomControl?.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(serviceLabel!.snp_bottom)
                make.bottom.equalTo(view!).offset(-10)
                make.left.equalTo(view!)
                make.right.equalTo(view!)
            })
        }

    }
    
    func setInfo(services: Array<Dictionary<String, AnyObject>>?, setSpread spd: Bool) {
        if services!.count != 0 {
            spread = spd
            servicesInfo = services
            if let bgView = contentView.viewWithTag(tags["view"]!) {
                let serviceLabel = bgView.viewWithTag(tags["serviceLabel"]!) as? UILabel
                for (index, service) in services!.enumerate() {
                    let titleStr = service["service_name_"] as! String
                    let timeStr = service["service_time_"] as! String
                    let payStr = "\(service["service_price_"] as! Int)元"
                    
                    var svcView = bgView.viewWithTag(tags["svcView"]! * 10 + index)
                    if svcView == nil {
                        svcView = UIView()
                        svcView!.tag = tags["svcView"]! * 10 + index
                        svcView!.userInteractionEnabled = true
                        svcView!.backgroundColor = UIColor.clearColor()
                        bgView.addSubview(svcView!)
                        svcView?.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(serviceLabel!)
                            if index != 0 {
                                let preView = bgView.viewWithTag(svcView!.tag - 1)!
                                make.top.equalTo(preView.snp_bottom).offset(5)
                            } else {
                                make.top.equalTo(serviceLabel!.snp_bottom).offset(12.5)
                            }
                            make.right.equalTo(bgView).offset(-10)
                            make.height.equalTo(40)
                        })
                    }
                    
                    var titleLabel = svcView!.viewWithTag(svcView!.tag * 10 + index ) as? UILabel
                    var timeLabel = svcView!.viewWithTag(svcView!.tag * 11 + index) as? UILabel
                    var payLabel = svcView!.viewWithTag(svcView!.tag * 12 + index) as? UILabel
                    
                    if titleLabel == nil {
                        titleLabel = UILabel()
                        titleLabel!.tag = svcView!.tag * 10 + index
                        titleLabel!.font = UIFont.systemFontOfSize(14)
                        titleLabel!.userInteractionEnabled = true
                        titleLabel!.backgroundColor = UIColor.clearColor()
                        titleLabel!.textAlignment = NSTextAlignment.Left
                        titleLabel!.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                        svcView!.addSubview(titleLabel!)
                        titleLabel!.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(svcView!)
                            make.top.equalTo(svcView!)
                            make.width.equalTo(100)
                            make.bottom.equalTo(svcView!)
                        })
                    }
                    titleLabel!.text = titleStr
                    
                    if timeLabel == nil {
                        timeLabel = UILabel()
                        timeLabel!.tag = svcView!.tag * 11 + index
                        timeLabel!.font = UIFont.systemFontOfSize(14)
                        timeLabel!.userInteractionEnabled = true
                        timeLabel!.backgroundColor = UIColor.clearColor()
                        timeLabel!.textAlignment = NSTextAlignment.Left
                        timeLabel!.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                        svcView!.addSubview(timeLabel!)
                        timeLabel!.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(titleLabel!.snp_right).offset(10)
                            make.top.equalTo(svcView!)
                            make.width.equalTo(150)
                            make.bottom.equalTo(svcView!)
                        })
                    }
                    timeLabel!.text = timeStr
                    
                    if payLabel == nil {
                        payLabel = UILabel()
                        payLabel!.tag = svcView!.tag * 12 + index
                        payLabel!.font = UIFont.systemFontOfSize(14)
                        payLabel!.userInteractionEnabled = true
                        payLabel!.backgroundColor = UIColor.clearColor()
                        payLabel!.textAlignment = NSTextAlignment.Left
                        payLabel!.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                        svcView!.addSubview(payLabel!)
                        payLabel?.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(timeLabel!.snp_right)
                            make.right.equalTo(svcView!).offset(-10)
                            make.top.equalTo(svcView!)
                            make.bottom.equalTo(svcView!)
                        })
                    }
                    payLabel!.text = payStr
                    
                    if index != servicesInfo!.count - 1 {
                        var bottomLine = svcView!.viewWithTag(svcView!.tag * 13 + index)
                        if bottomLine == nil {
                            bottomLine = UIView()
                            bottomLine?.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
                            bottomLine?.tag = svcView!.tag * 13 + index
                            svcView?.addSubview(bottomLine!)
                            bottomLine?.snp_makeConstraints(closure: { (make) in
                                make.left.equalTo(svcView!).offset(-5)
                                make.right.equalTo(self.contentView)
                                make.bottom.equalTo(svcView!)
                                make.height.equalTo(1)
                            })
                        }
                    }
                    
                }
            }
            
            showSubView(spread)

        }
    }
    
    func showSubView(show: Bool) {
        let bgView = contentView.viewWithTag(tags["view"]!)
        let serviceLabel = bgView?.viewWithTag(tags["serviceLabel"]!) as? UILabel
        let bottomControl = bgView?.viewWithTag(tags["bottomControl"]!)
        let detailBtn = bgView?.viewWithTag(tags["detailBtn"]!) as? UIButton
        detailBtn?.selected = spread
        for (index, _) in servicesInfo!.enumerate() {
            if let svcView = bgView?.viewWithTag(tags["svcView"]! * 10 + index) {
                if let bottomLine = svcView.viewWithTag(tags["svcView"]! * 13 + index) {
                    bottomLine.snp_updateConstraints(closure: { (make) in
                        make.height.equalTo(spread ? 1 : 0)
                    })
                }
                svcView.snp_updateConstraints(closure: { (make) in
                    make.height.equalTo(spread ? 40 : 0)
                    if index == servicesInfo!.count - 1 {
                        if spread {
                            bottomControl?.snp_remakeConstraints(closure: { (make) in
                                make.top.equalTo(svcView.snp_bottom)
                                make.bottom.equalTo(bgView!).offset(-2.5)
                                make.left.equalTo(bgView!)
                                make.right.equalTo(bgView!)
                            })
                        } else {
                            bottomControl?.snp_remakeConstraints(closure: { (make) in
                                make.top.equalTo(serviceLabel!.snp_bottom)
                                make.bottom.equalTo(bgView!).offset(-10)
                                make.left.equalTo(bgView!)
                                make.right.equalTo(bgView!)
                            })
                        }
                    }
                })
            }
            
        }
        
    }
    
    func detailAction(sender: UIButton?) {
        XCGLogger.defaultInstance().debug("detailAction")
        spreadAction()
    }
    
    func spreadAction() {
        delegate!.spreadAction(self)
        
    }
    
    func selectAction(sender: AnyObject?) {
        XCGLogger.defaultInstance().debug("selectAction:\(sender!.tag)")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

