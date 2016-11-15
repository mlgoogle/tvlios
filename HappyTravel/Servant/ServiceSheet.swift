//
//  ServiceSheet.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/16.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD
protocol ServiceSheetDelegate : NSObjectProtocol {
    
    func cancelAction(sender: UIButton?)
    
    func sureAction(service: ServiceInfo?, daysCount:Int?)
    
}

class ServiceSheet: UIView, UITableViewDelegate, UITableViewDataSource{
    
    weak var delegate:ServiceSheetDelegate?
    var count = 0
    var selectedIndexPath:NSIndexPath?
    var countsArray:Array<Int> = []

    var servantInfo:UserInfo?
    var isNormal = true
    let tags = ["selectBtn": 1001,
                "priceLab": 1002,
                "descLab": 1003,
                "plusOrReduceView":1004,
                "countLabel":1005,
                "reduceButton":1006,
                "plusButton":1007]
    var table:UITableView?
    
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
        table?.registerClass(SingleServiceInfoCell.self, forCellReuseIdentifier: "singleService")
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
        if selectedIndexPath == nil {
            return
        }
        delegate?.sureAction(servantInfo?.serviceList[selectedIndexPath!.row], daysCount: countsArray[(selectedIndexPath?.row)!])
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servantInfo != nil ? servantInfo!.serviceList.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("singleService", forIndexPath: indexPath) as! SingleServiceInfoCell
        let service = servantInfo?.serviceList[indexPath.row]

        cell.delegate = self
        
        /**
         *  判断是否有当前IndexPath的天数记录 没有就添加
         */
        if countsArray.count < indexPath.row + 1 {
            countsArray.append(1)
        }
//        cell.setCounts(countsArray[indexPath.row], isNormal: isNormal)
        /**
         *  防止cell重用刷新问题
         */
        cell.setupInfo(service!, count: countsArray[indexPath.row], isNormal: isNormal)
        if selectedIndexPath != nil {
            
            if indexPath == selectedIndexPath {
                if let selectBtn = cell.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
                    selectBtn.selected = true
                }
                return cell

            }
        }
    
       if let selectBtn = cell.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
        selectBtn.selected = false
        }
        return cell
        
        
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

extension ServiceSheet:DaysCountDelegate {
    
    func countsPlus(cell:SingleServiceInfoCell) {
        
        
        let indexPath = (table?.indexPathForCell(cell))! as NSIndexPath
        
        countsArray[indexPath.row] += 1
        table?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    func countsReduce(cell:SingleServiceInfoCell) {
        let indexPath = (table?.indexPathForCell(cell))! as NSIndexPath
        
        if countsArray[indexPath.row] > 1 {
            
            countsArray[indexPath.row] -= 1
            table?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        } else {
            SVProgressHUD.showWainningMessage(WainningMessage: "不能再减了哦", ForDuration: 1.5, completion: nil)
        }
    }
}

