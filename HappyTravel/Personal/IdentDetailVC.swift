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
    var hodometerInfo:HodometerInfo?
    var serviceScore:Int?
    var userScore:Int?
    var remark:String?
    var commitBtn: UIButton?
    
    
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
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(InvoiceDetailVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdentDetailVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdentDetailVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdentDetailVC.evaluatetripReply(_:)), name: NotifyDefine.EvaluatetripReply, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdentDetailVC.servantDetailInfo(_:)), name: NotifyDefine.ServantDetailInfo, object: nil)
    }
    
    func servantDetailInfo(notification: NSNotification) {
        let data = notification.userInfo!["data"]
        if data!["error_"]! != nil {
            XCGLogger.error("Get UserInfo Error:\(data!["error"])")
            return
        }
        servantInfo =  DataManager.getUserInfo((hodometerInfo?.to_uid_)!)
        let realm = try! Realm()
        try! realm.write({
            servantInfo!.setInfo(.Servant, info: data as? Dictionary<String, AnyObject>)
            
        })
        
        
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data!["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
       
    }
    
    
    func evaluatetripReply(notification: NSNotification) {
        SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 0.5, completion: { () in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    func commitAction(sender: UIButton) {
        XCGLogger.info("\(self.commonCell!.serviceStar)   \(self.commonCell!.servantStar)    \(self.commonCell!.comment)")
        
        let dict:Dictionary<String, AnyObject> = ["from_uid_": (hodometerInfo?.from_uid_)!,
                                                  "to_uid_": (hodometerInfo?.to_uid_)!,
                                                  "order_id_": (hodometerInfo?.order_id_)!,
                                                  "service_score_": (self.commonCell?.serviceStar)!,
                                                  "user_score_": (self.commonCell?.servantStar)!,
                                                  "remarks_": self.commonCell!.comment]
        SocketManager.sendData(.EvaluateTripRequest, data: dict)
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("AppointmentDetailCell", forIndexPath: indexPath) as! AppointmentDetailCell
            cell.setServiceInfo(hodometerInfo!)
   
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("IdentCommentCell", forIndexPath: indexPath) as! IdentCommentCell
            cell.setInfo(hodometerInfo)
            commonCell = cell
            if serviceScore != nil {
                cell.serviceSocre = serviceScore
                cell.userScore = userScore
                cell.remark = remark
            }
            return cell
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let dict:Dictionary<String, AnyObject> = ["uid_": (hodometerInfo?.to_uid_)!]
            SocketManager.sendData(.GetServantDetailInfo, data:dict)
           
        }
    }
    

    
    

    // MARK: - DATA
    func initData() {
        let param:[String: AnyObject] = ["order_id_": (hodometerInfo?.order_id_)!]
        SocketManager.sendData(.CheckCommentDetail, data: param) { [weak self](body) in
            if let strongSelf = self{
                let data = body["data"] as! NSDictionary
                let code = data.valueForKey("code")
                if code?.intValue == 0 {
                    SVProgressHUD.showErrorMessage(ErrorMessage: "获取评论信息失败，请稍后再试", ForDuration: 1, completion:nil)
                    return
                }
                strongSelf.serviceScore = data.valueForKey("service_score_") as? Int
                strongSelf.userScore = data.valueForKey("user_score_") as? Int
                strongSelf.remark = data.valueForKey("remarks_") as? String
                let isCommited = strongSelf.serviceScore != 0 && strongSelf.userScore != 0
                strongSelf.commitBtn?.enabled = isCommited
                SVProgressHUD.dismiss()
                strongSelf.table?.reloadData()
            }
        }
    }
    
}
