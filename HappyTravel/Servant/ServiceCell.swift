//
//  ServiceCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/5.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift

protocol ServiceCellDelegate : NSObjectProtocol {
    
    func spreadAction(_ sender: AnyObject?)
    
}

open class ServiceCell : UITableViewCell {
    
    let tags = ["view": 1001,
                "serviceLabel": 1002,
                "detailBtn": 1003,
                "bottomControl": 1004,
                "svcView": 1005]
    
    var spread = false
    var servicesInfo:List<ServiceInfo>?
    weak var delegate:ServiceCellDelegate?
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        
        var view = contentView.viewWithTag(tags["view"]!)
        if view == nil {
            view = UIView()
            view!.tag = tags["view"]!
            view!.isUserInteractionEnabled = true
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
            line.backgroundColor = UIColor.black
            view!.addSubview(line)
            line.snp_makeConstraints({ (make) in
                make.left.equalTo(view!).offset(15)
                make.top.equalTo(view!).offset(10)
                make.width.equalTo(2)
                make.height.equalTo(25)
            })
            
            serviceLabel = UILabel(frame: CGRect.zero)
            serviceLabel!.tag = tags["serviceLabel"]!
            serviceLabel!.font = UIFont.systemFont(ofSize: S18)
            serviceLabel!.isUserInteractionEnabled = true
            serviceLabel!.backgroundColor = UIColor.white
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
            detailBtn = UIButton(frame: CGRect.zero)
            detailBtn?.tag = tags["detailBtn"]!
            detailBtn!.backgroundColor = UIColor.clear
            detailBtn!.setImage(UIImage.init(named: "guide-detail-arrows"), for: UIControlState())
            detailBtn!.setImage(UIImage.init(named: "guide-detail-arrows-up"), for: .selected)
            detailBtn?.contentMode = .scaleAspectFit
            detailBtn!.addTarget(self, action: #selector(ServiceCell.detailAction(_:)), for: UIControlEvents.touchUpInside)
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
            bottomControl!.backgroundColor = UIColor.clear
            view!.addSubview(bottomControl!)
            bottomControl?.snp_makeConstraints({ (make) in
                make.top.equalTo(serviceLabel!.snp_bottom)
                make.bottom.equalTo(view!).offset(-10)
                make.left.equalTo(view!)
                make.right.equalTo(view!)
            })
        }

    }
    
    func setInfo(_ services: List<ServiceInfo>?, setSpread spd: Bool) {
        if services!.count != 0 {
            spread = spd
            servicesInfo = services
            if let bgView = contentView.viewWithTag(tags["view"]!) {
                let serviceLabel = bgView.viewWithTag(tags["serviceLabel"]!) as? UILabel
                for (index, service) in services!.enumerated() {
                    let titleStr = service.service_name_
                    let timeStr = service.service_time_
                    let payStr = "\(Double(service.service_price_) / 100)元"
                    
                    var svcView = bgView.viewWithTag(tags["svcView"]! * 10 + index)
                    if svcView == nil {
                        svcView = UIView()
                        svcView!.tag = tags["svcView"]! * 10 + index
                        svcView!.isUserInteractionEnabled = true
                        svcView!.backgroundColor = UIColor.clear
                        bgView.addSubview(svcView!)
                        svcView?.snp_makeConstraints({ (make) in
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
                        titleLabel!.font = UIFont.systemFont(ofSize: S15)
                        titleLabel!.isUserInteractionEnabled = true
                        titleLabel!.backgroundColor = UIColor.clear
                        titleLabel!.textAlignment = NSTextAlignment.left
                        titleLabel!.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                        svcView!.addSubview(titleLabel!)
                        titleLabel!.snp_makeConstraints({ (make) in
                            make.left.equalTo(svcView!)
                            make.top.equalTo(svcView!)
                            make.width.equalTo(AtapteWidthValue(100))
                            make.bottom.equalTo(svcView!)
                        })
                    }
                    titleLabel!.text = titleStr
                    
                    if timeLabel == nil {
                        timeLabel = UILabel()
                        timeLabel!.tag = svcView!.tag * 11 + index
                        timeLabel!.font = UIFont.systemFont(ofSize: S15)
                        timeLabel!.isUserInteractionEnabled = true
                        timeLabel!.backgroundColor = UIColor.clear
                        timeLabel!.textAlignment = NSTextAlignment.left
                        timeLabel!.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                        svcView!.addSubview(timeLabel!)
                        timeLabel!.snp_makeConstraints({ (make) in
                            make.left.equalTo(titleLabel!.snp_right).offset(0)
                            make.top.equalTo(svcView!)
//                            make.width.equalTo(150)
                            make.bottom.equalTo(svcView!)
                        })
                    }
                    timeLabel!.text = timeStr
                    
                    if payLabel == nil {
                        payLabel = UILabel()
                        payLabel!.tag = svcView!.tag * 12 + index
                        payLabel!.font = UIFont.systemFont(ofSize: S15)
                        payLabel!.isUserInteractionEnabled = true
                        payLabel!.backgroundColor = UIColor.clear
                        payLabel!.textAlignment = NSTextAlignment.right
                        payLabel!.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                        svcView!.addSubview(payLabel!)
                        payLabel?.snp_makeConstraints({ (make) in
//                            make.left.equalTo(timeLabel!.snp_right)
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
                            bottomLine?.snp_makeConstraints({ (make) in
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
    
    func showSubView(_ show: Bool) {
        let bgView = contentView.viewWithTag(tags["view"]!)
        let serviceLabel = bgView?.viewWithTag(tags["serviceLabel"]!) as? UILabel
        let bottomControl = bgView?.viewWithTag(tags["bottomControl"]!)
        let detailBtn = bgView?.viewWithTag(tags["detailBtn"]!) as? UIButton
        detailBtn?.isSelected = spread
        for (index, _) in servicesInfo!.enumerated() {
            if let svcView = bgView?.viewWithTag(tags["svcView"]! * 10 + index) {
                if let bottomLine = svcView.viewWithTag(tags["svcView"]! * 13 + index) {
                    bottomLine.snp_updateConstraints({ (make) in
                        make.height.equalTo(spread ? 1 : 0)
                    })
                }
                svcView.snp_updateConstraints({ (make) in
                    make.height.equalTo(spread ? 40 : 0)
                    if index == servicesInfo!.count - 1 {
                        if spread {
                            bottomControl?.snp_remakeConstraints({ (make) in
                                make.top.equalTo(svcView.snp_bottom)
                                make.bottom.equalTo(bgView!).offset(-2.5)
                                make.left.equalTo(bgView!)
                                make.right.equalTo(bgView!)
                            })
                        } else {
                            bottomControl?.snp_remakeConstraints({ (make) in
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
    
    func detailAction(_ sender: UIButton?) {
        XCGLogger.defaultInstance().debug("detailAction")
        spreadAction()
    }
    
    func spreadAction() {
        delegate!.spreadAction(self)
        
    }
    
    func selectAction(_ sender: AnyObject?) {
        XCGLogger.defaultInstance().debug("selectAction:\(sender!.tag)")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

