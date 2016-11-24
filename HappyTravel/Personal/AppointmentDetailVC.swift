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
    var servantDict:Dictionary<String, AnyObject>?

    
    var user_score_ = 0
    var service_score_ = 0
    var remarks_:String?
    lazy fileprivate var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
    }
    
    
    /**
     注册通知监听
     */
    func registerNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppointmentDetailVC.servantDetailInfo(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ServantDetailInfo), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppointmentDetailVC.receivedDetailInfo(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AppointmentDetailReply), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(AppointmentDetailVC.reveicedCommentInfo(_:)), name: NSNotification.Name(rawValue: NotifyDefine.CheckCommentDetailResult), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppointmentDetailVC.evaluatetripReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.EvaluatetripReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IdentDetailVC.servantBaseInfoReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.UserBaseInfoReply), object: nil)

    }
    
    /**
     发表评论回调
     
     - parameter notification:
     */
    func evaluatetripReply(_ notification: Notification) {
        SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 0.5, completion: { () in
            self.navigationController?.popViewController(animated: true)
        })
    }
    /**
     
     获取评论信息回调
     - parameter notification:
     */
    func reveicedCommentInfo(_ notification: Notification) {
        if let data = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
            guard data["error_"] == nil  else { return }
            user_score_ = data["user_score_"] as! Int
            service_score_ = data["service_score_"] as! Int
            remarks_ = data["remarks_"] as? String
         
            // 是否可以评论过滤条件 暂设为 用户打分 和 服务打分 全为0
            let isCommited = user_score_ != 0 || service_score_ != 0
            commitBtn?.isEnabled = !isCommited
            commitBtn?.setTitle("发表评论", for: UIControlState())
            tableView.reloadData()
        }
    }
    /**
     获取预约详情回调
     
     - parameter notification:
     */
    func receivedDetailInfo(_ notification: Notification) {
        
        if  let data = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
 
            skillsArray.removeAll()
            if data["skills_"] != nil {
             let skillStr = data["skills_"] as? String
             let idArray = (skillStr?.components(separatedBy: ","))! as Array<String>
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
    func servantDetailInfo(_ notification: Notification) {
        
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
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
        }
    }
    func getServantBaseInfo() {
        
        let dic = ["uid_str_" : String(servantDict!["uid_"] as! Int) + "," + "0"]
        SocketManager.sendData(.getUserInfo, data: dic as AnyObject?)
        
    }
    func servantBaseInfoReply(_ notification: Notification) {
        
        servantInfo =  DataManager.getUserInfo(servantDict!["uid_"] as! Int)
        let realm = try! Realm()
        try! realm.write({
            
            servantInfo!.setInfo(.Servant, info: servantDict)
            
        })
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = servantInfo
        navigationController?.pushViewController(servantPersonalVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "预约详情"
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        view.addSubview(tableView)
        tableView.register(SkillsCell.self, forCellReuseIdentifier: "TallyCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "normal")
        tableView.register(AppointmentDetailCell.self, forCellReuseIdentifier: "detailCell")
        tableView.register(IdentCommentCell.self, forCellReuseIdentifier: "CommentCell")

        let commitBtn = UIButton()
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), for: UIControlState())
        commitBtn.setTitle("发表评论", for: UIControlState())
        commitBtn.addTarget(self, action: #selector(AppointmentDetailVC.cancelOrCommitButtonAction), for: .touchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.bottom.equalTo(commitBtn.snp.top)
        }
        self.commitBtn = commitBtn
        initData()
    }

    func initData() {
        
        SocketManager.sendData(.appointmentDetailRequest, data: ["order_id_" : (appointmentInfo?.order_id_)!, "order_type_":1])
        SocketManager.sendData(.checkCommentDetail, data: ["order_id_": appointmentInfo!.order_id_])
    }
    func cancelOrCommitButtonAction() {
        
        let dict:Dictionary<String, AnyObject> = ["from_uid_": (DataManager.currentUser?.uid)! as AnyObject,
                                                  "to_uid_": (appointmentInfo?.to_user_)! as AnyObject,
                                                  "order_id_": (appointmentInfo?.order_id_)! as AnyObject,
                                                  "service_score_": (self.commonCell?.serviceStar)! as AnyObject,
                                                  "user_score_": (self.commonCell?.servantStar)! as AnyObject,
                                                  "remarks_": self.commonCell!.comment as AnyObject]
        SocketManager.sendData(.evaluateTripRequest, data: dict as AnyObject?)
    }

}
//MARK: - UITableViewDelegate && UITableViewDataSource
extension AppointmentDetailVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let dict:Dictionary<String, AnyObject> = ["uid_": (appointmentInfo?.to_user_)! as AnyObject]
            SocketManager.sendData(.getServantDetailInfo, data:dict as AnyObject?)
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /**
         * 如果是代订 则多显示一区
         */
        if appointmentInfo?.is_other_ == 1 {
            
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! AppointmentDetailCell
                cell.setupDataWithInfo(DataManager.getUserInfo(appointmentInfo!.to_user_)!)
                cell.setApponimentInfo(appointmentInfo!)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TallyCell", for: indexPath) as! SkillsCell
                cell.setInfo(skillsArray)
                
                cell.contentView.backgroundColor = UIColor.white

                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)
                cell.selectionStyle = .none
                cell.textLabel?.font = UIFont.systemFont(ofSize: S15)
                cell.textLabel?.textColor = colorWithHexString("#131f32")
                cell.textLabel?.text = "代订 : " + (appointmentInfo?.other_name_)! + " " + (appointmentInfo?.other_phone_)!
                return cell
            default:
                break
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! IdentCommentCell
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! AppointmentDetailCell

                cell.setApponimentInfo(appointmentInfo!)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TallyCell", for: indexPath) as! SkillsCell
                cell.setInfo(skillsArray)
                
                cell.contentView.backgroundColor = UIColor.white
                
                return cell
                
            default:
                break
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! IdentCommentCell
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
     
        
        
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
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 0.001
        } else if section == 3 {
            return 0.001
        }
        return 10
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
