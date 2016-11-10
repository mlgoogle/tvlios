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

class DistanceOfTravelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var segmentSC:UISegmentedControl?
    var table:UITableView?
    var messageInfo:Array<UserInfo>? = []
    var segmentIndex = 0
    
    var orderID = 0
    var hotometers:Results<HodometerInfo>?
    
    var consumedOrderID = 0
    var consumes:Results<CenturionCardConsumedInfo>?
    var records:Results<AppointmentInfo>?
    var lastRecordId = 0
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "我的消费"
        
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        header.beginRefreshing()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.obtainTripReply(_:)), name: NotifyDefine.ObtainTripReply, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.centurionCardConsumedReply(_:)), name: NotifyDefine.CenturionCardConsumedReply, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DistanceOfTravelVC.receivedAppointmentInfos(_:)), name: NotifyDefine.AppointmentRecordReply, object: nil)
    }
    
    func obtainTripReply(notification: NSNotification) {
        if header.state == MJRefreshState.Refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.Refreshing {
            footer.endRefreshing()
        }
        
        let realm = try! Realm()
        hotometers = realm.objects(HodometerInfo.self).sorted("start_", ascending: false)
        
        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .NoMoreData
            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
            table?.reloadData()
            return
        }
        orderID = lastOrderID
        table?.reloadData()
    }
    
    func centurionCardConsumedReply(notification: NSNotification) {
        if header.state == MJRefreshState.Refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.Refreshing {
            footer.endRefreshing()
        }
        
        let realm = try! Realm()
        consumes = realm.objects(CenturionCardConsumedInfo.self).sorted("order_id_", ascending: false)
        
        let lastOrderID = notification.userInfo!["lastOrderID"] as! Int
        if lastOrderID == -1001 {
            footer.state = .NoMoreData
            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
            table?.reloadData()
            return
        }
        consumedOrderID = lastOrderID
        table?.reloadData()
    }
    func receivedAppointmentInfos(notification:NSNotification) {
        
        if header.state == MJRefreshState.Refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.Refreshing {
            footer.endRefreshing()
        }
        let realm = try! Realm()
        records = realm.objects(AppointmentInfo.self).sorted("appointment_id_", ascending: false)
        let lastID = notification.userInfo!["lastID"] as! Int
        if lastID == -9999 {
            footer.state = .NoMoreData
            footer.setTitle("多乎哉 不多矣", forState: .NoMoreData)
            table?.reloadData()
            return
        }
        lastRecordId = lastID
        table?.reloadData()
        
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
        table?.registerClass(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        table?.registerClass(CentrionCardConsumedCell.self, forCellReuseIdentifier: "CentrionCardConsumedCell")
        table?.registerClass(AppointmentRecordCell.self, forCellReuseIdentifier: "AppointmentRecordCell")
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
            SocketManager.sendData(.ObtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                "order_id_": 0,
                "count_": 10])
            break
        case 1:
            SocketManager.sendData(.AppointmentRecordRequest, data: ["uid_": DataManager.currentUser!.uid,
                "last_id_": 0,
                "count_": 10])
            break
        case 2:
            SocketManager.sendData(.CenturionCardConsumedRequest, data: ["uid_": DataManager.currentUser!.uid])
            break
        default:
            break
        }
        
    }
    
    func footerRefresh() {
        switch segmentIndex {
        case 0:
            SocketManager.sendData(.ObtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                "order_id_": orderID,
                "count_": 10])
            break
        case 1:
            SocketManager.sendData(.AppointmentRecordRequest, data: ["uid_": DataManager.currentUser!.uid,
                "last_id_": lastRecordId,
                "count_": 10])
            break
        case 2:
            SocketManager.sendData(.CenturionCardConsumedRequest, data: ["uid_": DataManager.currentUser!.uid])
            break
        default:
            break
        }
        
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cnt = 0
        if segmentIndex == 0 {
            cnt = hotometers != nil ? hotometers!.count : 0
        } else if (segmentIndex == 1){
            cnt = records != nil ? records!.count : 0
        } else {
            cnt = consumes != nil ? consumes!.count : 0
        }
        footer.hidden = cnt < 10 ? true : false
        return cnt
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch segmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("DistanceOfTravelCell", forIndexPath: indexPath) as! DistanceOfTravelCell
            cell.setHodometerInfo(hotometers![indexPath.row])
            return cell

        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("AppointmentRecordCell", forIndexPath: indexPath) as! AppointmentRecordCell
            cell.setRecordInfo(records![indexPath.row])
            return cell

        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("CentrionCardConsumedCell", forIndexPath: indexPath) as! CentrionCardConsumedCell
            cell.setCenturionCardConsumedInfo(consumes![indexPath.row])
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
            if cell.curHodometerInfo?.status_ == HodometerStatus.Paid.rawValue ||
            cell.curHodometerInfo?.status_ == HodometerStatus.InvoiceMaking.rawValue ||
            cell.curHodometerInfo?.status_ == HodometerStatus.InvoiceMaked.rawValue{

                let identDetailVC = IdentDetailVC()
                identDetailVC.hodometerInfo = cell.curHodometerInfo!
                navigationController?.pushViewController(identDetailVC, animated: true)
            }
        }
            break
        case 1:
            let detailVC = AppointmentDetailVC()
            detailVC.appointmentInfo = records![indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
            break
        case 2:
            break
        default:
            break

        }
    }
    
    func segmentChange(sender: AnyObject?) {
        segmentIndex = (sender?.selectedSegmentIndex)!
        header.beginRefreshing()

    }
    
}
