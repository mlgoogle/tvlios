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
enum OrderType : Int {
    case InviteOrder = 0
    case AppointmentOrder = 1
    case CenturionCardOrder = 2
}
class DistanceOfTravelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var segmentSC:UISegmentedControl?
    var table:UITableView?
    var messageInfo:Array<UserInfo>? = []
    var segmentIndex = 0
    var timer:NSTimer?
    var servantsArray:Array<UserInfo>? = []

    var hotometers:Results<HodometerInfo>?
    var currentApponitmentID = 0
    
    var consumes:Results<CenturionCardConsumedInfo>?
    var records:Results<AppointmentInfo>?
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    var selectedHodometerInfo:HodometerInfoModel?
    var selectedAppointmentInfo:AppointmentInfoModel?
    
    var orderID = 0
    var lastRecordId = 0
    var consumedOrderID = 0
    
    /***
     新
     \***/
    var inviteList:Results<HodometerInfoModel>?
    var appointmentList:Results<AppointmentInfoModel>?
    var centurionRecordList:Results<CenturionCardRecordModel>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "我的消费"
        
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        registerNotify()
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)

    }
    
    func appearheaderRefresh() {
        header.beginRefreshing()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
//    
//    func registerNotify() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.obtainTripReply(_:)), name: NotifyDefine.ObtainTripReply, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.receivedAppoinmentRecommendServants(_:)), name: NotifyDefine.AppointmentRecommendReply, object: nil)
//
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.centurionCardConsumedReply(_:)), name: NotifyDefine.CenturionCardConsumedReply, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.receivedAppointmentInfos(_:)), name: NotifyDefine.AppointmentRecordReply, object: nil)
////        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.payForInvitationReply(_:)), name: NotifyDefine.PayForInvitationReply, object: nil)
//    }
//    func receivedAppoinmentRecommendServants(notification:NSNotification?) {
//        
//        if let data = notification?.userInfo!["data"] as? Dictionary<String, AnyObject> {
//            servantsArray?.removeAll()
//            if let servants = data["recommend_guide_"] as? Array<Dictionary<String, AnyObject>> {
//                var uid_str = ""
//                for servant in servants {
//                    let servantInfo = UserInfo()
//                    servantInfo.setInfo(.Servant, info: servant)
//                    servantsArray?.append(servantInfo)
//                    uid_str += "\(servantInfo.uid),"
//                    
//                }
//                let recommendVC = RecommendServantsVC()
//                recommendVC.isNormal = false
//                recommendVC.appointment_id_ = currentApponitmentID
//                recommendVC.servantsInfo = servantsArray
//                navigationController?.pushViewController(recommendVC, animated: true)
//                uid_str.removeAtIndex(uid_str.endIndex.predecessor())
//                let dict:Dictionary<String, AnyObject> = ["uid_str_": uid_str]
//                SocketManager.sendData(.GetUserInfo, data: dict)
//            }
//            
//        }
//    }
//    
    /**
     支付回调
     
     - parameter notification: 
     */
