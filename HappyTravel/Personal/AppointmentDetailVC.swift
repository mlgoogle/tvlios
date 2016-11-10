//
//  AppointmentDetailVC.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/10.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD
class AppointmentDetailVC: UIViewController {

    var appointmentInfo:AppointmentInfo?
    lazy private var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
    }
    func registerNotification() {
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "预约详情"
        view.addSubview(tableView)
        tableView.registerClass(SkillsCell.self, forCellReuseIdentifier: "skillCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "normal")
        tableView.registerClass(AppointmentDetailCell.self, forCellReuseIdentifier: "detailCell")
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        initFooterView()    
    }

    
    func initFooterView() {
        let footerView = UIView (frame:CGRectMake(0, 0, ScreenWidth, AtapteHeightValue(110)))
        
        let button = UIButton(type: .Custom)
        
        button.setTitle("取消预约", forState: .Normal)
       
        footerView.addSubview(button)
        
        footerView.backgroundColor = UIColor.clearColor()
        
        button.addTarget(self, action: #selector(AppointmentDetailVC.cancelAppointment), forControlEvents: .TouchUpInside)
        button.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), forState: .Normal)

        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.blackColor()
        button.snp_makeConstraints { (make) in
            
            make.top.equalTo(footerView).offset(AtapteHeightValue(65))
            make.left.equalTo(footerView).offset(AtapteWidthValue(25))
            make.right.equalTo(footerView).offset(AtapteWidthValue(-25))
            make.bottom.equalTo(footerView.snp_bottom)
        }
        tableView.tableFooterView = footerView
    }
    
    func cancelAppointment() {
        
        
    }
}


extension AppointmentDetailVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
          SVProgressHUD.showWainningMessage(WainningMessage: "还没为您分配V领队", ForDuration: 1.5, completion: nil)
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /**
         *
         */
        if appointmentInfo?.is_other_ == 1 {
            
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("normal", forIndexPath: indexPath)
                cell.selectionStyle = .None
                cell.textLabel?.font = UIFont.systemFontOfSize(S15)
                cell.textLabel?.textColor = colorWithHexString("#131f32")
                cell.textLabel?.text = "代订 : " + (appointmentInfo?.other_name_)! + " " + (appointmentInfo?.other_phone_)!
                return cell
            default:
                break
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("skillCell", forIndexPath: indexPath)
            
            return cell
            
        }
        
        
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath)
            
            return cell
            
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("skillCell", forIndexPath: indexPath)
        
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        /**
         *  判断是否添加代订信息
         */
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     
        return appointmentInfo?.is_other_ == 1 ? 3 : 2
        
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}