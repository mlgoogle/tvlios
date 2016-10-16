//
//  ServiceSheet.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/16.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

protocol ServiceSheetDelegate : NSObjectProtocol {
    
    func cancelAction(sender: UIButton?)
    
    func sureAction(service: ServiceInfo?)
    
}

class ServiceSheet: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate:ServiceSheetDelegate?
    
    var selectedIndexPath:NSIndexPath?
    
    var servantInfo:UserInfo?
    
    var table:UITableView?
    
    let tags = ["selectBtn": 1001,
                "priceLab": 1002,
                "descLab": 1003]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.whiteColor()
        bgView.userInteractionEnabled = true
        addSubview(bgView)
        bgView.snp_makeConstraints { (make) in
            make.left.equalTo(self).offset(-10)
            make.right.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(10)
            make.top.equalTo(self)
        }
        
        let head = UIView()
        head.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        head.userInteractionEnabled = true
        addSubview(head)
        head.snp_makeConstraints { (make) in
            make.left.equalTo(bgView)
            make.right.equalTo(bgView)
            make.top.equalTo(bgView)
            make.height.equalTo(40)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消", forState: .Normal)
        cancelBtn.backgroundColor = UIColor.clearColor()
        cancelBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cancelBtn.addTarget(self, action: #selector(ServiceSheet.cancelAction(_:)), forControlEvents: .TouchUpInside)
        head.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) in
            make.left.equalTo(head)
            make.right.equalTo(head.snp_centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        let sureBtn = UIButton()
        sureBtn.setTitle("确定", forState: .Normal)
        sureBtn.backgroundColor = UIColor.clearColor()
        sureBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        sureBtn.addTarget(self, action: #selector(ServiceSheet.sureAction(_:)), forControlEvents: .TouchUpInside)
        head.addSubview(sureBtn)
        sureBtn.snp_makeConstraints { (make) in
            make.right.equalTo(head)
            make.left.equalTo(head.snp_centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.clearColor()
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(self)
            make.top.equalTo(head.snp_bottom)
            make.right.equalTo(self)
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.mainScreen().bounds.size.height / 3.0)
        })
    }
    
    func cancelAction(sender: UIButton?) {
        delegate?.cancelAction(sender)
    }
    
    func sureAction(sender: UIButton?) {
        delegate?.sureAction(servantInfo?.serviceList[selectedIndexPath!.row])
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servantInfo != nil ? servantInfo!.serviceList.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SettingCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.selectionStyle = .None
        }
        
        let service = servantInfo?.serviceList[indexPath.row]
        
        var selectBtn = cell?.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton
        if selectBtn == nil {
            selectBtn = UIButton()
            selectBtn?.tag = tags["selectBtn"]!
            selectBtn?.setBackgroundImage(UIImage.init(named: "service-unselect"), forState: .Normal)
            selectBtn?.setBackgroundImage(UIImage.init(named: "service-selected"), forState: .Selected)
            selectBtn?.backgroundColor = UIColor.clearColor()
            cell?.contentView.addSubview(selectBtn!)
            selectBtn?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(15)
                make.top.equalTo(cell!.contentView).offset(20)
                make.width.equalTo(20)
                make.bottom.equalTo(cell!.contentView).offset(-20)
                
            })
        }
        
        var priceLab = cell?.contentView.viewWithTag(tags["priceLab"]!) as? UILabel
        if priceLab == nil {
            priceLab = UILabel()
            priceLab?.tag = tags["priceLab"]!
            priceLab?.backgroundColor = UIColor.clearColor()
            priceLab?.textAlignment = .Right
            priceLab?.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            priceLab?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(priceLab!)
            priceLab!.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(cell!.contentView).offset(-15)
                make.top.equalTo(selectBtn!)
                make.bottom.equalTo(selectBtn!)
            })
        }
        priceLab!.text = "\(service!.service_price_) 元"
        
        var descLab = cell?.contentView.viewWithTag(tags["descLab"]!) as? UILabel
        if descLab == nil {
            descLab = UILabel()
            descLab?.tag = tags["descLab"]!
            descLab?.backgroundColor = UIColor.clearColor()
            descLab?.textAlignment = .Left
            descLab?.numberOfLines = 0
            descLab?.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.size.width / 5.0 * 3
            descLab?.textColor = UIColor.init(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1)
            descLab?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(descLab!)
            descLab!.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(selectBtn!.snp_right).offset(15)
                make.right.equalTo(priceLab!.snp_left)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
            })
        }
        
        descLab!.text = "\(service!.service_name_!)    \(service!.service_time_!)"
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedIndexPath != nil {
            let cell = tableView.cellForRowAtIndexPath(selectedIndexPath!)
            if let selectBtn = cell?.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
                selectBtn.selected = false
            }
        }
        
        if let currentCell = tableView.cellForRowAtIndexPath(indexPath) {
            if let selectBtn = currentCell.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
                selectBtn.selected = true
                selectedIndexPath = indexPath
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
