//
//  IdentDetailVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/31.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
import RealmSwift

class IdentDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var table:UITableView?
    var commonCell:IdentCommentCell?
    
    var servantInfo:UserInfo?
    var hodometerInfo:HodometerInfoModel?
    var serviceScore:Int?
    var userScore:Int?
    var remark:String?
    var commitBtn: UIButton?
    var commentModel:OrderCommentModel?

    var servantDict:Dictionary<String, AnyObject>?
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "订单详情"
        initData()
        initView()
        
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(IdentBaseInfoCell.self, forCellReuseIdentifier: "IdentBaseInfoCell")
        table?.registerClass(IdentCommentCell.self, forCellReuseIdentifier: "IdentCommentCell")
        table?.registerClass(AppointmentDetailCell.self, forCellReuseIdentifier: "AppointmentDetailCell")
        view.addSubview(table!)
        
        let commitBtn = UIButton()
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), forState: .Normal)
        commitBtn.setTitle("发表评论", forState: .Normal)
        commitBtn.addTarget(self, action: #selector(IdentDetailVC.commitAction(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
        }
        self.commitBtn = commitBtn
        
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(commitBtn.snp_top)
        })
        
        hideKeyboard()
    }
    
    func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

    }

    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset

        table?.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    func commitAction(sender: UIButton) {
        
        let dict:Dictionary<String, AnyObject> = ["from_uid_": (hodometerInfo?.from_uid_)!,
                                                  "to_uid_": (hodometerInfo?.to_uid_)!,
                                                  "order_id_": (hodometerInfo?.order_id_)!,
                                                  "service_score_": (self.commonCell?.serviceStar)!,
                                                  "user_score_": (self.commonCell?.servantStar)!,
                                                  "remarks_": self.commonCell!.comment]
        
        let model = CommentForOrderModel(value: dict)
        
        APIHelper.consumeAPI().commentForOrder(model, complete: { (response) in
            SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 0.5, completion: { () in
                    self.navigationController?.popViewControllerAnimated(true)
                })
        }) { (error) in
            SVProgressHUD.showWainningMessage(WainningMessage: "评论失败，请稍后再试", ForDuration: 1.5, completion: nil)
        }
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("AppointmentDetailCell", forIndexPath: indexPath) as! AppointmentDetailCell
            cell.setServiceInfo(hodometerInfo!)

            cell.hideCityInfo()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("IdentCommentCell", forIndexPath: indexPath) as! IdentCommentCell
            cell.setInfo(hodometerInfo)
            commonCell = cell
            
            guard commentModel != nil else {return cell}
            guard commentModel?.service_score_  != 0 || commentModel?.user_score_ != 0 || commentModel?.remarks_ != nil else {
                return cell
            }
            cell.serviceSocre = commentModel?.service_score_
            cell.userScore = commentModel?.user_score_
            cell.remark = commentModel?.remarks_
            return cell
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let servant = UserBaseModel()
            servant.uid_ = hodometerInfo!.to_uid_
            APIHelper.servantAPI().servantDetail(servant, complete: { [weak self](response) in
                if let model = response as? ServantDetailModel {
                    DataManager.insertData(model)
                    if let servantInfo = DataManager.getData(UserInfoModel.self, filter: "uid_ = \(model.uid_)")?.first {
                        self?.jumpToServantPersonal(servantInfo)
                    } else {
                        let req = UserInfoIDStrRequestModel()
                        req.uid_str_ = "\(model.uid_)"
                        APIHelper.servantAPI().getUserInfoByString(req, complete: { [weak self](response) in
                            if let users = response as? [UserInfoModel] {
                                DataManager.insertData(users[0])
                                self?.jumpToServantPersonal(users[0])
                            }
                        }, error: nil)
                    }
                }
            }, error: nil)
           
        }
    }
    
    func jumpToServantPersonal(user: UserInfoModel) {
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = user
        navigationController?.pushViewController(servantPersonalVC, animated: true)
    }

    // MARK: - DATA
    func initData() {
        let model = CommentDetaiRequsetModel()
        model.order_id_ = (hodometerInfo?.order_id_)!
        
        APIHelper.consumeAPI().requestComment(model, complete: { (response) in
            self.commentModel = response as? OrderCommentModel
            guard self.commentModel != nil else {return}
            let isCommited = self.commentModel?.user_score_ != 0 || self.commentModel!.service_score_ != 0
            self.commitBtn?.enabled = !isCommited
            self.commitBtn?.setTitle("发表评论", forState: .Normal)
            self.table?.reloadData()
            
        }) { (error) in
            
        }
    }
    
}
