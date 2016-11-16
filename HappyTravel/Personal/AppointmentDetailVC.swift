//
//  AppointmentDetailVC.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/10.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD
import RealmSwift

class AppointmentDetailVC: UIViewController {
    var commitBtn: UIButton?
    var servantInfo:UserInfo?
    var skillsArray:Array<Dictionary<SkillInfo, Bool>> = Array()
    var skills:List<Tally> = List()
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.servantDetailInfo(_:)), name: NotifyDefine.ServantDetailInfo, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.receivedDetailInfo(_:)), name: NotifyDefine.AppointmentDetailReply, object: nil)

    }
    func receivedDetailInfo(notification: NSNotification) {
        
        if  let data = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
 
            skillsArray.removeAll()
            if data["skills_"] != nil {
             let skillStr = data["skills_"] as? String
             let idArray = (skillStr?.componentsSeparatedByString(","))! as Array<String>
                for idString in idArray {
                    let results = DataManager.getData(SkillInfo.self, filter: "skill_id_ = \(idString)") as! Results<SkillInfo>
                    let skillInfo = results.first
                    let dict = [skillInfo!:false] as Dictionary<SkillInfo, Bool>
                    skillsArray.append(dict)
                }
                tableView.reloadData()
            }

            
        }
    }
    
    func servantDetailInfo(notification: NSNotification) {
        
        
        let data = notification.userInfo!["data"]
        if data!["error_"]! != nil {
            return
        }
        
        
        
        servantInfo =  DataManager.getUserInfo((appointmentInfo?.to_user_)!)
        let realm = try! Realm()
        try! realm.write({
            servantInfo!.setInfo(.Servant, info: data as? Dictionary<String, AnyObject>)
            
        })
        
        
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data!["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "预约详情"
        view.addSubview(tableView)
        tableView.registerClass(SkillsCell.self, forCellReuseIdentifier: "TallyCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "normal")
        tableView.registerClass(AppointmentDetailCell.self, forCellReuseIdentifier: "detailCell")
        tableView.registerClass(IdentCommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.bottom.equalTo(view).offset(-60)
        }
        let commitBtn = UIButton()
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), forState: .Normal)
        commitBtn.setTitle("取消预约", forState: .Normal)
        commitBtn.addTarget(self, action: #selector(AppointmentDetailVC.cancelOrCommitButtonAction), forControlEvents: .TouchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
        }
        self.commitBtn = commitBtn
        initData()
//        initFooterView()
//        if let infos = DataManager.getData(SkillInfo.self, filter: nil) as? Results<SkillInfo> {
//            for info in infos {
//                let selected = false
//      
//                skills.append([info: selected])
//                
//            }
//            
//        }
//        for _ in 0...10 {
//            
//            let tally = Tally()
//            tally.tally = "标签"
//            tally.labelWidth = 60
//            skills.append(tally)
//        }
//        
    }

    func initData() {

        SocketManager.sendData(.AppointmentDetailRequest, data: ["order_id_" : (appointmentInfo?.order_id_)!, "order_type_":1])
    }
    func cancelOrCommitButtonAction() {
        
        SVProgressHUD.showWainningMessage(WainningMessage: "还不能取消预约哦！", ForDuration: 1.5, completion: nil)
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
            let dict:Dictionary<String, AnyObject> = ["uid_": (appointmentInfo?.to_user_)!]
            SocketManager.sendData(.GetServantDetailInfo, data:dict)
            
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /**
         *
         */
        if appointmentInfo?.is_other_ == 1 {
            
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! AppointmentDetailCell
                cell.setupDataWithInfo(DataManager.getUserInfo(appointmentInfo!.to_user_)!)
                cell.setApponimentInfo(appointmentInfo!)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("TallyCell", forIndexPath: indexPath) as! SkillsCell
                cell.setInfo(skillsArray)
                
                cell.contentView.backgroundColor = UIColor.whiteColor()

                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("normal", forIndexPath: indexPath)
                cell.selectionStyle = .None
                cell.textLabel?.font = UIFont.systemFontOfSize(S15)
                cell.textLabel?.textColor = colorWithHexString("#131f32")
                cell.textLabel?.text = "代订 : " + (appointmentInfo?.other_name_)! + " " + (appointmentInfo?.other_phone_)!
                return cell
            default:
                break
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! IdentCommentCell

            return cell
            
        } else {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! AppointmentDetailCell
        
                cell.setApponimentInfo(appointmentInfo!)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("TallyCell", forIndexPath: indexPath) as! SkillsCell
                cell.setInfo(skillsArray)
                
                cell.contentView.backgroundColor = UIColor.whiteColor()
                
                return cell
                
            default:
                break
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! IdentCommentCell
            //            cell.setInfo(hodometerInfo)
            //            commonCell = cell
            //            if serviceScore != nil {
            //                cell.serviceSocre = serviceScore
            //                cell.userScore = userScore
            //                cell.remark = remark
            //            }
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
     
        if appointmentInfo?.status_ == 4 {
            
            return appointmentInfo?.is_other_ == 1 ? 4 : 3
        }
        
        return appointmentInfo?.is_other_ == 1 ? 3 : 2
        
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.001
        } else if section == 3 {
            return 0.001
        }
        return 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}