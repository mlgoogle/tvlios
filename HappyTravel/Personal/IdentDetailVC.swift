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
    
    var servantDict:Dictionary<String, AnyObject>?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "订单详情"
        initData()
        initView()
        
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .none
        table?.register(IdentBaseInfoCell.self, forCellReuseIdentifier: "IdentBaseInfoCell")
        table?.register(IdentCommentCell.self, forCellReuseIdentifier: "IdentCommentCell")
        table?.register(AppointmentDetailCell.self, forCellReuseIdentifier: "AppointmentDetailCell")
        view.addSubview(table!)
        
        let commitBtn = UIButton()
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), for: UIControlState())
        commitBtn.setTitle("发表评论", for: UIControlState())
        commitBtn.addTarget(self, action: #selector(IdentDetailVC.commitAction(_:)), for: .touchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
        }
        self.commitBtn = commitBtn
        
        table?.snp.makeConstraints({ (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(commitBtn.snp.top)
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
        NotificationCenter.default.addObserver(self, selector: #selector(IdentDetailVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IdentDetailVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IdentDetailVC.evaluatetripReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.EvaluatetripReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IdentDetailVC.servantDetailInfo(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ServantDetailInfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IdentDetailVC.servantBaseInfoReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.UserBaseInfoReply), object: nil)
    }
    
    
    func servantDetailInfo(_ notification: Notification) {


        let data = notification.userInfo!["data"] as! [String : Any]
        if data["error_"]! != nil {
            XCGLogger.error("Get UserInfo Error:\(data["error"])")
            return
        }
        servantInfo =  DataManager.getUserInfo((hodometerInfo?.to_uid_)!)
        guard servantInfo != nil else {
            
            servantDict = data
//            servantInfo = UserInfo()
//            servantInfo!.setInfo(.Servant, info: data as? Dictionary<String, AnyObject>)
            getServantBaseInfo()
            
            return
        }
        
        let realm = try! Realm()
        try! realm.write({
                
          servantInfo!.setInfo(.servant, info: data)
                
        })
        
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
       
    }
    
    func getServantBaseInfo() {
        
        let dic = ["uid_str_" : String((hodometerInfo?.to_uid_)!) + "," + "0"]
        _ = SocketManager.sendData(.getUserInfo, data: dic as AnyObject?)
        
    }
    func servantBaseInfoReply(_ notification: Notification) {
        
        servantInfo =  DataManager.getUserInfo((hodometerInfo?.to_uid_)!)
        let realm = try! Realm()
        try! realm.write({
            
            servantInfo!.setInfo(.servant, info: servantDict)
            
        })
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.personalInfo = servantInfo
        navigationController?.pushViewController(servantPersonalVC, animated: true)
    }
    
    func evaluatetripReply(_ notification: Notification) {
     
        unowned let weakSelf = self
        SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 0.5, completion: { () in
            _ = weakSelf.navigationController?.popViewController(animated: true)
        })
    }
    
    func keyboardWillShow(_ notification: Notification?) {
        let frame = (notification!.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let inset = UIEdgeInsetsMake(0, 0, (frame?.size.height)!, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    func commitAction(_ sender: UIButton) {
        XCGLogger.info("\(self.commonCell!.serviceStar)   \(self.commonCell!.servantStar)    \(self.commonCell!.comment)")
        
        let dict:Dictionary<String, AnyObject> = ["from_uid_": (hodometerInfo?.from_uid_)! as AnyObject,
                                                  "to_uid_": (hodometerInfo?.to_uid_)! as AnyObject,
                                                  "order_id_": (hodometerInfo?.order_id_)! as AnyObject,
                                                  "service_score_": (self.commonCell?.serviceStar)! as AnyObject,
                                                  "user_score_": (self.commonCell?.servantStar)! as AnyObject,
                                                  "remarks_": self.commonCell!.comment as AnyObject]
        _ = SocketManager.sendData(.evaluateTripRequest, data: dict as AnyObject?)
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentDetailCell", for: indexPath) as! AppointmentDetailCell
            cell.setServiceInfo(hodometerInfo!)

            cell.hideCityInfo()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentCommentCell", for: indexPath) as! IdentCommentCell
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let dict:Dictionary<String, AnyObject> = ["uid_": (hodometerInfo?.to_uid_)! as AnyObject]
            _ = SocketManager.sendData(.getServantDetailInfo, data:dict as AnyObject?)
           
        }
    }
    

    
    

    // MARK: - DATA
    func initData() {
        let param:[String: AnyObject] = ["order_id_": (hodometerInfo?.order_id_)! as AnyObject]
        SocketManager.sendData(.checkCommentDetail, data: param as AnyObject?) { [weak self](body) in
            if let strongSelf = self{
                let data = body["data"] as! NSDictionary
                let code = data.value(forKey: "code")
                if (code as AnyObject).int32Value == 0 {
                    SVProgressHUD.showErrorMessage(ErrorMessage: "获取评论信息失败，请稍后再试", ForDuration: 1, completion:nil)
                    return
                }
                
                if data.value(forKey: "error_") != nil{
                    return
                }
                strongSelf.serviceScore = data.value(forKey: "service_score_") as? Int
                strongSelf.userScore = data.value(forKey: "user_score_") as? Int
                strongSelf.remark = data.value(forKey: "remarks_") as? String
                // 是否可以评论过滤条件 暂设为 用户打分 和 服务打分 全为0 则可继续提交评论
                let isCommited = strongSelf.serviceScore != 0 || strongSelf.userScore != 0
                strongSelf.commitBtn?.isEnabled = !isCommited
                SVProgressHUD.dismiss()
                strongSelf.table?.reloadData()
            }
        }
    }
    
}
