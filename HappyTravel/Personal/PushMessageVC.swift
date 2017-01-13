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


class PushMessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource,RefreshChatSessionListDelegate{
    
    var currentAppointmentId = 0
    var segmentSC:UISegmentedControl?
    var selectedIndex = 0
    var table:UITableView?
    var servantsArray:Array<UserInfoModel>? = []
    var segmentIndex = 0
    var orderID = 0
    var hotometers:Results<HodometerInfoModel>?
    var timer:NSTimer?
    var isFirstTime = true
    var requestCount = 0
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "消息中心"
        ChatMessageHelper.shared.refreshDelegate = self
        initView()
        segmentChange(segmentSC)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(chatMessage(_:)), name: NotifyDefine.ChatMessgaeNotiy, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pushMessageNotify(_:)), name: NotifyDefine.PushMessageNotify, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushMessageVC.obtainTripReply(_:)), name: NotifyDefine.ObtainTripReply, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushMessageVC.receivedAppoinmentRecommendServants(_:)), name: NotifyDefine.AppointmentRecommendReply, object: nil)

    }
    
//    func receivedAppoinmentRecommendServants(notification:NSNotification?) {
//        
//        if let data = notification?.userInfo!["data"] as? Dictionary<String, AnyObject> {
//            servantsArray?.removeAll()
//        
//            if let servants = data["recommend_guide_"] as? Array<Dictionary<String, AnyObject>> {
//                var uid_str = ""
//                for servant in servants {
////                    let servantInfo = UserInfo()
////                    servantInfo.setInfo(.Servant, info: servant)
////                    servantsArray?.append(servantInfo)
////                    uid_str += "\(servantInfo.uid),"
//                    
//                }
//                let recommendVC = RecommendServantsVC()
//                recommendVC.isNormal = false
//                recommendVC.appointment_id_ = currentAppointmentId
////                recommendVC.servantsInfo = servantsArray
//                navigationController?.pushViewController(recommendVC, animated: true)
//                uid_str.removeAtIndex(uid_str.endIndex.predecessor())
//                let dict:Dictionary<String, AnyObject> = ["uid_str_": uid_str]
//                SocketManager.sendData(.GetUserInfo, data: dict)
//            }
//           
//        }
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushMessageVC.obtainTripReply(_:)), name: NotifyDefine.ObtainTripReply, object: nil)
//    }
    
    
    func allEndRefreshing() {
        if header.state == MJRefreshState.Refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.Refreshing {
            footer.endRefreshing()
        }
        

    }
    
