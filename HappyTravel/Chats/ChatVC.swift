//
//  ChatVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/3.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import MJRefresh

public class ChatVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ServiceSheetDelegate {
    
    var dateFormatter = NSDateFormatter()
    var messages:Array<Message> = []
    var chatTable:UITableView?
    var toolBar: UIToolbar!
    var textView: UITextView!
    var sendButton: UIButton!
    var faceButton: UIButton!
    var rotating = false
    var invitaionVC = InvitationVC()
    var alertController:UIAlertController?
    var servantInfo:UserInfo?
    var msgList:List<PushMessage>?
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    
    override public var inputAccessoryView: UIView! {
        get {
            if toolBar == nil {
                toolBar = UIToolbar(frame: CGRectMake(0, 0, 0, 44-0.5))
                toolBar.backgroundColor = colorWithHexString("#f2f2f2")
                faceButton = UIButton(type: .Custom)
                faceButton.setBackgroundImage(UIImage.init(named: "face-btn"), forState: .Normal)
                faceButton.addTarget(self, action: #selector(ChatVC.sendMessageAction), forControlEvents: UIControlEvents.TouchUpInside)
                toolBar.addSubview(faceButton)
                faceButton.translatesAutoresizingMaskIntoConstraints = false
                faceButton.snp_makeConstraints(closure: { (make) in
                    make.top.equalTo(toolBar).offset(5)
                    make.left.equalTo(toolBar).offset(5)
                    make.bottom.equalTo(toolBar).offset(-5)
                    make.width.equalTo(32)
                })
                
                sendButton = UIButton(type: .System)
                sendButton.enabled = false
                sendButton.titleLabel?.font = UIFont.systemFontOfSize(S18)
                sendButton.layer.cornerRadius = 5
                sendButton.layer.masksToBounds = true
                sendButton.backgroundColor = UIColor.init(red: 20/255, green: 31/255, blue: 49/255, alpha: 1)
                sendButton.setTitle("发送", forState: .Normal)
                sendButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
                sendButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                sendButton.addTarget(self, action: #selector(ChatVC.sendMessageAction), forControlEvents: UIControlEvents.TouchUpInside)
                toolBar.addSubview(sendButton)
                sendButton.translatesAutoresizingMaskIntoConstraints = false
                sendButton.snp_makeConstraints(closure: { (make) in
                    make.top.equalTo(toolBar).offset(5)
                    make.right.equalTo(toolBar).offset(-5)
                    make.bottom.equalTo(toolBar).offset(-5)
                    make.width.equalTo(80)
                })
                
                textView = InputTextView(frame: CGRectZero)
                textView.backgroundColor = UIColor(white: 250/255, alpha: 1)
                textView.delegate = self
                textView.font = UIFont.systemFontOfSize(S18)
                textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
                textView.layer.borderWidth = 0.5
                textView.layer.cornerRadius = 5
                textView.scrollsToTop = false
                textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
                toolBar.addSubview(textView)
                textView.translatesAutoresizingMaskIntoConstraints = false
                textView.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(faceButton.snp_right).offset(5)
                    make.right.equalTo(sendButton.snp_left).offset(-5)
                    make.bottom.equalTo(toolBar).offset(-5)
                    make.top.equalTo(toolBar).offset(5)
                })

            }
            return toolBar
        }
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = servantInfo?.nickname
        view.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)

        msgList = DataManager.getMessage(servantInfo!.uid)?.msgList
        
