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
import SVProgressHUD

public class ServantPersonalVC : UIViewController, UITableViewDelegate, UITableViewDataSource, PersonalHeadCellDelegate, PhotosCellDelegate {
    //记录是邀约？预约？   ture为邀约  false 为预约
    var isNormal = true
    
    var personalInfo:UserInfoModel?
    var detailInfo:ServantDetailModel?
    var personalTable:UITableView?
    var serviceSpread = true
    var alertController:UIAlertController?
    
    var photoModel:PhotoWallModel?
    
    var follow = false
    
    var followCount = 0
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    func initView() {
        view.backgroundColor = UIColor.init(red: 33/255.0, green: 59/255.0, blue: 76/255.0, alpha: 1)
        title = personalInfo?.nickname_
        
        detailInfo = DataManager.getData(ServantDetailModel.self, filter: "uid_ = \(personalInfo!.uid_)")?.first
        
        personalTable = UITableView(frame: CGRectZero, style: .Plain)
        personalTable!.registerClass(PersonalHeadCell.self, forCellReuseIdentifier: "PersonalHeadCell")
        personalTable!.registerClass(TallyCell.self, forCellReuseIdentifier: "TallyCell")
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
            make.bottom.equalTo(view)
        }
        
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
    }
    
    func registerNotify() {

    }
    
    func requestPhoto() {
        if personalInfo != nil {
            let dict = ["uid_": personalInfo!.uid_,
                        "size_": 12,
                        "num_": 1]
            let model = PhotoWallRequestModel(value: dict)
            APIHelper.servantAPI().requestPhotoWall(model, complete: { (response) in
                
                self.photoModel = response as? PhotoWallModel
                self.personalTable?.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: .Fade)
            }) { (error) in
                
            }
        }
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        personalTable!.reloadData()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        updateFollowStatus()
        updateFollowCount()
        requestPhoto()

        guard isNormal else { return }
        if navigationItem.rightBarButtonItem == nil {
            let msgItem = UIBarButtonItem.init(image: UIImage.init(named: "nav-msg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(reportAction(_:)))
            navigationItem.rightBarButtonItem = msgItem
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    public func reportAction(sender: UIButton) {
        XCGLogger.debug("举报")
    }
    
    // MARK -- UITableViewDelegate & UITableViewDataSource
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PersonalHeadCell", forIndexPath: indexPath) as! PersonalHeadCell
            cell.delegate = self
            cell.setInfo(personalInfo, servantDetail: detailInfo , detailInfo: nil, follow: follow, followCnt: followCount)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TallyCell", forIndexPath: indexPath) as! TallyCell
            cell.setInfo(detailInfo?.tags)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotosCell", forIndexPath: indexPath) as! PhotosCell
            cell.delegate = self
            cell.setInfo(photoModel?.photo_list_, setSpread: serviceSpread)
            return cell
        }
        
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 {
            let photoWall = PhotoWallViewController()
            photoWall.info = personalInfo
            navigationController?.pushViewController(photoWall, animated: true)
        }
    }
    
    // MARK ServiceCellDelegate
    func spreadAction(sender: AnyObject?) {
        
    }
    
    // MARK - PersonalHeadCellDelegate
    func followAction() {
        let req = FollowModel()
        req.follow_to_ = personalInfo?.uid_ ?? -1
        req.follow_type_ = !follow ? 1 : 2
        APIHelper.followAPI().followStatus(req, complete: { [weak self](response) in
            if let model = response as? FollowedModel {
                if model.result_ == 0 {
                    self?.updateFollowStatus()
                } else {
                    SVProgressHUD.showWainningMessage(WainningMessage: req.follow_type_ == 1 ? "关注失败" : "取消关注失败", ForDuration: 1.5, completion: nil)
                }
            }
        }, error: nil)
        
    }
    
    func updateFollowStatus() {
        let req = FollowModel()
        req.follow_to_ = personalInfo?.uid_ ?? -1
        req.follow_type_ = 3
        APIHelper.followAPI().followStatus(req, complete: { [weak self](response) in
            if let model = response as? FollowedModel {
                self?.follow = !Bool(model.result_)
                self?.personalTable?.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
            }
            self?.updateFollowCount()
        }, error: nil)
    }
    
    func updateFollowCount() {
        let req = FollowCountRequestModel()
        req.uid_ = personalInfo!.uid_
        APIHelper.followAPI().followCount(req, complete: { [weak self](response) in
            if let model = response as? FollowCountModel {
                self?.followCount = model.follow_count_
                self?.personalTable?.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
            }
            }, error: nil)
    }
}
