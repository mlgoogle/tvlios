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

public class ServantPersonalVC : UIViewController, UITableViewDelegate, UITableViewDataSource, ServiceCellDelegate, PhotosCellDelegate, ServiceSheetDelegate {
    
    var personalInfo:UserInfo?
    var personalTable:UITableView?
    var bottomBar:UIImageView?
    var serviceSpread = false
    var invitaionVC = InvitationVC()
    var alertController:UIAlertController?
    
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
        invitationBtn.setTitle("发起邀约", forState: .Normal)
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
    
    func bottomBarAction(sender: UIButton?) {
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
    
    func sureAction(sender: UIButton?) {
        alertController?.dismissViewControllerAnimated(true, completion: nil)
        self.view.addSubview(invitaionVC.view)
        invitaionVC.start()
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        personalTable!.reloadData()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationItem.rightBarButtonItem == nil {
            let msgItem = UIBarButtonItem.init(image: UIImage.init(named: "nav-msg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ServantPersonalVC.msgAction))
            navigationItem.rightBarButtonItem = msgItem
        }
    }
    
    func msgAction() {
        XCGLogger.debug("msgAction")
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
            let tallys = personalInfo!.businessTags! + personalInfo!.travalTags!
            cell.setInfo(tallys)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCell", forIndexPath: indexPath) as! ServiceCell
            cell.delegate = self
            cell.setInfo(personalInfo?.serviceList, setSpread: serviceSpread)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotosCell", forIndexPath: indexPath) as! PhotosCell
            cell.delegate = self
            cell.setInfo(personalInfo?.photoUrlList, setSpread: serviceSpread)
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