//    func obtainTripReply(notification: NSNotification) {
//        
//        allEndRefreshing()
//        let realm = try! Realm()
//        hotometers = realm.objects(HodometerInfo.self).filter("order_id_ != 0").sorted("start_", ascending: false)
//        
//        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
//        if lastOrderID == -1001 {
//            footer.state = .NoMoreData
//            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
//            return
//        }
//        orderID = lastOrderID
//        table?.reloadData()
//    }
    func requestRecommendListWithUidStr(uid_str_:String) {
        let model = AppointmentRecommendRequestModel()
        model.uid_str_ = uid_str_
        APIHelper.consumeAPI().requestAppointmentRecommendList(model, complete: { (response) in
            let list = response as? Array<UserInfoModel>
            var uid_str = ""
            self.servantsArray?.removeAll()
            guard list?.count > 0 else {return}
            for servant in list! {
                self.servantsArray?.append(servant)
                uid_str += "\(servant.uid_),"
                self.requestDetaiInfo(servant.uid_)
            }
            //            uid_str.removeAtIndex(uid_str.endIndex.predecessor())
            //            self.requestUserInfoByIDStr(uid_str)
        }) { (error) in
        }
    }
    func requestDetaiInfo(uid:Int) {
        
        let model = UserBaseModel()
        model.uid_ = uid
        APIHelper.servantAPI().servantDetail(model, complete: { (response) in
            self.requestCount += 1
            if self.requestCount == self.servantsArray?.count {
                let recommendVC = RecommendServantsVC()
                recommendVC.isNormal = false
                recommendVC.appointment_id_ = self.currentAppointmentId
                recommendVC.servantsInfo = self.servantsArray
                self.navigationController?.pushViewController(recommendVC, animated: true)
            }
            let info = response as? ServantDetailModel
            guard info != nil else {return}
            DataManager.insertData(info!)
        }) { (error) in
        }
        
    }
    func chatMessage(notification: NSNotification?) {
//        let data = (notification?.userInfo!["data"])! as! Dictionary<String, AnyObject>
        table?.reloadData()
        
    }
    
    func pushMessageNotify(notification: NSNotification) {
        if let dict = notification.userInfo as? Dictionary<String, AnyObject> {
            if let msg = dict["data"] as? Dictionary<String, AnyObject> {
                let chatVC = ChatVC()
                chatVC.servantInfo = DataManager.getData(UserInfoModel.self, filter: "uid_ = \(msg["from_uid_"] as! Int)")?.first
                navigationController?.pushViewController(chatVC, animated: true)
            }
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
        
        let segmentItems = ["消息", "行程"]
        segmentSC = UISegmentedControl(items: segmentItems)
        segmentSC!.tag = 1001
        segmentSC!.addTarget(self, action: #selector(PushMessageVC.segmentChange), forControlEvents: UIControlEvents.ValueChanged)
        segmentSC!.selectedSegmentIndex = selectedIndex
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
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0)
        }
    
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        table?.registerClass(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(segmentBGV.snp_bottom)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(PushMessageVC.headerRefresh))
        table?.mj_header = header
        footer.hidden = true
        footer.setRefreshingTarget(self, refreshingAction: #selector(PushMessageVC.footerRefresh))
        table?.mj_footer = footer
        
    }
    func handleInviteOrderRequest(isRefresh:Bool) {
        let model = HodometerRequestModel()
        model.order_id_ = isRefresh ? 0 : orderID
        APIHelper.consumeAPI().requestInviteOrderLsit(model, complete: { (response) in
            self.hotometers = DataManager.getData(HodometerInfoModel.self)!.filter("order_id_ != 0").sorted("start_", ascending: false)
            if let models = response as? [HodometerInfoModel] {
                DataManager.insertDatas(models)
                self.orderID = models.last!.order_id_
            } else {
                self.noMoreData()
            }
            self.endRefresh()
        }) { (error) in
            self.noMoreData()
        }
    }
    func headerRefresh() {
        if segmentIndex == 0 {
            header.endRefreshing()
            table?.reloadData()
        } else if segmentIndex == 1 {
            handleInviteOrderRequest(true)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(PushMessageVC.endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    func endRefresh() {
        
        isFirstTime = false
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
        table?.reloadData()
    }
    func noMoreData() {
        endRefresh()
        footer.state = .NoMoreData
        footer.setTitle("没有更多信息", forState: .NoMoreData)
    }
    func footerRefresh() {
        if segmentIndex == 0 {
            footer.endRefreshing()
        } else if segmentIndex == 1 {
            handleInviteOrderRequest(false)

        }
        
    }
    
    func segmentChange(sender: UISegmentedControl?) {
        allEndRefreshing()
        segmentIndex = (sender?.selectedSegmentIndex)!
        if segmentIndex == 0 {

            if !isFirstTime {
                header.beginRefreshing()
                performSelector(#selector(PushMessageVC.allEndRefreshing), withObject: nil, afterDelay: 1.5)
            }
//            header.hidden = true
            footer.hidden = true
        } else if segmentIndex == 1 {
            header.hidden = false
            footer.hidden = false
            header.beginRefreshing()
        }
        
        table?.reloadData()

    }
    // MARK: - RefreshChatSessionListDelegate
    func refreshChatSeesionList() {
        if segmentIndex == 0 {
            table?.reloadData()
        }
    }

    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentIndex == 0 ? DataManager.getData(ChatSessionModel.self)!.sorted("msg_time_", ascending: false).count : (hotometers?.count ?? 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentIndex == 0 {
            //消息
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            let userPushMessage = DataManager.getData(ChatSessionModel.self)!.sorted("msg_time_", ascending: false)[indexPath.row]
            cell.setInfo(userPushMessage.msgList.last, unreadCnt: userPushMessage.unread_)
            return cell
        } else {
            //行程(和我的消费中商务游相同)
            let cell = tableView.dequeueReusableCellWithIdentifier("DistanceOfTravelCell", forIndexPath: indexPath) as! DistanceOfTravelCell
            cell.setHodometerInfo(hotometers![indexPath.row])
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if segmentIndex == 0 {
            let userPushMessage = DataManager.getData(ChatSessionModel.self)!.sorted("msg_time_", ascending: false)[indexPath.row]
            
            let message = userPushMessage.msgList.last
            if message?.push_msg_type_ == 2231 {
                let uid_str_ = message?.servant_id_
                currentAppointmentId = (message?.appointment_id_)!
                if uid_str_ != nil  {
                    requestRecommendListWithUidStr(uid_str_!)
                } else {
                    XCGLogger.error("推送服务者id 为空")
                }
                DataManager.readMessage(currentAppointmentId)

                return

            }
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MessageCell {
                let chatVC = ChatVC()
                chatVC.servantInfo = DataManager.getData(UserInfoModel.self, filter: "uid_ = \(cell.userInfo!.uid_)")?.first
                navigationController?.pushViewController(chatVC, animated: true)
                DataManager.readMessage((cell.userInfo?.uid_)!)

            }
        } else if segmentIndex == 1 {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? DistanceOfTravelCell {
                let status = cell.curHodometerInfo?.status_
                if cell.curHodometerInfo?.status_ == HodometerStatus.InvoiceMaking.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.InvoiceMaked.rawValue ||
                    cell.curHodometerInfo?.status_ == HodometerStatus.Completed.rawValue {
                    let identDetailVC = IdentDetailVC()
                    identDetailVC.hodometerInfo = cell.curHodometerInfo!
                    navigationController?.pushViewController(identDetailVC, animated: true)
                } else if status == HodometerStatus.WaittingPay.rawValue {
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
                    payForInvitationRequest(cell.curHodometerInfo)
                }
                
            }
        }
        
    }
    
    /**
     跳转到设置支付密码界面
     */
    func jumpToPayPasswdVC() {
        let payPasswdVC = PayPasswdVC()
        payPasswdVC.payPasswdStatus = PayPasswdStatus(rawValue: CurrentUser.has_passwd_)!
        navigationController?.pushViewController(payPasswdVC, animated: true)
    }
    
    func payForInvitationRequest(info: HodometerInfoModel?) {
         MobClick.event(CommonDefine.BuriedPoint.payForOrder)
        if CurrentUser.has_passwd_ == -1 {
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
        
        guard info != nil else {return}

        let payVc = PayVC()
        payVc.price = info?.order_price_
        payVc.orderId = info?.order_id_
        payVc.segmentIndex = segmentSC!.selectedSegmentIndex
        self.navigationController?.pushViewController(payVc, animated: true)

    }
    
    func moneyIsTooLess() {
        MobClick.event(CommonDefine.BuriedPoint.payForOrderFail)

        let alert = UIAlertController.init(title: "余额不足", message: "\n请前往充值", preferredStyle: .Alert)
        
        let ok = UIAlertAction.init(title: "前往充值", style: .Default, handler: { (action: UIAlertAction) in
            let rechargeVC = RechargeVC()
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

