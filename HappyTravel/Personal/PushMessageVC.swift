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


class PushMessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table:UITableView?
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
        initView()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pushMessageNotify(_:)), name: NotifyDefine.PushMessageNotify, object: nil)

    }
    
    func allEndRefreshing() {
        if header.state == MJRefreshState.Refreshing {
            header.endRefreshing()
        }
        if footer.state == MJRefreshState.Refreshing {
            footer.endRefreshing()
        }

    }
    
    func pushMessageNotify(notification: NSNotification) {
        
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(PushMessageVC.headerRefresh))
        table?.mj_header = header
        footer.hidden = true
        footer.setRefreshingTarget(self, refreshingAction: #selector(PushMessageVC.footerRefresh))
        table?.mj_footer = footer
        
    }
    
    func headerRefresh() {
        header.endRefreshing()
        table?.reloadData()
        
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
        footer.endRefreshing()
        
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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