//    func payForInvitationReply(notification: NSNotification) {
//        
//        
//        if let result = notification.userInfo!["result_"] as? Int {
//            var msg = ""
//            switch result {
//            case 0:
//                 MobClick.event(CommonDefine.BuriedPoint.payForOrderSuccess)
//                msg = "预支付成功"
//                if segmentIndex == 0 {
//                    SocketManager.sendData(.ObtainTripRequest, data: ["uid_": CurrentUser.uid_,
//                        "order_id_": 0,
//                        "count_": 10])
//                } else {
//                    SocketManager.sendData(.AppointmentRecordRequest, data: ["uid_": CurrentUser.uid_,
//                        "last_id_": 0,
//                        "count_": 10])
//                }
//            case -1:
//                msg = "密码错误"
//            case -2:
//                 MobClick.event(CommonDefine.BuriedPoint.payForOrderFail)
//                msg = "余额不足"
//                moneyIsTooLess()
//                return
//            default:
//                break
//            }
//            let alert = UIAlertController.init(title: "提示", message: msg, preferredStyle: .Alert)
//            let sure = UIAlertAction.init(title: "好的", style: .Cancel, handler: nil)
//            alert.addAction(sure)
//            presentViewController(alert, animated: true, completion: nil)
//        }
//        
//        
//    }
//    /**
//     邀约行程回调记录
//     - parameter notification:
//     */
//    func obtainTripReply(notification: NSNotification) {
//        if header.state == MJRefreshState.Refreshing {
//            header.endRefreshing()
//        }
//        if footer.state == MJRefreshState.Refreshing {
//            footer.endRefreshing()
//        }
//        
//        let realm = try! Realm()
//        hotometers = realm.objects(HodometerInfo.self).filter("order_id_ != 0").sorted("start_", ascending: false)
//        
//        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
//        if lastOrderID == -1001 {
//            footer.state = .NoMoreData
//            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
//            table?.reloadData()
//            return
//        }
//        orderID = lastOrderID
//        if segmentIndex == 0 {
//            table?.reloadData()
//        }
//        
//    }
//    /**
//     黑卡消费记录回调
//     - parameter notification:
//     */
//    func centurionCardConsumedReply(notification: NSNotification) {
//        if header.state == MJRefreshState.Refreshing {
//            header.endRefreshing()
//        }
//        if footer.state == MJRefreshState.Refreshing {
//            footer.endRefreshing()
//        }
//        
//        let realm = try! Realm()
//        consumes = realm.objects(CenturionCardConsumedInfo.self).filter("order_status_ > 3").sorted("order_id_", ascending: false)
//        
//        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
//        if lastOrderID == -1001 {
//            footer.state = .NoMoreData
//            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
//            table?.reloadData()
//            return
//        }
//        consumedOrderID = lastOrderID
//        if segmentIndex == 2 {
//            table?.reloadData()
//        }
//        
//    }
//    
//    /**
//     预约行程记录回调
//     
//     - parameter notification: 
//     */
//    func receivedAppointmentInfos(notification:NSNotification) {
//        let realm = try! Realm()
//        if header.state == MJRefreshState.Refreshing {
//            header.endRefreshing()
//            
//        }
//        if footer.state == MJRefreshState.Refreshing {
//            footer.endRefreshing()
//        }
//        
//        records = realm.objects(AppointmentInfo.self).sorted("appointment_id_", ascending: false)
//        let lastID = notification.userInfo!["lastID"] as! Int
//        if lastID == -9999 {
//            footer.state = .NoMoreData
//            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
//            table?.reloadData()
//            return
//        }
//        lastRecordId = lastID
//        if segmentIndex == 1 {
//            table?.reloadData()
//        }
//        
//    }
//    
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
        segmentSC!.addTarget(self, action: #selector(DistanceOfTravelVC.segmentChange), forControlEvents: UIControlEvents.ValueChanged)
        segmentSC!.selectedSegmentIndex = segmentIndex
        segmentSC!.layer.masksToBounds = true
        segmentSC?.layer.cornerRadius = 5
        segmentSC?.backgroundColor = UIColor.clearColor()
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        segmentSC?.tintColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
        view.addSubview(segmentSC!)
        segmentSC!.snp_makeConstraints { (make) in
            make.center.equalTo(segmentBGV)
            make.height.equalTo(30)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0 + 20)
        }
        
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        table?.registerClass(CentrionCardConsumedCell.self, forCellReuseIdentifier: "CentrionCardConsumedCell")
        table?.registerClass(AppointmentRecordCell.self, forCellReuseIdentifier: "AppointmentRecordCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(segmentBGV.snp_bottom)
            make.right.equalTo(view)
            make.bottom.equalTo(view).offset(-5)
        })
        header.setRefreshingTarget(self, refreshingAction: #selector(DistanceOfTravelVC.headerRefresh))
        table?.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(DistanceOfTravelVC.footerRefresh))
        table?.mj_footer = footer

    }
    func footerRefresh() {
        refreshAction(false)
    }
    
    func headerRefresh() {
        refreshAction(true)
    }
    func refreshAction(isRefresh:Bool) {
        
        footer.state = .Idle
        switch segmentIndex {
        case 0:
            handleInviteOrderRequest(isRefresh)
        case 1:
            handleAppointmentRequest(isRefresh)
            break
        case 2:
            handleCenturionCardRequest(isRefresh)

            footer.state = .NoMoreData
            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
            break
        default:
            break
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(DistanceOfTravelVC.endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func handleCenturionCardRequest(isRefresh:Bool) {
        APIHelper.consumeAPI().requsetCenturionCardRecordList(CenturionCardRecordRequestModel(), complete: { (response) in
            self.endRefresh()
            }) { (error) in
                
        }
    }
    
    func handleAppointmentRequest(isRefresh:Bool) {
        let model = AppointmentRequestModel()
        model.last_id_ = isRefresh ? 0 : lastRecordId
        APIHelper.consumeAPI().requestAppointmentList(model, complete: { (response) in
            self.lastRecordId = response as! Int
            self.endRefresh()
            }) { (error) in
        }
    }
    
    func handleInviteOrderRequest(isRefresh:Bool) {
        let model = HodometerRequestModel()
        model.order_id_ = isRefresh ? 0 : orderID
        APIHelper.consumeAPI().requestInviteOrderLsit(model, complete: { (response) in
            self.lastRecordId = response as! Int
            self.endRefresh()
            }) { (error) in
        }
    }
    

    func requestRecommendListWithUidStr(uid_str_:String) {
        let model = AppointmentRecommendRequestModel()
        model.uid_str_ = uid_str_
        APIHelper.consumeAPI().requestAppointmentRecommendList(model, complete: { (response) in
            
            let listModel = response as? AppointmentRecommendListModel
            var uid_str = ""
            for servant in (listModel?.recommend_guide_)! {
                DataManager.insertData(servant)
                uid_str += "\(servant.uid_),"
            }
            let recommendVC = RecommendServantsVC()
            recommendVC.isNormal = false
            recommendVC.appointment_id_ = self.currentApponitmentID
//            recommendVC.servantsInfo = listModel?.recommend_guide_
//            navigationController?.pushViewController(recommendVC, animated: true)
            uid_str.removeAtIndex(uid_str.endIndex.predecessor())
            let dict:Dictionary<String, AnyObject> = ["uid_str_": uid_str]
            SocketManager.sendData(.GetUserInfo, data: dict)
        }) { (error) in
        }
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cnt = 0
        if segmentIndex == 0 {
            cnt = inviteList?.count ?? 0
        } else if (segmentIndex == 1){
            cnt = appointmentList?.count ?? 0
        } else {
            cnt = centurionRecordList?.count ?? 0
        }
        footer.hidden = cnt < 10 ? true : false
        return cnt
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch segmentIndex {
        case 0://商务游(和消息中心的行程一样)
            let cell = tableView.dequeueReusableCellWithIdentifier("DistanceOfTravelCell", forIndexPath: indexPath) as! DistanceOfTravelCell
            if inviteList?.count > 0 && indexPath.row < inviteList?.count {
                cell.setHodometerInfo(inviteList![indexPath.row])
            }
            
            return cell

        case 1://预约
            let cell = tableView.dequeueReusableCellWithIdentifier("AppointmentRecordCell", forIndexPath: indexPath) as! AppointmentRecordCell
            if appointmentList?.count > 0 && indexPath.row < appointmentList?.count {
                cell.setRecordInfo(appointmentList![indexPath.row])
            }
            
            return cell

        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("CentrionCardConsumedCell", forIndexPath: indexPath) as! CentrionCardConsumedCell
            if centurionRecordList?.count > 0 && indexPath.row < centurionRecordList?.count {
                cell.setCenturionCardConsumedInfo(centurionRecordList![indexPath.row])
            }
            
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        switch segmentIndex {
        case 0:
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? DistanceOfTravelCell {
                if  cell.curHodometerInfo?.status_ == HodometerStatus.InvoiceMaking.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.InvoiceMaked.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.Completed.rawValue{
                    
                    let identDetailVC = IdentDetailVC()
                    identDetailVC.hodometerInfo = cell.curHodometerInfo!
                    navigationController?.pushViewController(identDetailVC, animated: true)
                    /**
                     *  未支付状态去支付
                     */
                } else if cell.curHodometerInfo?.status_ == HodometerStatus.WaittingPay.rawValue {
                    APIHelper.userAPI().cash({ (response) in
                        if let dict = response as? [String: AnyObject] {
                            if let cash = dict["user_cash_"] as? Int {
                                CurrentUser.user_cash_ = cash
                            }
                            if let hasPasswd = dict["has_passwd_"] as? Int {
                                CurrentUser.has_passwd_ = hasPasswd
                            }
                        }
                        }, error: nil)
                    selectedHodometerInfo = cell.curHodometerInfo
                    payForInvitationRequest()
                    
                }
            }
            break
        case 1:
            guard  appointmentList?.count > 0 else {return}
            let object = appointmentList![indexPath.row]
            guard object.status_ > 1  else {
                if object.recommend_uid_ != nil {
                    SocketManager.sendData(.AppointmentRecommendRequest, data: ["uid_str_":  object.recommend_uid_!])
                } else {
                    SVProgressHUD.showWainningMessage(WainningMessage: "此预约尚未确定服务者", ForDuration: 1.5, completion: nil)
                }
                return
            }
            if  object.status_ == HodometerStatus.InvoiceMaking.rawValue ||
                object.status_ == HodometerStatus.InvoiceMaked.rawValue ||
                object.status_ == HodometerStatus.Completed.rawValue {
                let detailVC = AppointmentDetailVC()
                detailVC.appointmentInfo = appointmentList![indexPath.row]

                navigationController?.pushViewController(detailVC, animated: true)
                /**
                 *  未支付状态去支付
                 */
            } else if object.status_ == HodometerStatus.WaittingPay.rawValue {
                APIHelper.userAPI().cash({ (response) in
                    if let dict = response as? [String: AnyObject] {
                        if let cash = dict["user_cash_"] as? Int {
                            CurrentUser.user_cash_ = cash
                        }
                        if let hasPasswd = dict["has_passwd_"] as? Int {
                            CurrentUser.has_passwd_ = hasPasswd
                        }
                    }
                    }, error: nil)
                selectedAppointmentInfo = appointmentList![indexPath.row]
                payForInvitationRequest()
                
            }
    
            break
        case 2:
            break
        default:
            break
        }
    }
    
    func segmentChange(sender: AnyObject?) {
        segmentIndex = (sender?.selectedSegmentIndex)!
        if header.state == .Idle && (footer.state == .Idle || footer.state == .NoMoreData){
            header.beginRefreshing()
        }

    }
    func endRefresh() {
        if header.state == .Refreshing {
            header.endRefreshing()
        }
        if footer.state == .Refreshing {
            footer.endRefreshing()
        }
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        refreshData()
    }
    func refreshData() {
        
        switch segmentIndex {
        case 0:
            inviteList = DataManager.getData(HodometerInfoModel.self)
            break
        case 1:
            appointmentList = DataManager.getData(AppointmentInfoModel.self)
        case 2:
            centurionRecordList = DataManager.getData(CenturionCardRecordModel.self)
            break
        default:
            break
        }
        table?.reloadData()
    }
    /**
     支付操作
     */
    func payForInvitationRequest() {
         MobClick.event(CommonDefine.BuriedPoint.payForOrder)
        if DataManager.currentUser?.has_passwd_ == -1 {
            let alert = UIAlertController.init(title: "提示", message: "您尚未设置支付密码", preferredStyle: .Alert)
            weak var weakSelf = self
            let gotoSetup = UIAlertAction.init(title: "前往设置", style: .Default, handler: { (action) in
                weakSelf?.jumpToPayPasswdVC()
            })
            let cancel = UIAlertAction.init(title: "取消", style: .Default, handler: nil)
            alert.addAction(gotoSetup)
            alert.addAction(cancel)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        guard segmentIndex != 2 else { return }
        var price = 0
        var order_id_ = 0
        if segmentIndex == 1 {
            price = (selectedAppointmentInfo?.order_price_)!
            order_id_ = (selectedAppointmentInfo?.order_id_)!

        } else {
            price =  (selectedHodometerInfo?.order_price_)!
            order_id_ = (selectedHodometerInfo?.order_id_)!
        }
        guard price>0 else{return}
        let payVc = PayVC()
        payVc.price = price
        payVc.orderId = order_id_
        payVc.segmentIndex = segmentSC!.selectedSegmentIndex
        self.navigationController?.pushViewController(payVc, animated: true)
        
//        let msg = "\n您即将预支付人民币:\(Double(price)/100)元"
//        
//        
//        let alert = UIAlertController.init(title: "付款确认", message: msg, preferredStyle: .Alert)
//        
//        alert.addTextFieldWithConfigurationHandler({ (textField) in
//            textField.placeholder = "请输入支付密码"
//            textField.secureTextEntry = true
//        })
//        
//        let ok = UIAlertAction.init(title: "确认付款", style: .Default, handler: { (action) in
//            var errMsg = ""
//            let passwd = alert.textFields?.first?.text
//            if passwd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
//                errMsg = "请输入支付密码"
//            }
//            if errMsg.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
//                let warningAlert = UIAlertController.init(title: "提示", message: errMsg, preferredStyle: .Alert)
//                let sure = UIAlertAction.init(title: "好的", style: .Cancel, handler: { (action) in
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.15)), dispatch_get_main_queue(), { () in
//                        weakSelf!.payForInvitationRequest()
//                    })
//                })
//                warningAlert.addAction(sure)
//                weakSelf!.presentViewController(warningAlert, animated: true, completion: nil)
//            } else {
//                if DataManager.currentUser?.cash < price {
//                    weakSelf!.moneyIsTooLess()
//                } else {
//                    let dict:[String: AnyObject] = ["uid_": (CurrentUser.uid_)!,
//                                                    "order_id_": order_id_,
//                                                    "passwd_": passwd!]
//                    SocketManager.sendData(.PayForInvitationRequest, data: dict)
//                }
//                
//            }
//            
//        })
//        
//        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
//        
//        alert.addAction(ok)
//        alert.addAction(cancel)
//        
//        presentViewController(alert, animated: true, completion: nil)
//    }
//    /**
//     余额不足操作
//     */
//    func moneyIsTooLess() {
//        let alert = UIAlertController.init(title: "余额不足", message: "\n请前往充值", preferredStyle: .Alert)
//        
//        let ok = UIAlertAction.init(title: "前往充值", style: .Default, handler: { (action: UIAlertAction) in
//            let rechargeVC = RechargeVC()
//            self.navigationController?.pushViewController(rechargeVC, animated: true)
//        })
//        
//        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
//        
//        alert.addAction(ok)
//        alert.addAction(cancel)
//        
//        presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     跳转到设置支付密码界面
     */
    func jumpToPayPasswdVC() {
        let payPasswdVC = PayPasswdVC()
        payPasswdVC.payPasswdStatus = PayPasswdStatus(rawValue: (DataManager.currentUser?.has_passwd_)!)!
        navigationController?.pushViewController(payPasswdVC, animated: true)
    }
    
    deinit {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
