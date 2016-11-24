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
    
    func cancelAction(_ sender: UIButton?)
    
    func sureAction(_ service: ServiceInfo?, daysCount:Int?)
    
}

class ServiceSheet: UIView, UITableViewDelegate, UITableViewDataSource{
    
    weak var delegate:ServiceSheetDelegate?
    var count = 0
    var selectedIndexPath:IndexPath?
    var countsArray:Array<Int> = []

    var servantInfo:UserInfo?
    
    //记录是邀约？预约？   ture为邀约  false 为预约
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
        bgView.backgroundColor = UIColor.white
        bgView.isUserInteractionEnabled = true
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(-10)
            make.right.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(10)
            make.top.equalTo(self)
        }
        
        let head = UIView()
        head.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        head.isUserInteractionEnabled = true
        addSubview(head)
        head.snp.makeConstraints { (make) in
            make.left.equalTo(bgView)
            make.right.equalTo(bgView)
            make.top.equalTo(bgView)
            make.height.equalTo(40)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消", for: UIControlState())
        cancelBtn.backgroundColor = UIColor.clear
        cancelBtn.setTitleColor(UIColor.black, for: UIControlState())
        cancelBtn.addTarget(self, action: #selector(ServiceSheet.cancelAction(_:)), for: .touchUpInside)
        head.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(head)
            make.right.equalTo(head.snp.centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        let sureBtn = UIButton()
        sureBtn.setTitle("确定", for: UIControlState())
        sureBtn.backgroundColor = UIColor.clear
        sureBtn.setTitleColor(UIColor.black, for: UIControlState())
        sureBtn.addTarget(self, action: #selector(ServiceSheet.sureAction(_:)), for: .touchUpInside)
        head.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalTo(head)
            make.left.equalTo(head.snp.centerX)
            make.top.equalTo(head)
            make.bottom.equalTo(head)
        }
        
        table = UITableView(frame: CGRect.zero, style: .plain)
        table?.backgroundColor = UIColor.clear
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .none
        table?.register(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        table?.register(SingleServiceInfoCell.self, forCellReuseIdentifier: "singleService")
        addSubview(table!)
        table?.snp.makeConstraints({ (make) in
            make.left.equalTo(self)
            make.top.equalTo(head.snp.bottom)
            make.right.equalTo(self)
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.main.bounds.size.height / 3.0)
        })
    }
    
    func cancelAction(_ sender: UIButton?) {
        delegate?.cancelAction(sender)
    }
    
    func sureAction(_ sender: UIButton?) {
        if selectedIndexPath == nil {
            return
        }
        delegate?.sureAction(servantInfo?.serviceList[selectedIndexPath!.row], daysCount: countsArray[(selectedIndexPath?.row)!])
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servantInfo != nil ? servantInfo!.serviceList.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "singleService", for: indexPath) as! SingleServiceInfoCell
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
                    selectBtn.isSelected = true
                }
                return cell

            }
        }
    
       if let selectBtn = cell.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
        selectBtn.isSelected = false
        }
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath != nil {
            let cell = tableView.cellForRow(at: selectedIndexPath!)
            if let selectBtn = cell?.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
                selectBtn.isSelected = false
            }
        }
        
        if let currentCell = tableView.cellForRow(at: indexPath) {
            if let selectBtn = currentCell.contentView.viewWithTag(tags["selectBtn"]!) as? UIButton {
                selectBtn.isSelected = true
                selectedIndexPath = indexPath
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ServiceSheet:DaysCountDelegate {
    
    func countsPlus(_ cell:SingleServiceInfoCell) {
        
        
        let indexPath = (table?.indexPath(for: cell))! as IndexPath
        
        countsArray[indexPath.row] += 1
        table?.reloadRows(at: [indexPath], with: .none)
    }
    
    func countsReduce(_ cell:SingleServiceInfoCell) {
        let indexPath = (table?.indexPath(for: cell))! as IndexPath
        
        if countsArray[indexPath.row] > 1 {
            
            countsArray[indexPath.row] -= 1
            table?.reloadRows(at: [indexPath], with: .none)
        } else {
            SVProgressHUD.showWainningMessage(WainningMessage: "不能再减了哦", ForDuration: 1.5, completion: nil)
        }
    }
}

