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

class PushMessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var segmentSC:UISegmentedControl?
    var table:UITableView?
    var messageInfo:Array<UserInfo>? = []
    var segmentIndex = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "消息中心"
        
        initView()
        
        registerNotify()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        table?.reloadData()
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushMessageVC.chatMessage(_:)), name: NotifyDefine.ChatMessgaeNotiy, object: nil)
    }
    
    func chatMessage(notification: NSNotification?) {
        let data = (notification?.userInfo!["data"])! as! Dictionary<String, AnyObject>
        
    }
    
    func initView() {let segmentBGV = UIImageView()
        segmentBGV.image = UIImage.init(named: "head-bg")?.imageWithAlignmentRectInsets(UIEdgeInsetsMake(128, 0, 0, 0))
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
        segmentSC!.selectedSegmentIndex = 0
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
        
    }
    
    func segmentChange(sender: UISegmentedControl?) {
        segmentIndex = (sender?.selectedSegmentIndex)!
        table?.reloadData()
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentIndex == 0 ? DataManager.getMessageCount(-1) : 15
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentIndex == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            let realm = try! Realm()
            let userPushMessage = realm.objects(UserPushMessage.self)[indexPath.row]
            cell.setInfo(userPushMessage.msgList.last, unreadCnt: userPushMessage.unread)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("DistanceOfTravelCell", forIndexPath: indexPath) as! DistanceOfTravelCell
            cell.setInfo(nil)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MessageCell {
            DataManager.readMessage(cell.userInfo!.uid)
            let realm = try! Realm()
            let userPushMessage = realm.objects(UserPushMessage.self)[indexPath.row]
            let chatVC = ChatVC()
            chatVC.servantInfo = DataManager.getUserInfo(userPushMessage.uid)
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


