//
//  ServantPersonalVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/4.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import XCGLogger
import RealmSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


open class ServantPersonalVC : UIViewController, UITableViewDelegate, UITableViewDataSource, ServiceCellDelegate, PhotosCellDelegate, ServiceSheetDelegate {
    //记录是邀约？预约？   ture为邀约  false 为预约
    var isNormal = true
    
    var personalInfo:UserInfo?
    var personalTable:UITableView?
    var bottomBar:UIImageView?
    var serviceSpread = true
    var invitaionVC = InvitationVC()
    var alertController:UIAlertController?
    var appointment_id_ = 0
    
    var service_price_oneday:Int?
    
    var daysAlertController:UIAlertController?
    
    var selectedServcie:ServiceInfo?
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    func initView() {
        view.backgroundColor = UIColor.init(red: 33/255.0, green: 59/255.0, blue: 76/255.0, alpha: 1)
        title = personalInfo?.nickname
        
        bottomBar = UIImageView()
        bottomBar?.isUserInteractionEnabled = true
        bottomBar?.image = UIImage.init(named: "bottom-selector-bg")
        view.addSubview(bottomBar!)
        bottomBar?.snp.makeConstraints({ (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(50)
        })
        
        let chatBtn = UIButton()
        chatBtn.tag = 1001
        chatBtn.setTitle("开始聊天", for: UIControlState())
        chatBtn.backgroundColor = UIColor.clear
        chatBtn.setTitleColor(UIColor.white, for: UIControlState())
        chatBtn.addTarget(self, action: #selector(ServantPersonalVC.bottomBarAction(_:)), for: .touchUpInside)
        bottomBar?.addSubview(chatBtn)
        chatBtn.snp.makeConstraints { (make) in
            make.left.equalTo(bottomBar!)
            make.top.equalTo(bottomBar!)
            make.bottom.equalTo(bottomBar!)
            make.right.equalTo(bottomBar!.snp.centerX)
        }
        let invitationBtn = UIButton()
        invitationBtn.tag = 1002
        invitationBtn.setTitle( isNormal ? "发起邀约" : "发起预约", for: UIControlState())
        invitationBtn.backgroundColor = UIColor.clear
        invitationBtn.setTitleColor(UIColor.white, for: UIControlState())
        invitationBtn.addTarget(self, action: #selector(ServantPersonalVC.bottomBarAction(_:)), for: .touchUpInside)
        bottomBar?.addSubview(invitationBtn)
        invitationBtn.snp.makeConstraints { (make) in
            make.right.equalTo(bottomBar!)
            make.top.equalTo(bottomBar!)
            make.bottom.equalTo(bottomBar!)
            make.left.equalTo(bottomBar!.snp.centerX)
        }
        
        personalTable = UITableView(frame: CGRect.zero, style: .plain)
        personalTable!.register(PersonalHeadCell.self, forCellReuseIdentifier: "PersonalHeadCell")
        personalTable!.register(TallyCell.self, forCellReuseIdentifier: "TallyCell")
        personalTable!.register(ServiceCell.self, forCellReuseIdentifier: "ServiceCell")
        personalTable!.register(PhotosCell.self, forCellReuseIdentifier: "PhotosCell")
        personalTable!.tag = 1001
        personalTable!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        personalTable!.dataSource = self
        personalTable!.delegate = self
        personalTable!.estimatedRowHeight = 400
        personalTable!.rowHeight = UITableViewAutomaticDimension
        personalTable!.separatorStyle = .none
        personalTable!.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        view.addSubview(personalTable!)
        personalTable!.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(bottomBar!.snp.top)
        }
        
    }
    
    /**
     下面沟通 或者 邀约操作
     
     - parameter sender:
     */
    func bottomBarAction(_ sender: UIButton?) {
        if DataManager.currentUser?.has_recharged_ == 0 {
            let alert = UIAlertController.init(title: "余额不足", message: "服务者的最低价格为1000元，还需充值200元", preferredStyle: .alert)
            
            let ok = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
                XCGLogger.debug("去充值")
                
                let rechargeVC = RechargeVC()
                self.navigationController?.pushViewController(rechargeVC, animated: true)
                DataManager.currentUser?.cash = 10
                
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction) in
                
            })
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: { 
                
            })
            
