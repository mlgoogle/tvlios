//
//  FollowListVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/3/1.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
import XCGLogger
import MJRefresh

class FollowListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let table = UITableView()
    var timer:NSTimer?
    var isFirstTime = true
    var pageCount = 0
    var follows = [FollowListCellModel]()
    var followedCount = 0
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    lazy var headView:UILabel = {
        let label = UILabel.init(text: "关注的人数: ", font: UIFont.systemFontOfSize(S16), textColor: colorWithHexString("#666666"))
        label.textAlignment = .Left
        label.backgroundColor = colorWithHexString("#f2f2f2")
        return label
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
    }
    
    override func viewDidLoad() {
        initView()
        //隐藏小红点
        let viewHidden = tabBarController?.view.viewWithTag(10)
        viewHidden?.hidden = true
    }
    
    func initView() {
        view.backgroundColor = UIColor.whiteColor()
        table.backgroundColor = UIColor.clearColor()
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 80
        table.rowHeight = UITableViewAutomaticDimension
        table.separatorStyle = .SingleLine
        table.registerClass(FollowCell.self, forCellReuseIdentifier: "FollowCell")
        view.addSubview(table)
        table.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        table.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        table.mj_footer = footer
        
    }
    
    func headerRefresh() {
        footer.state = .Idle
        pageCount = 0
        let req = FollowListRequestModel()
        req.uid_ = CurrentUser.uid_
        APIHelper.followAPI().followList(req, complete: { [weak self](response) in
            if let models = response as? [FollowListCellModel] {
                self?.follows = models
                self?.followedCount = models.count
                self?.endRefresh()
            }
            if self?.follows.count < 10 {
                self?.noMoreData()
            }
        }, error: { [weak self](error) in
            self?.endRefresh()
        })
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func footerRefresh() {
        pageCount += 1
        let req = FollowListRequestModel()
        req.uid_ = CurrentUser.uid_
        req.page_num_ = pageCount
        APIHelper.followAPI().followList(req, complete: { [weak self](response) in
            if let models = response as? [FollowListCellModel] {
                self?.follows += models
                self?.endRefresh()
            } else {
                self?.noMoreData()
            }
            }, error: { [weak self](error) in
                self?.endRefresh()
            })
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
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
        table.reloadData()
    }
    
    func noMoreData() {
        endRefresh()
        footer.state = .NoMoreData
        footer.setTitle("没有更多信息", forState: .NoMoreData)
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headView.text = "    关注的人数: \(followedCount)人"
        return headView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return follows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell", forIndexPath: indexPath) as! FollowCell
        cell.update(follows[indexPath.row])
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let req = UserInfoIDStrRequestModel()
        req.uid_str_ = "\(follows[indexPath.row].uid_)"
        APIHelper.servantAPI().getUserInfoByString(req, complete: { [weak self](response) in
            if let models = response as? [UserInfoModel] {
                DataManager.insertDatas(models)
                
                let servantPersonalVC = ServantPersonalVC()
                servantPersonalVC.servantInfo = models.first
                self?.navigationController?.pushViewController(servantPersonalVC, animated: true)
            }
        }, error: { (err) in
        
        })
        
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
