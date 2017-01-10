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
    var skillsArray:Array<Dictionary<SkillModel, Bool>> = Array()
    var skills:List<Tally> = List()
    var appointmentInfo:AppointmentInfoModel?
    var commonCell:IdentCommentCell?
    var servantDict:Dictionary<String, AnyObject>?

    
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
        super.viewWillDisappear(animated)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.servantBaseInfoReply(_:)), name: NotifyDefine.UserBaseInfoReply, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentDetailVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: appointmentInfo?.is_other_ == 1 ? 3 : 2), atScrollPosition: .Bottom, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets =  inset
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
            guard data["error_"] == nil  else { return }
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
                    if idString == "" {
                        break
                    }
                    if Int(idString) == nil {
                        
                        break
                    }
                    if let results = DataManager.getData(SkillModel.self, filter: "skill_id_ = \(idString)") {
                        let skillInfo = results.first
                        let dict = [skillInfo!:false] as Dictionary<SkillModel, Bool>
                        skillsArray.append(dict)
                    }
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
        if data["error_"] != nil {
            XCGLogger.error("Get UserInfo Error:\(data["error"])")
            return
        }
        servantInfo =  DataManager.getUserInfo(data["uid_"] as! Int )
        guard servantInfo != nil else {
            
            servantDict = data
            getServantBaseInfo()
            
            return
        }
        
        let realm = try! Realm()
        try! realm.write({
            
            servantInfo!.setInfo(.Servant, info: data)
            
        })
        
        let servantPersonalVC = ServantPersonalVC()
//        servantPersonalVC.personalInfo = DataManager.getUserInfo(data["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
        }
    }
    func getServantBaseInfo() {
        
        let dic = ["uid_str_" : String(servantDict!["uid_"] as! Int) + "," + "0"]
        SocketManager.sendData(.GetUserInfo, data: dic)
        
    }
    func servantBaseInfoReply(notification: NSNotification) {
        
        servantInfo =  DataManager.getUserInfo(servantDict!["uid_"] as! Int)
        let realm = try! Realm()
        try! realm.write({
            
            servantInfo!.setInfo(.Servant, info: servantDict)
            
        })
        let servantPersonalVC = ServantPersonalVC()
//        servantPersonalVC.personalInfo = servantInfo
        navigationController?.pushViewController(servantPersonalVC, animated: true)
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
        commitBtn.setTitle("发表评论", forState: .Normal)
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
        
        let dict:Dictionary<String, AnyObject> = ["from_uid_": CurrentUser.uid_,
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
//                cell.setupDataWithInfo(DataManager.getUserInfo(appointmentInfo!.to_user_)!)
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
            cell.setAppointmentInfo(appointmentInfo)
            
            guard service_score_  != 0 || user_score_ != 0 else {
                return cell
            }
            cell.serviceSocre = service_score_
            cell.userScore = user_score_
            cell.remark = remarks_


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
            cell.setAppointmentInfo(appointmentInfo)

            guard service_score_  != 0 || user_score_ != 0 else {
                return cell
            }
            cell.serviceSocre = service_score_
            cell.userScore = user_score_
            cell.remark = remarks_

            return cell
        }

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     
        
        /**
         *  进入逻辑已修改
         */
        return appointmentInfo?.is_other_ == 1 ? 4 : 3

//        /**
//         *  status_ = 7代表可以评价 所以显示评论cell
//         */
//        if appointmentInfo?.status_ == 7 {
//            /**
//             如果是代订 则多显示一区
//             - returns:
//             */
//            return appointmentInfo?.is_other_ == 1 ? 4 : 3
//        }
//        /**
//         如果是代订 则多显示一区
//         - returns:
//         */
//        return appointmentInfo?.is_other_ == 1 ? 3 : 2
        
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