            return
        }

        if sender?.tag == 1001 {
            XCGLogger.debug("Chats")
            let chatVC = ChatVC()
            chatVC.servantInfo = personalInfo
            navigationController?.pushViewController(chatVC, animated: true)
        } else if sender?.tag == 1002 {
            invitation()

        }
        
    }
    
    func invitation() {
        if alertController == nil {
            alertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
            let sheet = ServiceSheet()
            sheet.servantInfo = personalInfo
            sheet.isNormal = isNormal
            sheet.delegate = self
            alertController!.view.addSubview(sheet)
            sheet.snp.makeConstraints { (make) in
                make.left.equalTo(alertController!.view).offset(-10)
                make.right.equalTo(alertController!.view).offset(10)
                make.bottom.equalTo(alertController!.view).offset(10)
                make.top.equalTo(alertController!.view).offset(-10)
            }
        }
        
        present(alertController!, animated: true, completion: nil)
        
        
    }
    
    // MARK: - ServiceSheetDelegate
    func cancelAction(_ sender: UIButton?) {
        alertController?.dismiss(animated: true, completion: nil)
    }
    
    /**
     邀约或者预约确定
     
     - parameter service:
     - parameter daysCount:
     */
    func sureAction(_ service: ServiceInfo?, daysCount: Int?) {
        
        service_price_oneday = service?.service_price_
        
        
    
        if !isNormal { // 预约
            
            alertController?.dismiss(animated: true, completion: nil)
            
            let arrry = DataManager.getAppointmentRecordInfos(appointment_id_)
            let appointmentInfo:AppointmentInfo? = arrry?.first
            
            // 预约天数
            let dayNum:Double = Double(((appointmentInfo?.end_time_)! - (appointmentInfo?.start_time_)!) / (24 * 60 * 60))
            
            // 预约总金额
            let totalMoney = service_price_oneday! * Int(dayNum)
            let currentCash = DataManager.currentUser?.cash
            
            
            if currentCash >= totalMoney { // 余额充足
                
                SocketManager.sendData(.appointmentServantRequest, data: ["from_uid_": DataManager.currentUser!.uid,
                    "to_uid_": personalInfo!.uid,
                    "service_id_": service!.service_id_,
                    "appointment_id_":appointment_id_])
                
            }else{
                let alert = UIAlertController.init(title: "余额不足", message: "服务者的最低价格为1000元，还差\((totalMoney - currentCash!)/100)元", preferredStyle: .alert)
                
                let ok = UIAlertAction.init(title: "去充值", style: .default, handler: { (action: UIAlertAction) in
                    XCGLogger.debug("去充值")
                    
                    let rechargeVC = RechargeVC()
                    rechargeVC.chargeNumber = totalMoney - currentCash!
                    self.navigationController?.pushViewController(rechargeVC, animated: true)
                    
                })
                
                let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction) in
                    
                })
                
                alert.addAction(ok)
                alert.addAction(cancel)
                
                present(alert, animated: true, completion: {
                    
                })
            }
            
            
            
            

        } else { // 邀约
            unowned let weakSelf = self
            weakSelf.selectedServcie = service

            alertController?.dismiss(animated: true, completion: {
                
                weakSelf.perform(#selector(ServantPersonalVC.inviteAction), with: nil, afterDelay: 0.2)
                
                
            })
        }

    }
    

    func inviteAction() {
        unowned let weakSelf = self
        if daysAlertController == nil {
            daysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
            let sheet = CitysSelectorSheet()
            let days = [1, 2, 3, 4, 5, 6, 7]
           sheet.daysList = days
            sheet.delegate = self
            daysAlertController!.view.addSubview(sheet)
            sheet.snp.makeConstraints { (make) in
                make.left.equalTo(weakSelf.daysAlertController!.view).offset(-10)
                make.right.equalTo(weakSelf.daysAlertController!.view).offset(10)
                make.bottom.equalTo(weakSelf.daysAlertController!.view).offset(10)
                make.top.equalTo(weakSelf.daysAlertController!.view)
            }
        }
        
        present(weakSelf.daysAlertController!, animated: true, completion: nil)
    }
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(ServantPersonalVC.invitationResult(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AskInvitationResult), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ServantPersonalVC.receivedResults(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AppointmentServantReply), object: nil)
        
    }
    
    /**
     预约回调
     
     - parameter notifucation:
     */
    func receivedResults(_ notifucation: Notification?) {
        
        let dict = notifucation?.userInfo!["data"] as? Dictionary<String , AnyObject>
        
        var msg = "预约发起成功，等待对方接受邀请"
        if dict!["is_asked_"] as! Int == 1 {
            msg = "预约失败，您已经预约过对方"

        }
        
        let alert = UIAlertController.init(title: "预约状态",
                                           message: msg,
                                           preferredStyle: .alert)
        

        let action = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
            
        })
        
        alert.addAction(action)

        present(alert, animated: true) {
            /**
             预约完成 删除 推送的预约消息 测试状态 暂时不删
             */
//            DataManager.deletePushMessage(appointment_id_)
        }
    }
    /**
     邀约回调
     
     - parameter notifucation:
     */
    func invitationResult(_ notifucation: Notification?) {
        var msg = ""
        if let err = SocketManager.getErrorCode((notifucation?.userInfo as? [String: AnyObject])!) {
            switch err {
            case .noOrder:
                msg = "邀约失败，订单异常"
                break
            default:
                msg = "邀约失败，订单异常"
                break
            }
            
        }
        
        if let order = notifucation?.userInfo!["orderInfo"] as? HodometerInfo {
            if msg == "" {
                msg = order.is_asked_ == 0 ? "邀约发起成功，等待对方接受邀请" : "邀约失败，您已经邀约过对方"
            }
            let alert = UIAlertController.init(title: "邀约状态",
                                               message: msg,
                                               preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
                
            })
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        personalTable!.reloadData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        guard isNormal else { return }
        if navigationItem.rightBarButtonItem == nil {
            let msgItem = UIBarButtonItem.init(image: UIImage.init(named: "nav-msg"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ServantPersonalVC.msgAction(_:)))
            navigationItem.rightBarButtonItem = msgItem
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /**
    push to 聊天页面
     - parameter sender:
     */
    func msgAction(_ sender: AnyObject?) {
        let msgVC = PushMessageVC()
//        msgVC.messageInfo = recommendServants
        
        if sender?.isKind(of: UIButton.classForCoder()) == false {
            navigationController?.pushViewController(msgVC, animated: false)
            if let userInfo = sender as? [AnyHashable: Any] {
                let type = userInfo["type"] as? Int
                if type == PushMessage.MessageType.chat.rawValue {
                    perform(#selector(ForthwithVC.postPushMessageNotify(_:)), with: userInfo["data"], afterDelay: 0.5)
                }
            }
            
        } else {
            navigationController?.pushViewController(msgVC, animated: true)
        }
        
    }
    
    // MARK -- UITableViewDelegate & UITableViewDataSource
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalHeadCell", for: indexPath) as! PersonalHeadCell
            cell.setInfo(personalInfo, detailInfo: nil)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TallyCell", for: indexPath) as! TallyCell
            let tallys = List<Tally>()
            for businessTag in personalInfo!.businessTags {
                tallys.append(businessTag)
            }
            for travalTag in personalInfo!.travalTags {
                tallys.append(travalTag)
            }
            cell.setInfo(tallys)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            cell.delegate = self
            cell.setInfo(personalInfo!.serviceList, setSpread: serviceSpread)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosCell", for: indexPath) as! PhotosCell
            cell.delegate = self
            cell.setInfo(personalInfo!.photoUrlList, setSpread: serviceSpread)
            return cell
        }
        
    }
    
    // MARK ServiceCellDelegate
    func spreadAction(_ sender: AnyObject?) {
        let cell =  sender as! ServiceCell
        let indexPath = personalTable?.indexPath(for: cell)
        serviceSpread = !cell.spread
        personalTable?.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
    }
}


