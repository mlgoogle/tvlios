//
//  PushMessageVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/25.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
import XCGLogger
import MJRefresh
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



class PushMessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentAppointmentId = 0
    var segmentSC:UISegmentedControl?
    var selectedIndex = 0
    var table:UITableView?
    var servantsArray:Array<UserInfo>? = []
    var segmentIndex = 0
    var orderID = 0
    var hotometers:Results<HodometerInfo>?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "消息中心"
        
        initView()
        segmentChange(segmentSC)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        table?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(PushMessageVC.chatMessage(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ChatMessgaeNotiy), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PushMessageVC.pushMessageNotify(_:)), name: NSNotification.Name(rawValue: NotifyDefine.PushMessageNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DistanceOfTravelVC.obtainTripReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ObtainTripReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PushMessageVC.receivedAppoinmentRecommendServants(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AppointmentRecommendReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PushMessageVC.payForInvitationReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.PayForInvitationReply), object: nil)
    }
    
    func receivedAppoinmentRecommendServants(_ notification:Notification?) {
        
        if let data = notification?.userInfo!["data"] as? Dictionary<String, AnyObject> {
            servantsArray?.removeAll()
        
            let servants = data["recommend_guide"] as? Array<Dictionary<String, AnyObject>>
           
            var uid_str = ""
            for servant in servants! {
                let servantInfo = UserInfo()
                servantInfo.setInfo(.servant, info: servant)
                servantsArray?.append(servantInfo)
                uid_str += "\(servantInfo.uid),"

            }
            let recommendVC = RecommendServantsVC()
            recommendVC.isNormal = false
            recommendVC.appointment_id_ = currentAppointmentId
            recommendVC.servantsInfo = servantsArray
            navigationController?.pushViewController(recommendVC, animated: true)
            uid_str.remove(at: uid_str.characters.index(before: uid_str.endIndex))
            let dict:Dictionary<String, AnyObject> = ["uid_str_": uid_str as AnyObject]
            _ = SocketManager.sendData(.getUserInfo, data: dict as AnyObject?)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(PushMessageVC.obtainTripReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ObtainTripReply), object: nil)
    }
    
    func payForInvitationReply(_ notification: Notification) {
        let result = notification.userInfo!["result_"] as! Int
        var msg = ""
        switch result {
        case 0:
            msg = "预支付成功"
            _ = SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                                                             "order_id_": 0,
                                                                "count_": 10])
        case -1:
            msg = "密码错误"
        case -2:
            msg = "余额不足"
            moneyIsTooLess()
            return
        default:
            break
        }
        let alert = UIAlertController.init(title: "提示", message: msg, preferredStyle: .alert)
        let sure = UIAlertAction.init(title: "好的", style: .cancel, handler: nil)
        alert.addAction(sure)
        present(alert, animated: true, completion: nil)
        
    }
    
    func obtainTripReply(_ notification: Notification) {
        if header.state == MJRefreshState.refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.refreshing {
            footer.endRefreshing()
        }
        
        let realm = try! Realm()
        hotometers = realm.objects(HodometerInfo.self).sorted(byProperty: "start_", ascending: false)
        
        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .noMoreData
            footer.setTitle("多乎哉 不多矣", for: .noMoreData)
            return
        }
        orderID = lastOrderID
        table?.reloadData()
    }
    
    func chatMessage(_ notification: Notification?) {
//        let data = (notification?.userInfo!["data"])! as! Dictionary<String, AnyObject>
        table?.reloadData()
        
    }
    
    func pushMessageNotify(_ notification: Notification) {
        if let dict = notification.userInfo as? Dictionary<String, AnyObject> {
            if let msg = dict["data"] as? Dictionary<String, AnyObject> {
                let chatVC = ChatVC()
                chatVC.servantInfo = DataManager.getUserInfo(msg["from_uid_"] as! Int)
                navigationController?.pushViewController(chatVC, animated: true)
            }
        }
        
    }
    
    func initView() {
        let segmentBGV = UIImageView()
        segmentBGV.image = UIImage.init(named: "segment-bg")
        view.addSubview(segmentBGV)
        segmentBGV.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(60)
        }
        
        let segmentItems = ["消息", "行程"]
        segmentSC = UISegmentedControl(items: segmentItems)
        segmentSC!.tag = 1001
        segmentSC!.addTarget(self, action: #selector(PushMessageVC.segmentChange), for: UIControlEvents.valueChanged)
        segmentSC!.selectedSegmentIndex = selectedIndex
        segmentSC!.layer.masksToBounds = true
        segmentSC?.layer.cornerRadius = 5
        segmentSC?.backgroundColor = UIColor.clear
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        segmentSC?.tintColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
        view.addSubview(segmentSC!)
        segmentSC!.snp.makeConstraints { (make) in
            make.center.equalTo(segmentBGV)
            make.height.equalTo(30)
            make.width.equalTo(UIScreen.main.bounds.size.width / 2.0)
        }
    
        table = UITableView(frame: CGRect.zero, style: .plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .none
        table?.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        table?.register(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        view.addSubview(table!)
        table?.snp.makeConstraints({ (make) in
            make.left.equalTo(view)
            make.top.equalTo(segmentBGV.snp.bottom)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        header.isHidden = true
        header.setRefreshingTarget(self, refreshingAction: #selector(PushMessageVC.headerRefresh))
        table?.mj_header = header
        footer.isHidden = true
        footer.setRefreshingTarget(self, refreshingAction: #selector(PushMessageVC.footerRefresh))
        table?.mj_footer = footer
        
    }
    
    func headerRefresh() {
        if segmentIndex == 0 {
            header.endRefreshing()
        } else if segmentIndex == 1 {
            _ = SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                "order_id_": 0,
                "count_": 10])
        }
        
    }
    
    func footerRefresh() {
        if segmentIndex == 0 {
            footer.endRefreshing()
        } else if segmentIndex == 1 {
            _ = SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                "order_id_": orderID,
                "count_": 10])
        }
        
    }
    
    func segmentChange(_ sender: UISegmentedControl?) {
        segmentIndex = (sender?.selectedSegmentIndex)!
        if segmentIndex == 0 {
            header.isHidden = true
            footer.isHidden = true
        } else if segmentIndex == 1 {
            header.isHidden = false
            footer.isHidden = false
            header.beginRefreshing()
        }
        table?.reloadData()
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentIndex == 0 ? DataManager.getMessageCount(-1) : (hotometers != nil ? hotometers!.count : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            let realm = try! Realm()
            let userPushMessage = realm.objects(UserPushMessage.self).sorted(byProperty: "msg_time_", ascending: false)[indexPath.row]
            cell.setInfo(userPushMessage.msgList.last, unreadCnt: userPushMessage.unread)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DistanceOfTravelCell", for: indexPath) as! DistanceOfTravelCell
            cell.setHodometerInfo(hotometers![indexPath.row])
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentIndex == 0 {
            let realm = try! Realm()
            let userPushMessage = realm.objects(UserPushMessage.self).sorted(byProperty: "msg_time_", ascending: false)[indexPath.row]

            let message = userPushMessage.msgList.last
            if message?.push_msg_type == 2231 {
                let uid_str_ = message?.service_id_
                currentAppointmentId = (message?.appointment_id_)!
                _ = SocketManager.sendData(.appointmentRecommendRequest, data: ["uid_str_": uid_str_!])
                DataManager.readMessage(currentAppointmentId)

                return

            }

            
            if let cell = tableView.cellForRow(at: indexPath) as? MessageCell {
                let chatVC = ChatVC()
                chatVC.servantInfo = cell.userInfo
                navigationController?.pushViewController(chatVC, animated: true)
                
            }
        } else if segmentIndex == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? DistanceOfTravelCell {
                let status = cell.curHodometerInfo?.status_
                if cell.curHodometerInfo?.status_ == HodometerStatus.invoiceMaking.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.invoiceMaked.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.completed.rawValue {
                    let identDetailVC = IdentDetailVC()
                    identDetailVC.hodometerInfo = cell.curHodometerInfo!
                    navigationController?.pushViewController(identDetailVC, animated: true)
                } else if status == HodometerStatus.waittingPay.rawValue {
                    _ = SocketManager.sendData(.checkUserCash, data: ["uid_":DataManager.currentUser!.uid])
                    payForInvitationRequest(cell.curHodometerInfo)
                }
                
            }
        }
        
    }
    
    func payForInvitationRequest(_ info: HodometerInfo?) {
        guard info != nil else {return}
        weak var weakSelf = self
        let msg = "\n您即将预支付人民币:\(Double((info?.order_price_)!) / 100)元"
        let alert = UIAlertController.init(title: "付款确认", message: msg, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "请输入密码"
            textField.isSecureTextEntry = true
        })
        
        let ok = UIAlertAction.init(title: "确认付款", style: .default, handler: { (action) in
            var errMsg = ""
            let passwd = alert.textFields?.first?.text
            if passwd?.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                errMsg = "请输入密码"
            } else if let localPasswd = UserDefaults.standard.object(forKey: CommonDefine.Passwd) as? String {
                if passwd != localPasswd {
                    errMsg = "密码输入错误，请重新输入"
                }
            }
            if errMsg.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                let warningAlert = UIAlertController.init(title: "提示", message: errMsg, preferredStyle: .alert)
                let sure = UIAlertAction.init(title: "好的", style: .cancel, handler: { (action) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 0.15)) / Double(NSEC_PER_SEC), execute: { () in
                        weakSelf!.payForInvitationRequest(info)
                    })
                })
                warningAlert.addAction(sure)
                weakSelf!.present(warningAlert, animated: true, completion: nil)
            } else {
                if DataManager.currentUser?.cash < info?.order_price_ {
                    weakSelf!.moneyIsTooLess()
                } else {
                    let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)! as AnyObject,
                        "order_id_": (info?.order_id_)! as AnyObject,
                        "passwd_": passwd! as AnyObject]
                    _ = SocketManager.sendData(.payForInvitationRequest, data: dict as AnyObject?)
                }
                
            }
            
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func moneyIsTooLess() {
        let alert = UIAlertController.init(title: "余额不足", message: "\n请前往充值", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "前往充值", style: .default, handler: { (action: UIAlertAction) in
            let rechargeVC = RechargeVC()
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

