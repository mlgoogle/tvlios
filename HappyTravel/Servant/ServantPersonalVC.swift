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

public class ServantPersonalVC : UIViewController, UITableViewDelegate, UITableViewDataSource, ServiceCellDelegate, PhotosCellDelegate, ServiceSheetDelegate {
    //记录是邀约？预约？   ture为邀约  false 为预约
    var isNormal = true
    
    var personalInfo:UserInfo?
    var personalTable:UITableView?
    var bottomBar:UIImageView?
    var serviceSpread = true
    var invitaionVC = InvitationVC()
    var alertController:UIAlertController?
    var appointment_id_ = 0
    
    var daysAlertController:UIAlertController?
    
    var selectedServcie:ServiceInfo?
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    func initView() {
        view.backgroundColor = UIColor.init(red: 33/255.0, green: 59/255.0, blue: 76/255.0, alpha: 1)
        title = personalInfo?.nickname
        
        bottomBar = UIImageView()
        bottomBar?.userInteractionEnabled = true
        bottomBar?.image = UIImage.init(named: "bottom-selector-bg")
        view.addSubview(bottomBar!)
        bottomBar?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(50)
        })
        
        let chatBtn = UIButton()
        chatBtn.tag = 1001
        chatBtn.setTitle("开始聊天", forState: .Normal)
        chatBtn.backgroundColor = UIColor.clearColor()
        chatBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        chatBtn.addTarget(self, action: #selector(ServantPersonalVC.bottomBarAction(_:)), forControlEvents: .TouchUpInside)
        bottomBar?.addSubview(chatBtn)
        chatBtn.snp_makeConstraints { (make) in
            make.left.equalTo(bottomBar!)
            make.top.equalTo(bottomBar!)
            make.bottom.equalTo(bottomBar!)
            make.right.equalTo(bottomBar!.snp_centerX)
        }
        let invitationBtn = UIButton()
        invitationBtn.tag = 1002
        invitationBtn.setTitle( isNormal ? "发起邀约" : "发起预约", forState: .Normal)
        invitationBtn.backgroundColor = UIColor.clearColor()
        invitationBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        invitationBtn.addTarget(self, action: #selector(ServantPersonalVC.bottomBarAction(_:)), forControlEvents: .TouchUpInside)
        bottomBar?.addSubview(invitationBtn)
        invitationBtn.snp_makeConstraints { (make) in
            make.right.equalTo(bottomBar!)
            make.top.equalTo(bottomBar!)
            make.bottom.equalTo(bottomBar!)
            make.left.equalTo(bottomBar!.snp_centerX)
        }
        
        personalTable = UITableView(frame: CGRectZero, style: .Plain)
        personalTable!.registerClass(PersonalHeadCell.self, forCellReuseIdentifier: "PersonalHeadCell")
        personalTable!.registerClass(TallyCell.self, forCellReuseIdentifier: "TallyCell")
        personalTable!.registerClass(ServiceCell.self, forCellReuseIdentifier: "ServiceCell")
        personalTable!.registerClass(PhotosCell.self, forCellReuseIdentifier: "PhotosCell")
        personalTable!.tag = 1001
        personalTable!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        personalTable!.dataSource = self
        personalTable!.delegate = self
        personalTable!.estimatedRowHeight = 400
        personalTable!.rowHeight = UITableViewAutomaticDimension
        personalTable!.separatorStyle = .None
        personalTable!.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        view.addSubview(personalTable!)
        personalTable!.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(bottomBar!.snp_top)
        }
        
    }
    
    /**
     下面沟通 或者 邀约操作
     
     - parameter sender:
     */
    func bottomBarAction(sender: UIButton?) {
        if DataManager.currentUser?.cash == 0 {
            let alert = UIAlertController.init(title: "余额不足", message: "服务者的最低价格为1000元，还需充值200元", preferredStyle: .Alert)
            
            let ok = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                XCGLogger.debug("去充值")
                
                let rechargeVC = RechargeVC()
                self.navigationController?.pushViewController(rechargeVC, animated: true)
                DataManager.currentUser?.cash = 10
                
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
                
            })
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            presentViewController(alert, animated: true, completion: { 
                
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
            alertController = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
            let sheet = ServiceSheet()
            sheet.servantInfo = personalInfo
            sheet.isNormal = isNormal
            sheet.delegate = self
            alertController!.view.addSubview(sheet)
            sheet.snp_makeConstraints { (make) in
                make.left.equalTo(alertController!.view).offset(-10)
                make.right.equalTo(alertController!.view).offset(10)
                make.bottom.equalTo(alertController!.view).offset(10)
                make.top.equalTo(alertController!.view).offset(-10)
            }
        }
        
        presentViewController(alertController!, animated: true, completion: nil)
        
        
    }
    
    // MARK: - ServiceSheetDelegate
    func cancelAction(sender: UIButton?) {
        alertController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     邀约或者预约确定
     
     - parameter service:
     - parameter daysCount:
     */
    func sureAction(service: ServiceInfo?, daysCount: Int?) {
    
        if !isNormal {
            
            alertController?.dismissViewControllerAnimated(true, completion: nil)
            SocketManager.sendData(.AppointmentServantRequest, data: ["from_uid_": DataManager.currentUser!.uid,
                "to_uid_": personalInfo!.uid,
                "service_id_": service!.service_id_,
                "appointment_id_":appointment_id_])

        } else {
            unowned let weakSelf = self
            weakSelf.selectedServcie = service

            alertController?.dismissViewControllerAnimated(true, completion: {
                
                weakSelf.performSelector(#selector(ServantPersonalVC.inviteAction), withObject: nil, afterDelay: 0.2)
                
                
            })
        }

    }
    

    func inviteAction() {
        unowned let weakSelf = self
        if daysAlertController == nil {
            daysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
            let sheet = CitysSelectorSheet()
            let days = [1, 2, 3, 4, 5, 6, 7]
           sheet.daysList = days
            sheet.delegate = self
            daysAlertController!.view.addSubview(sheet)
            sheet.snp_makeConstraints { (make) in
                make.left.equalTo(weakSelf.daysAlertController!.view).offset(-10)
                make.right.equalTo(weakSelf.daysAlertController!.view).offset(10)
                make.bottom.equalTo(weakSelf.daysAlertController!.view).offset(10)
                make.top.equalTo(weakSelf.daysAlertController!.view)
            }
        }
        
        presentViewController(weakSelf.daysAlertController!, animated: true, completion: nil)
    }
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ServantPersonalVC.invitationResult(_:)), name: NotifyDefine.AskInvitationResult, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ServantPersonalVC.receivedResults(_:)), name: NotifyDefine.AppointmentServantReply, object: nil)
        
    }
    
    /**
     预约回调
     
     - parameter notifucation:
     */
    func receivedResults(notifucation: NSNotification?) {
        
        let dict = notifucation?.userInfo!["data"] as? Dictionary<String , AnyObject>
        
        var msg = "预约发起成功，等待对方接受邀请"
        if dict!["is_asked_"] as! Int == 1 {
            msg = "预约失败，您已经预约过对方"

        }
        
        let alert = UIAlertController.init(title: "预约状态",
                                           message: msg,
                                           preferredStyle: .Alert)
        

        let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
            
        })
        
        alert.addAction(action)

        presentViewController(alert, animated: true) {
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
    func invitationResult(notifucation: NSNotification?) {
        var msg = ""
        if let err = SocketManager.getErrorCode((notifucation?.userInfo as? [String: AnyObject])!) {
            switch err {
            case .NoOrder:
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
                                               preferredStyle: .Alert)
            
            let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                
            })
            
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        personalTable!.reloadData()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        guard isNormal else { return }
        if navigationItem.rightBarButtonItem == nil {
            let msgItem = UIBarButtonItem.init(image: UIImage.init(named: "nav-msg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ServantPersonalVC.msgAction(_:)))
            navigationItem.rightBarButtonItem = msgItem
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    /**
    push to 聊天页面
     - parameter sender:
     */
    func msgAction(sender: AnyObject?) {
        let msgVC = PushMessageVC()
//        msgVC.messageInfo = recommendServants
        
        if sender?.isKindOfClass(UIButton) == false {
            navigationController?.pushViewController(msgVC, animated: false)
            if let userInfo = sender as? [NSObject: AnyObject] {
                let type = userInfo["type"] as? Int
                if type == PushMessage.MessageType.Chat.rawValue {
                    performSelector(#selector(ForthwithVC.postPushMessageNotify(_:)), withObject: userInfo["data"], afterDelay: 0.5)
                }
            }
            
        } else {
            navigationController?.pushViewController(msgVC, animated: true)
        }
        
    }
    
    // MARK -- UITableViewDelegate & UITableViewDataSource
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PersonalHeadCell", forIndexPath: indexPath) as! PersonalHeadCell
            cell.setInfo(personalInfo, detailInfo: nil)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TallyCell", forIndexPath: indexPath) as! TallyCell
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCell", forIndexPath: indexPath) as! ServiceCell
            cell.delegate = self
            cell.setInfo(personalInfo!.serviceList, setSpread: serviceSpread)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotosCell", forIndexPath: indexPath) as! PhotosCell
            cell.delegate = self
            cell.setInfo(personalInfo!.photoUrlList, setSpread: serviceSpread)
            return cell
        }
        
    }
    
    // MARK ServiceCellDelegate
    func spreadAction(sender: AnyObject?) {
        let cell =  sender as! ServiceCell
        let indexPath = personalTable?.indexPathForCell(cell)
        serviceSpread = !cell.spread
        personalTable?.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
    }
}


extension ServantPersonalVC:CitysSelectorSheetDelegate {
    func daysSureAction(sender: UIButton?, targetDays: Int) {
        daysAlertController?.dismissViewControllerAnimated(true, completion: nil)

        SocketManager.sendData(.AskInvitation, data: ["from_uid_": DataManager.currentUser!.uid,
                                          "to_uid_": personalInfo!.uid,
                                      "service_id_": selectedServcie!.service_id_,
                                    "day_count_":targetDays])
    }
    
    func daysCancelAction(sender: UIButton?) {
        
        daysAlertController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