extension ServantPersonalVC:CitysSelectorSheetDelegate {
    func daysSureAction(_ sender: UIButton?, targetDays: Int) {
        daysAlertController?.dismiss(animated: true, completion: nil)
        
        let totalMoney = targetDays * service_price_oneday!  // 总价格
        let currentCash = DataManager.currentUser?.cash      // 当前余额
        
        if currentCash >= totalMoney {
            
            SocketManager.sendData(.askInvitation, data: ["from_uid_": DataManager.currentUser!.uid,
                "to_uid_": personalInfo!.uid,
                "service_id_": selectedServcie!.service_id_,
                "day_count_":targetDays])
        }else{

   
            let alert = UIAlertController.init(title: "余额不足", message: "服务者的最低价格为1000元，还差\((totalMoney - currentCash!)/100)元", preferredStyle: .alert)

            let ok = UIAlertAction.init(title: "去充值", style: .default, handler: { (action: UIAlertAction) in
                XCGLogger.debug("去充值")

                let rechargeVC = RechargeVC()
                rechargeVC.chargeNumber = totalMoney - currentCash!
                self.navigationController?.pushViewController(rechargeVC, animated: true)

            })

            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction) in

            })

            alert.addAction(ok)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: { 
                
            })
            
            return
            
        }

        SocketManager.sendData(.askInvitation, data: ["from_uid_": DataManager.currentUser!.uid,
                                          "to_uid_": personalInfo!.uid,
                                      "service_id_": selectedServcie!.service_id_,
                                       "day_count_":targetDays])
    }
    
    func daysCancelAction(_ sender: UIButton?) {
        
        daysAlertController?.dismiss(animated: true, completion: nil)
    }
}

