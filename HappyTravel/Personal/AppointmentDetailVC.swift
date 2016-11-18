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
import XCGLogger
class AppointmentDetailVC: UIViewController {
    var commitBtn: UIButton?
    var servantInfo:UserInfo?
    var skillsArray:Array<Dictionary<SkillInfo, Bool>> = Array()
    var skills:List<Tally> = List()
    var appointmentInfo:AppointmentInfo?
    var commonCell:IdentCommentCell?

    
    var user_score_ = 0
    var service_score_ = 0
    var remarks_:String?
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
    
    
    /**
     注册通知监听
     */
    func registerNotification() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.servantDetailInfo(_:)), name: NotifyDefine.ServantDetailInfo, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.receivedDetailInfo(_:)), name: NotifyDefine.AppointmentDetailReply, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.reveicedCommentInfo(_:)), name: NotifyDefine.CheckCommentDetailResult, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.evaluatetripReply(_:)), name: NotifyDefine.EvaluatetripReply, object: nil)

    }
    
    /**
     发表评论回调
     
     - parameter notification:
     */
    func evaluatetripReply(notification: NSNotification) {
        SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 0.5, completion: { () in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    /**
     
     获取评论信息回调
     - parameter notification:
     */
    func reveicedCommentInfo(notification: NSNotification) {
        if let data = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
            
            user_score_ = data["user_score_"] as! Int
            service_score_ = data["service_score_"] as! Int
            remarks_ = data["remarks_"] as? String
         
            // 是否可以评论过滤条件 暂设为 用户打分 和 服务打分 全为0
            let isCommited = user_score_ != 0 || service_score_ != 0
            commitBtn?.enabled = !isCommited
            commitBtn?.setTitle("发表评论", forState: .Normal)
            tableView.reloadData()
        }
    }
    /**
     获取预约详情回调
     
     - parameter notification:
     */
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
    /**
     获取服务者详情回调
     
     - parameter notification:
     */
    func servantDetailInfo(notification: NSNotification) {
        

        if let data = notification.userInfo!["data"] as? [String: AnyObject] {
        if let error = data["error_"] {
            XCGLogger.error(error)
            return
        }
        
        servantInfo =  DataManager.getUserInfo((appointmentInfo?.to_user_)!)
        let realm = try! Realm()
        try! realm.write({
            servantInfo!.setInfo(.Servant, info: data)
            
        })
        
        
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "预约详情"
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        view.addSubview(tableView)
        tableView.registerClass(SkillsCell.self, forCellReuseIdentifier: "TallyCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "normal")
        tableView.registerClass(AppointmentDetailCell.self, forCellReuseIdentifier: "detailCell")
        tableView.registerClass(IdentCommentCell.self, forCellReuseIdentifier: "CommentCell")

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
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.bottom.equalTo(commitBtn.snp_top)
        }
        self.commitBtn = commitBtn
        initData()
    }

    func initData() {
        
        SocketManager.sendData(.AppointmentDetailRequest, data: ["order_id_" : (appointmentInfo?.order_id_)!, "order_type_":1])
        SocketManager.sendData(.CheckCommentDetail, data: ["order_id_": appointmentInfo!.order_id_])
    }
    func cancelOrCommitButtonAction() {
        
        let dict:Dictionary<String, AnyObject> = ["from_uid_": (DataManager.currentUser?.uid)!,
                                                  "to_uid_": (appointmentInfo?.to_user_)!,
                                                  "order_id_": (appointmentInfo?.order_id_)!,
                                                  "service_score_": (self.commonCell?.serviceStar)!,
                                                  "user_score_": (self.commonCell?.servantStar)!,
                                                  "remarks_": self.commonCell!.comment]
        SocketManager.sendData(.EvaluateTripRequest, data: dict)
    }

}
//MARK: - UITableViewDelegate && UITableViewDataSource
extension AppointmentDetailVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let dict:Dictionary<String, AnyObject> = ["uid_": (appointmentInfo?.to_user_)!]
            SocketManager.sendData(.GetServantDetailInfo, data:dict)
            
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /**
         * 如果是代订 则多显示一区
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
            commonCell = cell

            cell.serviceSocre = service_score_
            cell.userScore = user_score_
            cell.remark = remarks_
            cell.setAppointmentInfo(appointmentInfo)

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
            commonCell = cell
            cell.serviceSocre = service_score_
            cell.userScore = user_score_
            cell.remark = remarks_
            cell.setAppointmentInfo(appointmentInfo)

            return cell
        }

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     
        /**
         *  status_ = 4代表可以评价 所以显示评论cell
         */
        if appointmentInfo?.status_ == 4 {
            /**
             如果是代订 则多显示一区
             - returns:
             */
            return appointmentInfo?.is_other_ == 1 ? 4 : 3
        }
        /**
         如果是代订 则多显示一区
         - returns:
         */
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