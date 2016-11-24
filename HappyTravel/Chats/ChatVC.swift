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

open class ChatVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ServiceSheetDelegate {
    var daysAlertController:UIAlertController?

    var dateFormatter = DateFormatter()
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
    
    var selectedServcie:ServiceInfo?

    override open var inputAccessoryView: UIView! {
        get {
            if toolBar == nil {
                toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44-0.5))
                toolBar.backgroundColor = colorWithHexString("#f2f2f2")
                faceButton = UIButton(type: .custom)
                faceButton.setBackgroundImage(UIImage.init(named: "face-btn"), for: UIControlState())
                faceButton.addTarget(self, action: #selector(ChatVC.sendMessageAction), for: UIControlEvents.touchUpInside)
                toolBar.addSubview(faceButton)
                faceButton.translatesAutoresizingMaskIntoConstraints = false
                faceButton.snp.makeConstraints({ (make) in
                    make.top.equalTo(toolBar).offset(5)
                    make.left.equalTo(toolBar).offset(5)
                    make.bottom.equalTo(toolBar).offset(-5)
                    make.width.equalTo(32)
                })
                
                sendButton = UIButton(type: .system)
                sendButton.isEnabled = false
                sendButton.titleLabel?.font = UIFont.systemFont(ofSize: S18)
                sendButton.layer.cornerRadius = 5
                sendButton.layer.masksToBounds = true
                sendButton.backgroundColor = UIColor.init(red: 20/255, green: 31/255, blue: 49/255, alpha: 1)
                sendButton.setTitle("发送", for: UIControlState())
                sendButton.setTitleColor(UIColor.gray, for: .disabled)
                sendButton.setTitleColor(UIColor.white, for: UIControlState())
                sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                sendButton.addTarget(self, action: #selector(ChatVC.sendMessageAction), for: UIControlEvents.touchUpInside)
                toolBar.addSubview(sendButton)
                sendButton.translatesAutoresizingMaskIntoConstraints = false
                sendButton.snp.makeConstraints({ (make) in
                    make.top.equalTo(toolBar).offset(5)
                    make.right.equalTo(toolBar).offset(-5)
                    make.bottom.equalTo(toolBar).offset(-5)
                    make.width.equalTo(80)
                })
                
                textView = InputTextView(frame: CGRect.zero)
                textView.backgroundColor = UIColor(white: 250/255, alpha: 1)
                textView.delegate = self
                textView.font = UIFont.systemFont(ofSize: S18)
                textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).cgColor
                textView.layer.borderWidth = 0.5
                textView.layer.cornerRadius = 5
                textView.scrollsToTop = false
                textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
                toolBar.addSubview(textView)
                textView.translatesAutoresizingMaskIntoConstraints = false
                textView.snp.makeConstraints({ (make) in
                    make.left.equalTo(faceButton.snp.right).offset(5)
                    make.right.equalTo(sendButton.snp.left).offset(-5)
                    make.bottom.equalTo(toolBar).offset(-5)
                    make.top.equalTo(toolBar).offset(5)
                })

            }
            return toolBar
        }
    }
    
    override open var canBecomeFirstResponder : Bool {
        return true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = servantInfo?.nickname
        view.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)

        if servantInfo == nil {
           navigationController?.popViewController(animated: true)
            return
        }
        
        msgList = DataManager.getMessage(servantInfo!.uid)?.msgList
        
        initView()
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        if navigationItem.rightBarButtonItem == nil {
            let msgItem = UIBarButtonItem.init(title: "立即邀约", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatVC.invitationAction(_:)))
            navigationItem.rightBarButtonItem = msgItem
        }
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if msgList != nil {
            chatTable!.scrollToRow(at: IndexPath.init(row: msgList!.count-1, inSection: 0), at: .bottom, animated: false)
        }
        let unreadCntBefore = DataManager.getUnreadMsgCnt(-1)
        DataManager.readMessage(servantInfo!.uid)
        let unreadCntLater = DataManager.getUnreadMsgCnt(-1)
        var readCnt = unreadCntBefore - unreadCntLater
        if readCnt == unreadCntBefore {
            readCnt = -1
        }
        SocketManager.sendData(.feedbackMSGReadCnt, data: ["uid_": servantInfo!.uid, "count_": readCnt])
        UIApplication.shared.applicationIconBadgeNumber = unreadCntLater
        
    }
    
    func registerNotify() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ChatVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatVC.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatVC.menuControllerWillHide(_:)), name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatVC.chatMessage(_:)), name: NSNotification.Name(rawValue: NotifyDefine.UpdateChatVC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.invitationResult(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AskInvitationResult), object: nil)
        
    }
    
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
    
    func chatMessage(_ notification: Notification?) {
        let msg = (notification?.userInfo!["data"])! as! PushMessage
        if msg.from_uid_ == servantInfo?.uid && msg.to_uid_ == DataManager.currentUser!.uid {
            chatTable?.beginUpdates()
            let numberOfRows = chatTable?.numberOfRows(inSection: 0)
            chatTable?.insertRows(at: [IndexPath.init(row: numberOfRows!, section: 0), IndexPath.init(row: numberOfRows!, section: 0)], with: .fade)
            chatTable?.endUpdates()
            chatTable?.scrollToRow(at: IndexPath.init(row: numberOfRows!, section: 0), at: .bottom, animated: true)
            DataManager.readMessage(msg.from_uid_)
        }
        
    }
    
    func invitationAction(_ sender: UIButton?) {
        invitation()
    }
    
    func invitation() {
        textView.resignFirstResponder()
        if alertController == nil {
            alertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
            let sheet = ServiceSheet()
            sheet.servantInfo = DataManager.getUserInfo(servantInfo!.uid)
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
    
    
    func sureAction(_ service: ServiceInfo?, daysCount: Int?) {
        
        unowned let weakSelf = self

        selectedServcie = service

        alertController?.dismiss(animated: true, completion: {
            
            weakSelf.perform(#selector(ServantPersonalVC.inviteAction), with: nil, afterDelay: 0.2)
            
            
        })
        
    }

    func inviteAction() {
        if daysAlertController == nil {
            daysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
            let sheet = CitysSelectorSheet()
            let days = [1, 2, 3, 4, 5, 6, 7]
            sheet.daysList = days
            sheet.delegate = self
            daysAlertController!.view.addSubview(sheet)
            sheet.snp.makeConstraints { (make) in
                make.left.equalTo(daysAlertController!.view).offset(-10)
                make.right.equalTo(daysAlertController!.view).offset(10)
                make.bottom.equalTo(daysAlertController!.view).offset(10)
                make.top.equalTo(daysAlertController!.view)
            }
        }
        
        present(daysAlertController!, animated: true, completion: nil)
    }
    open func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = textView.hasText
    }
    
    func initView() {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        let rect = view.bounds
        chatTable = UITableView(frame: rect, style: .plain)
        chatTable!.tag = 1001
        chatTable?.backgroundColor = UIColor.clear
        chatTable!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chatTable!.dataSource = self
        chatTable!.delegate = self
        chatTable!.keyboardDismissMode = .interactive
        chatTable!.estimatedRowHeight = 44
        chatTable!.separatorStyle = .none
        chatTable!.register(ChatDateCell.self, forCellReuseIdentifier: "ChatDateCell")
        chatTable!.register(ChatBubbleCell.self, forCellReuseIdentifier: "ChatBubbleCell")
        view.addSubview(chatTable!)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(ChatVC.headerRefresh))
        chatTable?.mj_header = header

    }
    
    func headerRefresh() {
        
        
        perform(#selector(ChatVC.endRefresh), with: nil, afterDelay: 5)
    }
    
    func endRefresh() {
        header.endRefreshing()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let insetNewBottom = chatTable!.convert(frameNew, from: nil).height
        let insetOld = chatTable!.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = chatTable!.contentSize.height - (chatTable!.frame.height-insetOld.top-insetOld.bottom)
        
        let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.chatTable!.isTracking || self.chatTable!.isDecelerating) {
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
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16)) // http://stackoverflow.com/a/18873820/242933
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let insetNewBottom = chatTable!.convert(frameNew, from: nil).height
        
        // Inset `tableView` with keyboard
        let contentOffsetY = chatTable!.contentOffset.y
        chatTable!.contentInset.bottom = insetNewBottom
        chatTable!.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if chatTable!.isTracking || chatTable!.isDecelerating {
            chatTable!.contentOffset.y = contentOffsetY
        }
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList == nil ? 0 : msgList!.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = msgList![indexPath.row]
        if message.msg_type_ == PushMessage.MessageType.Date.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDateCell", for: indexPath) as! ChatDateCell
            cell.sentDateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: NSNumber.init(value: message.msg_time_).doubleValue))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBubbleCell", for: indexPath) as! ChatBubbleCell
            let msgData = Message(incoming: (message.from_uid_ == DataManager.currentUser?.uid) ? false : true, text: message.content_!, sentDate: Date(timeIntervalSince1970: NSNumber.init(value: message.msg_time_).doubleValue))
            cell.configureWithMessage(msgData)
            return cell
        }
    }
    
    func sendMessageAction() {
        let msg = textView.text
        let msgData = Message(incoming: false, text: msg!, sentDate: Date(timeIntervalSinceNow: 0))
        messages.append(msgData)
        
        let data:Dictionary<String, AnyObject> = ["from_uid_": DataManager.currentUser!.uid as AnyObject,
                                                  "to_uid_": servantInfo!.uid as AnyObject,
                                                  "msg_time_": NSNumber.init(value: Int64(Date().timeIntervalSince1970) as Int64),
                                                  "content_": msg as AnyObject]
        
        SocketManager.sendData(.sendChatMessage, data: data as AnyObject?)
        let message = PushMessage(value: data)
        DataManager.insertMessage(message)
        
        let numberOfRows = chatTable?.numberOfRows(inSection: 0)
        if numberOfRows! == 0 {
            msgList = DataManager.getMessage(servantInfo!.uid)?.msgList
            chatTable?.reloadData()
        } else {
            chatTable?.beginUpdates()
            chatTable?.insertRows(at: [IndexPath.init(row: numberOfRows!, section: 0), IndexPath.init(row: numberOfRows!, section: 0)], with: .fade)
            chatTable?.endUpdates()
            chatTable?.scrollToRow(at: IndexPath.init(row: numberOfRows!, section: 0), at: .bottom, animated: true)
        }
        
        textView.text = ""
    }
    
    func menuControllerWillHide(_ notification: Notification) {
        if let selectedIndexPath = chatTable!.indexPathForSelectedRow {
            chatTable!.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
    
    
    func messageCopyTextAction(_ menuController: UIMenuController) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}



extension ChatVC:CitysSelectorSheetDelegate {
    func daysSureAction(_ sender: UIButton?, targetDays: Int) {
        daysAlertController?.dismiss(animated: true, completion: nil)
        
        SocketManager.sendData(.askInvitation, data: ["from_uid_": DataManager.currentUser!.uid,
            "to_uid_": servantInfo!.uid,
            "service_id_": selectedServcie!.service_id_,
            "day_count_":targetDays])
    }
    
    func daysCancelAction(_ sender: UIButton?) {
        
        daysAlertController?.dismiss(animated: true, completion: nil)
    }
}

