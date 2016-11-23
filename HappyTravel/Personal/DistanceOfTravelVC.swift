//
//  DistanceOfTravelVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/24.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
import MJRefresh
import XCGLogger
import SVProgressHUD
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


class DistanceOfTravelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var segmentSC:UISegmentedControl?
    var table:UITableView?
    var messageInfo:Array<UserInfo>? = []
    var segmentIndex = 0
    var timer:Timer?

    var orderID = 0
    var hotometers:Results<HodometerInfo>?
    
    var consumedOrderID = 0
    var consumes:Results<CenturionCardConsumedInfo>?
    var records:Results<AppointmentInfo>?
    var lastRecordId = 0
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    var selectedHodometerInfo:HodometerInfo?
    var selectedAppointmentInfo:AppointmentInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "我的消费"
        
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        header.perform(#selector(MJRefreshHeader.beginRefreshing), with: nil, afterDelay: 0.5)

    }
    
    func appearheaderRefresh() {
        header.beginRefreshing()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(DistanceOfTravelVC.obtainTripReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ObtainTripReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DistanceOfTravelVC.centurionCardConsumedReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.CenturionCardConsumedReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DistanceOfTravelVC.receivedAppointmentInfos(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AppointmentRecordReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DistanceOfTravelVC.payForInvitationReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.PayForInvitationReply), object: nil)
    }
    /**
     支付回调
     
     - parameter notification: 
     */
    func payForInvitationReply(_ notification: Notification) {
        if let result = notification.userInfo!["result_"] as? Int {
            var msg = ""
            switch result {
            case 0:
                msg = "预支付成功"
                if segmentIndex == 0 {
                    SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                        "order_id_": 0,
                        "count_": 10])
                } else {
                    SocketManager.sendData(.appointmentRecordRequest, data: ["uid_": DataManager.currentUser!.uid,
                        "last_id_": 0,
                        "count_": 10])
                }
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
        
        
    }
    /**
     邀约行程回调记录
     - parameter notification:
     */
    func obtainTripReply(_ notification: Notification) {
        if header.state == MJRefreshState.refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.refreshing {
            footer.endRefreshing()
        }
        
        let realm = try! Realm()
        hotometers = realm.objects(HodometerInfo.self).sorted("start_", ascending: false)
        
        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .noMoreData
            footer.setTitle("多乎哉 不多矣", for: .noMoreData)
            table?.reloadData()
            return
        }
        orderID = lastOrderID
        if segmentIndex == 0 {
            table?.reloadData()
        }
        
    }
    /**
     黑卡消费记录回调
     - parameter notification:
     */
    func centurionCardConsumedReply(_ notification: Notification) {
        if header.state == MJRefreshState.refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.refreshing {
            footer.endRefreshing()
        }
        
        let realm = try! Realm()
        consumes = realm.objects(CenturionCardConsumedInfo.self).sorted("order_id_", ascending: false)
        
        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .noMoreData
            footer.setTitle("多乎哉 不多矣", for: .noMoreData)
            table?.reloadData()
            return
        }
        consumedOrderID = lastOrderID
        if segmentIndex == 2 {
            table?.reloadData()
        }
        
    }
    
    /**
     预约行程记录回调
     
     - parameter notification: 
     */
    func receivedAppointmentInfos(_ notification:Notification) {
        
        if header.state == MJRefreshState.refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.refreshing {
            footer.endRefreshing()
        }
        let realm = try! Realm()
        records = realm.objects(AppointmentInfo.self).sorted("appointment_id_", ascending: false)
        let lastID = notification.userInfo!["lastID"] as! Int
        if lastID == -9999 {
            footer.state = .noMoreData
            footer.setTitle("多乎哉 不多矣", for: .noMoreData)
            table?.reloadData()
            return
        }
        lastRecordId = lastID
        if segmentIndex == 1 {
            table?.reloadData()
        }
        
    }
    
    func initView() {
        let segmentBGV = UIImageView()
        segmentBGV.image = UIImage.init(named: "segment-bg")
        view.addSubview(segmentBGV)
        segmentBGV.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(60)
        }
        
        let segmentItems = ["商务游", "预约", "黑卡消费"]
        segmentSC = UISegmentedControl(items: segmentItems)
        segmentSC!.tag = 1001
        segmentSC!.addTarget(self, action: #selector(DistanceOfTravelVC.segmentChange), for: UIControlEvents.valueChanged)
        segmentSC!.selectedSegmentIndex = segmentIndex
        segmentSC!.layer.masksToBounds = true
        segmentSC?.layer.cornerRadius = 5
        segmentSC?.backgroundColor = UIColor.clear
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        segmentSC?.tintColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
        view.addSubview(segmentSC!)
        segmentSC!.snp_makeConstraints { (make) in
            make.center.equalTo(segmentBGV)
            make.height.equalTo(30)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0)
        }
        
        table = UITableView(frame: CGRect.zero, style: .plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .none
        table?.register(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        table?.register(CentrionCardConsumedCell.self, forCellReuseIdentifier: "CentrionCardConsumedCell")
        table?.register(AppointmentRecordCell.self, forCellReuseIdentifier: "AppointmentRecordCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(segmentBGV.snp_bottom)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        header.setRefreshingTarget(self, refreshingAction: #selector(DistanceOfTravelVC.headerRefresh))
        table?.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(DistanceOfTravelVC.footerRefresh))
        table?.mj_footer = footer

    }
    
    func headerRefresh() {

        switch segmentIndex {
        case 0:
            SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                "order_id_": 0,
                "count_": 10])
            break
        case 1:
            SocketManager.sendData(.appointmentRecordRequest, data: ["uid_": DataManager.currentUser!.uid,
                "last_id_": 0,
                "count_": 10])
            break
        case 2:
            SocketManager.sendData(.centurionCardConsumedRequest, data: ["uid_": DataManager.currentUser!.uid])
            break
        default:
            break
        }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(DistanceOfTravelVC.endRefresh), userInfo: nil, repeats: false)
        /**
         加入mainloop 防止滑动计时器停止
         */
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func footerRefresh() {
        switch segmentIndex {
        case 0:
            SocketManager.sendData(.obtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                "order_id_": orderID,
                "count_": 10])
            break
        case 1:
            SocketManager.sendData(.appointmentRecordRequest, data: ["uid_": DataManager.currentUser!.uid,
                "last_id_": lastRecordId,
                "count_": 10])
            break
        case 2:
            SocketManager.sendData(.centurionCardConsumedRequest, data: ["uid_": DataManager.currentUser!.uid])
            break
        default:
            break
        }
        
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cnt = 0
        if segmentIndex == 0 {
            cnt = hotometers != nil ? hotometers!.count : 0
        } else if (segmentIndex == 1){
            cnt = records != nil ? records!.count : 0
        } else {
            cnt = consumes != nil ? consumes!.count : 0
        }
        footer.isHidden = cnt < 10 ? true : false
        return cnt
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch segmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DistanceOfTravelCell", for: indexPath) as! DistanceOfTravelCell
            if hotometers?.count > 0 && indexPath.row < hotometers?.count {
                cell.setHodometerInfo(hotometers![indexPath.row])
            }
            
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentRecordCell", for: indexPath) as! AppointmentRecordCell
            if records?.count > 0 && indexPath.row < records?.count {
                cell.setRecordInfo(records![indexPath.row])
            }
            
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CentrionCardConsumedCell", for: indexPath) as! CentrionCardConsumedCell
            if consumes?.count > 0 && indexPath.row < consumes?.count {
                cell.setCenturionCardConsumedInfo(consumes![indexPath.row])
            }
            
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch segmentIndex {
        case 0:
            if let cell = tableView.cellForRow(at: indexPath) as? DistanceOfTravelCell {
                if  cell.curHodometerInfo?.status_ == HodometerStatus.invoiceMaking.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.invoiceMaked.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.completed.rawValue{
                    
                    let identDetailVC = IdentDetailVC()
                    identDetailVC.hodometerInfo = cell.curHodometerInfo!
                    navigationController?.pushViewController(identDetailVC, animated: true)
                    /**
                     *  未支付状态去支付
                     */
                } else if cell.curHodometerInfo?.status_ == HodometerStatus.waittingPay.rawValue {
                    SocketManager.sendData(.checkUserCash, data: ["uid_":DataManager.currentUser!.uid])
                    selectedHodometerInfo = cell.curHodometerInfo
                    payForInvitationRequest()
                    
                }
            }
            break
        case 1:
            let detailVC = AppointmentDetailVC()
            guard  records?.count > 0 else {
                XCGLogger.error("注意: records数据是空的！")
                return
            }
            
            let object = records![indexPath.row]
            guard object.status_ > 1  else {
                SVProgressHUD.showWainningMessage(WainningMessage: "此预约尚未确定服务者", ForDuration: 1.5, completion: nil)
                return
            }
            if  object.status_ == HodometerStatus.InvoiceMaking.rawValue ||
                object.status_ == HodometerStatus.InvoiceMaked.rawValue ||
                object.status_ == HodometerStatus.Completed.rawValue{
                
                detailVC.appointmentInfo = records![indexPath.row]
                navigationController?.pushViewController(detailVC, animated: true)
                /**
                 *  未支付状态去支付
                 */
            } else if object.status_ == HodometerStatus.WaittingPay.rawValue {
                SocketManager.sendData(.checkUserCash, data: ["uid_":DataManager.currentUser!.uid])
                 selectedAppointmentInfo = records![indexPath.row]
                payForInvitationRequest()
                
            }
//            
//            guard object.status_ > 1  else {
//              SVProgressHUD.showWainningMessage(WainningMessage: "此预约尚未确定服务者", ForDuration: 1.5, completion: nil)
//                return
//            }
//            guard object.status_ != 3  else {
//                SVProgressHUD.showWainningMessage(WainningMessage: "预约已取消", ForDuration: 1.5, completion: nil)
//                return
//            }
//            /**
//             *  未支付状态去支付
//             */
//            if object.status_ == 2 {
//                selectedAppointmentInfo = records![indexPath.row]
//                payForInvitationRequest()
//                
//            } else {
//                detailVC.appointmentInfo = records![indexPath.row]
//                navigationController?.pushViewController(detailVC, animated: true)
//            }      
            break
        case 2:
            break
        default:
            break
        }
    }
    
    func segmentChange(_ sender: AnyObject?) {
        segmentIndex = (sender?.selectedSegmentIndex)!
        if header.state == .idle && (footer.state == .idle || footer.state == .noMoreData){
            header.beginRefreshing()
        }

    }
    func endRefresh() {
    
        if header.state == .refreshing {
            header.endRefreshing()
        }
        if footer.state == .refreshing {
            footer.endRefreshing()
        }
        if timer != nil {
            
            timer?.invalidate()
            timer = nil
        }
    }
    /**
     支付操作
     */
    func payForInvitationRequest() {
//        guard info != nil else {return}
        guard segmentIndex != 2 else { return }
        weak var weakSelf = self
       
        var price = 0
        var order_id_ = 0
        if segmentIndex == 1 {
            price = (selectedAppointmentInfo?.order_price_)!
            order_id_ = (selectedAppointmentInfo?.order_id_)!

        } else {
            price =  (selectedHodometerInfo?.order_price_)!
            order_id_ = (selectedHodometerInfo?.order_id_)!
        }
        let msg = "\n您即将预支付人民币:\(Double(price)/100)元"
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
                        weakSelf!.payForInvitationRequest()
                    })
                })
                warningAlert.addAction(sure)
                weakSelf!.present(warningAlert, animated: true, completion: nil)
            } else {
                if DataManager.currentUser?.cash < price {
                    weakSelf!.moneyIsTooLess()
                } else {
                    let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)! as AnyObject,
                                               "order_id_": order_id_ as AnyObject,
                                                 "passwd_": passwd! as AnyObject]
                    SocketManager.sendData(.payForInvitationRequest, data: dict)
                }
                
            }
            
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    /**
     余额不足操作
     */
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
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
