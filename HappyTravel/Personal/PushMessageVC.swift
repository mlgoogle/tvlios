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
    var pageCount = 0
    var orders = [OrderListCellModel]()
    
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
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 80
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .SingleLine
        table?.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        table?.mj_header = header
        footer.hidden = true
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        table?.mj_footer = footer
    }
    
    func headerRefresh() {
        
        footer.state = .Idle
        pageCount = 0
        let req = OrderListRequestModel()
        req.uid_ = CurrentUser.uid_
        APIHelper.consumeAPI().orderList(req, complete: { [weak self](response) in
            if let models = response as? [OrderListCellModel]{
               self?.orders = models
                self!.footer.hidden = false
                self?.endRefresh()
            }
            if self?.orders.count < 10 {
                self?.noMoreData()
            }
            
            },error:{ [weak self](error) in
                self?.endRefresh()
        })
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
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
        pageCount += 1
        let req = OrderListRequestModel()
        req.uid_ = CurrentUser.uid_
        req.page_num_ = pageCount
        APIHelper.consumeAPI().orderList(req, complete: { [weak self](response) in
            if let models = response as? [OrderListCellModel]{
                self?.orders += models
                self?.endRefresh()
            }
            else{
                self?.noMoreData()
            }
            },error: { [weak self](error) in
                self?.endRefresh()
        })
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 3
//    }
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        cell.accessoryType = .DisclosureIndicator
        cell.updeat(orders[indexPath.row])
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    //MARK: -- 返回组标题索引
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "最近30天内的订单消息"
        label.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        label.font = UIFont.systemFontOfSize(13)
        let sumView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 34))
        sumView.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.centerX.equalTo(sumView)
            make.height.equalTo(13)
            make.top.equalTo(sumView).offset(10)
            make.bottom.equalTo(sumView.snp_bottom).offset(-10)
            
        }
        return sumView
}
    //组头高
     func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    //组尾高
     func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
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

