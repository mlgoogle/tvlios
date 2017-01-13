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
    var skillsArray:Array<Dictionary<SkillModel, Bool>> = Array()
    var skills:List<Tally> = List()
    var appointmentInfo:AppointmentInfoModel?
    var commonCell:IdentCommentCell?
    var servantDict:Dictionary<String, AnyObject>?
    
    var user_score_ = 0
    var service_score_ = 0
    var remarks_:String?
    var commentModel:OrderCommentModel?
    
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
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receivedDetailInfo(_:)), name: NotifyDefine.AppointmentDetailReply, object: nil)
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reveicedCommentInfo(_:)), name: NotifyDefine.CheckCommentDetailResult, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(evaluatetripReply(_:)), name: NotifyDefine.EvaluatetripReply, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(servantBaseInfoReply(_:)), name: NotifyDefine.UserBaseInfoReply, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
//    func evaluatetripReply(notification: NSNotification) {
//        SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 0.5, completion: { () in
//            self.navigationController?.popViewControllerAnimated(true)
//        })
//    }
    /**
     
     获取评论信息回调
     - parameter notification:
     */
//    func reveicedCommentInfo(notification: NSNotification) {
//        if let data = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
//            guard data["error_"] == nil  else { return }
//            user_score_ = data["user_score_"] as! Int
//            service_score_ = data["service_score_"] as! Int
//            remarks_ = data["remarks_"] as? String
//         
//            // 是否可以评论过滤条件 暂设为 用户打分 和 服务打分 全为0
//            let isCommited = user_score_ != 0 || service_score_ != 0
//            commitBtn?.enabled = !isCommited
//            commitBtn?.setTitle("发表评论", forState: .Normal)
//            tableView.reloadData()
//        }
//    }
    /**
     获取预约详情回调
     
     - parameter notification:
     */
//    func receivedDetailInfo(notification: NSNotification) {
//        
//        if  let data = notification.userInfo!["data"] as? Dictionary<String, AnyObject> {
// 
//            skillsArray.removeAll()
//            if data["skills_"] != nil {
//             let skillStr = data["skills_"] as? String
//             let idArray = (skillStr?.componentsSeparatedByString(","))! as Array<String>
//                for idString in idArray {
//                    if idString == "" {
//                        break
//                    }
//                    if Int(idString) == nil {
//                        
//                        break
//                    }
//                    if let results = DataManager.getData(SkillModel.self, filter: "skill_id_ = \(idString)") {
//                        let skillInfo = results.first
//                        let dict = [skillInfo!:false] as Dictionary<SkillModel, Bool>
//                        skillsArray.append(dict)
//                    }
//                }
//                tableView.reloadData()
//            }
//
//        }
//    }
    
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
        commitBtn.addTarget(self, action: #selector(cancelOrCommitButtonAction), forControlEvents: .TouchUpInside)
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

//        SocketManager.sendData(.AppointmentDetailRequest, data: ["order_id_" : (appointmentInfo?.order_id_)!, "order_type_":1])
//        SocketManager.sendData(.CheckCommentDetail, data: ["order_id_": appointmentInfo!.order_id_])
        requestDetail()
        checkCommentDetail()
    }
    func requestDetail() {
        
        let model = OrderDetailRequsetModel()
        model.order_id_ = (appointmentInfo?.order_id_)!
        model.order_type_ = 1//1 为邀约 2为预约
        APIHelper.consumeAPI().requestOrderDetail(model, complete: { (response) in
            if  let data = response as? Dictionary<String, AnyObject> {
                
                self.skillsArray.removeAll()
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
                            self.skillsArray.append(dict)
                        }
                    }
                    self.tableView.reloadData()
                }
                
            }
            
        }) { (error) in
            
        }
    }
    func checkCommentDetail() {
        let model = CommentDetaiRequsetModel()
        model.order_id_ = (appointmentInfo?.order_id_)!
        
        APIHelper.consumeAPI().requestComment(model, complete: { (response) in
            self.commentModel = response as? OrderCommentModel
            guard self.commentModel != nil else {return}
            let isCommited = self.commentModel?.user_score_ != 0 || self.commentModel!.service_score_ != 0
            self.commitBtn?.enabled = !isCommited
            self.commitBtn?.setTitle("发表评论", forState: .Normal)
            self.tableView.reloadData()
            
            }) { (error) in
                
        }
    }
    
    func cancelOrCommitButtonAction() {
        
        let dict:Dictionary<String, AnyObject> = ["from_uid_": CurrentUser.uid_,
                                                  "to_uid_": (appointmentInfo?.to_user_)!,
                                                  "order_id_": (appointmentInfo?.order_id_)!,
                                                  "service_score_": (self.commonCell?.serviceStar)!,
                                                  "user_score_": (self.commonCell?.servantStar)!,
                                                  "remarks_": self.commonCell!.comment]
        
        
        let model = CommentForOrderModel(value: dict)
        
        APIHelper.consumeAPI().commentForOrder(model, complete: { (response) in
            
            self.navigationController?.popViewControllerAnimated(true)
            }) { (error) in
                
        }
    }

}
//MARK: - UITableViewDelegate && UITableViewDataSource
extension AppointmentDetailVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let servant = UserBaseModel()
            servant.uid_ = appointmentInfo!.to_user_
            APIHelper.servantAPI().servantDetail(servant, complete: { [weak self](response) in
                if let model = response as? ServantDetailModel {
                    DataManager.insertData(model)
                    if let servantInfo =  DataManager.getData(UserInfoModel.self, filter: "uid_ = \(model.uid_)")?.first {
                        self?.jumpToServantPersonalVC(servantInfo)
                    } else {
                        let req = UserInfoIDStrRequestModel()
                        req.uid_str_ = "\(model.uid_)"
                        APIHelper.servantAPI().getUserInfoByString(req, complete: { [weak self](response) in
                            if let users = response as? [UserInfoModel] {
                                DataManager.insertData(users[0])
                                self?.jumpToServantPersonalVC(users[0])
                            }
                        }, error: nil)
                    }
                }
            }, error: nil)
            
        }
    }
    
    func jumpToServantPersonalVC(user: UserInfoModel) {
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = user
        navigationController?.pushViewController(servantPersonalVC, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /**
         * 如果是代订 则多显示一区
         */
        if appointmentInfo?.is_other_ == 1 {
            
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
            
            guard commentModel != nil else {
                return cell
            }
            cell.serviceSocre = commentModel?.service_score_
            cell.userScore = commentModel?.user_score_
            cell.remark = commentModel?.remarks_


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

        return appointmentInfo?.is_other_ == 1 ? 4 : 3
        
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