        initView()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        if navigationItem.rightBarButtonItem == nil {
            let msgItem = UIBarButtonItem.init(title: "立即邀约", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChatVC.invitationAction(_:)))
            navigationItem.rightBarButtonItem = msgItem
        }
        
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if msgList != nil {
            chatTable!.scrollToRowAtIndexPath(NSIndexPath.init(forRow: msgList!.count-1, inSection: 0), atScrollPosition: .Bottom, animated: false)
        }
        let unreadCntBefore = DataManager.getUnreadMsgCnt(-1)
        DataManager.readMessage(servantInfo!.uid)
        let unreadCntLater = DataManager.getUnreadMsgCnt(-1)
        var readCnt = unreadCntBefore - unreadCntLater
        if readCnt == unreadCntBefore {
            readCnt = -1
        }
        SocketManager.sendData(.FeedbackMSGReadCnt, data: ["uid_": servantInfo!.uid, "count_": readCnt])
        UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCntLater
        
    }
    
    func registerNotify() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(ChatVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatVC.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatVC.menuControllerWillHide(_:)), name: UIMenuControllerWillHideMenuNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatVC.chatMessage(_:)), name: NotifyDefine.UpdateChatVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatVC.invitationResult(_:)), name: NotifyDefine.AskInvitationResult, object: nil)
        
    }
    
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
    
    func chatMessage(notification: NSNotification?) {
        let msg = (notification?.userInfo!["data"])! as! PushMessage
        if msg.from_uid_ == servantInfo?.uid && msg.to_uid_ == DataManager.currentUser!.uid {
            chatTable?.beginUpdates()
            let numberOfRows = chatTable?.numberOfRowsInSection(0)
            chatTable?.insertRowsAtIndexPaths([NSIndexPath.init(forRow: numberOfRows!, inSection: 0), NSIndexPath.init(forRow: numberOfRows!, inSection: 0)], withRowAnimation: .Fade)
            chatTable?.endUpdates()
            chatTable?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: numberOfRows!, inSection: 0), atScrollPosition: .Bottom, animated: true)
            DataManager.readMessage(msg.from_uid_)
        }
        
    }
    
    func invitationAction(sender: UIButton?) {
        invitation()
    }
    
    func invitation() {
        textView.resignFirstResponder()
        if alertController == nil {
            alertController = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
            let sheet = ServiceSheet()
            sheet.servantInfo = DataManager.getUserInfo(servantInfo!.uid)
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
    
    func sureAction(service: ServiceInfo?) {
        alertController?.dismissViewControllerAnimated(true, completion: nil)
        
        SocketManager.sendData(.AskInvitation, data: ["from_uid_": DataManager.currentUser!.uid,
                                                      "to_uid_": servantInfo!.uid,
                                                      "service_id_": service!.service_id_])
    }
    
    public func textViewDidChange(textView: UITextView) {
        sendButton.enabled = textView.hasText()
    }
    
    func initView() {
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle

        let rect = view.bounds
        chatTable = UITableView(frame: rect, style: .Plain)
        chatTable!.tag = 1001
        chatTable?.backgroundColor = UIColor.clearColor()
        chatTable!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        chatTable!.dataSource = self
        chatTable!.delegate = self
        chatTable!.keyboardDismissMode = .Interactive
        chatTable!.estimatedRowHeight = 44
        chatTable!.separatorStyle = .None
        chatTable!.registerClass(ChatDateCell.self, forCellReuseIdentifier: "ChatDateCell")
        chatTable!.registerClass(ChatBubbleCell.self, forCellReuseIdentifier: "ChatBubbleCell")
        view.addSubview(chatTable!)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(ChatVC.headerRefresh))
        chatTable?.mj_header = header

    }
    
    func headerRefresh() {
        
        
        performSelector(#selector(ChatVC.endRefresh), withObject: nil, afterDelay: 5)
    }
    
    func endRefresh() {
        header.endRefreshing()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let insetNewBottom = chatTable!.convertRect(frameNew, fromView: nil).height
        let insetOld = chatTable!.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = chatTable!.contentSize.height - (chatTable!.frame.height-insetOld.top-insetOld.bottom)
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.chatTable!.tracking || self.chatTable!.decelerating) {
                // Move content with keyboard
                if overflow > 0 {                   // scrollable before
                    self.chatTable!.contentOffset.y += insetChange
                    if self.chatTable!.contentOffset.y < -insetOld.top {
                        self.chatTable!.contentOffset.y = -insetOld.top
                    }
                } else if insetChange > -overflow { // scrollable after
                    self.chatTable!.contentOffset.y += insetChange + overflow
                }
            }
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16)) // http://stackoverflow.com/a/18873820/242933
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let insetNewBottom = chatTable!.convertRect(frameNew, fromView: nil).height
        
        // Inset `tableView` with keyboard
        let contentOffsetY = chatTable!.contentOffset.y
        chatTable!.contentInset.bottom = insetNewBottom
        chatTable!.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if chatTable!.tracking || chatTable!.decelerating {
            chatTable!.contentOffset.y = contentOffsetY
        }
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList == nil ? 0 : msgList!.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = msgList![indexPath.row]
        if message.msg_type_ == PushMessage.MessageType.Date.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatDateCell", forIndexPath: indexPath) as! ChatDateCell
            cell.sentDateLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: NSNumber.init(longLong: message.msg_time_).doubleValue))
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatBubbleCell", forIndexPath: indexPath) as! ChatBubbleCell
            let msgData = Message(incoming: (message.from_uid_ == DataManager.currentUser?.uid) ? false : true, text: message.content_!, sentDate: NSDate(timeIntervalSince1970: NSNumber.init(longLong: message.msg_time_).doubleValue))
            cell.configureWithMessage(msgData)
            return cell
        }
    }
    
    func sendMessageAction() {
        let msg = textView.text
        let msgData = Message(incoming: false, text: msg, sentDate: NSDate(timeIntervalSinceNow: 0))
        messages.append(msgData)
        
        let data:Dictionary<String, AnyObject> = ["from_uid_": DataManager.currentUser!.uid,
                                                  "to_uid_": servantInfo!.uid,
                                                  "msg_time_": NSNumber.init(longLong: Int64(NSDate().timeIntervalSince1970)),
                                                  "content_": msg]
        
        SocketManager.sendData(.SendChatMessage, data: data)
        let message = PushMessage(value: data)
        DataManager.insertMessage(message)
        
        let numberOfRows = chatTable?.numberOfRowsInSection(0)
        if numberOfRows! == 0 {
            msgList = DataManager.getMessage(servantInfo!.uid)?.msgList
            chatTable?.reloadData()
        } else {
            chatTable?.beginUpdates()
            chatTable?.insertRowsAtIndexPaths([NSIndexPath.init(forRow: numberOfRows!, inSection: 0), NSIndexPath.init(forRow: numberOfRows!, inSection: 0)], withRowAnimation: .Fade)
            chatTable?.endUpdates()
            chatTable?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: numberOfRows!, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
        
        textView.text = ""
    }
    
    func menuControllerWillHide(notification: NSNotification) {
        if let selectedIndexPath = chatTable!.indexPathForSelectedRow {
            chatTable!.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
    }
    
    
    func messageCopyTextAction(menuController: UIMenuController) {
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
