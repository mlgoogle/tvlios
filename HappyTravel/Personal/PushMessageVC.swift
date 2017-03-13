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
    var isRefresh:Bool = false
    
    var allDataDict:[String : Array<OrderListCellModel>] = Dictionary()
    var dateArray:[String] = Array()
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "消息中心"
        initView()
        //隐藏红点
        let viewHidden = tabBarController?.view.viewWithTag(10)
        viewHidden?.hidden = true
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        if isRefresh {
            
        }else{
            header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
        }
        
        
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
    
    //上拉刷新
    func headerRefresh() {
        footer.state = .Idle
        pageCount = 0
        let req = OrderListRequestModel()
        req.uid_ = CurrentUser.uid_
        APIHelper.consumeAPI().orderList(req, complete: { [weak self](response) in
            if response != nil{
                self!.footer.hidden = false
            }
            if let models = response as? [OrderListCellModel]{
                self!.allDataDict.removeAll()
                self!.dateArray.removeAll()
                self!.setupDataWithModels(models)
                
                self?.orders = models
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
    //下拉刷新
    func footerRefresh() {
        pageCount += 1
        let req = OrderListRequestModel()
        req.uid_ = CurrentUser.uid_
        req.page_num_ = pageCount
        APIHelper.consumeAPI().orderList(req, complete: { [weak self](response) in
            if let models = response as? [OrderListCellModel]{
                self!.setupDataWithModels(models)
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
    
    // MARK: - UITableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return dateArray.count
        }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = allDataDict[dateArray[section]]
        return array == nil ? 0 : array!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        cell.accessoryType = .DisclosureIndicator
        let array = allDataDict[dateArray[indexPath.section]]
        cell.updeat(array![indexPath.row])
        return cell
    }
    
    //数据分组处理
    func setupDataWithModels(models:[OrderListCellModel]){
        let dateFormatter = NSDateFormatter()
        var dateString: String?
        for model in models{
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.dateFromString(model.order_time_!)
            if date == nil {
                continue
            }
            else{
                dateFormatter.dateFormat = "MM"
                dateString = dateFormatter.stringFromDate(date!)
            }
           
            /*
             - 判断 model 对应的分组 是否已经有当天数据信息
             - 如果已经有信息则直接将model 插入当天信息array
             - 反之，创建当天分组array 插入数据
             */
            if dateArray.contains(dateString!){
                allDataDict[dateString!]?.append(model)
            }
            else{
                var list:[OrderListCellModel] = Array()
                list.append(model)
                dateArray.append(dateString!)
                allDataDict[dateString!] = list
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let array = allDataDict[dateArray[indexPath.section]]
        let getDict: [String : AnyObject] = ["order_id_": array![indexPath.row].order_id_,
                                             "uid_form_": CurrentUser.uid_,
                                             "uid_to_": array![indexPath.row].to_uid_]
        let getModel = GetRelationRequestModel(value: getDict)
        
        APIHelper.consumeAPI().getRelation(getModel, complete: { [weak self](response) in
            
            if let model = response as? GetRelationStatusModel{
                    let aidWeiXin = AidWenXinVC()
                    aidWeiXin.getRelation = model
                    aidWeiXin.nickname = array![indexPath.row].to_uid_nickename_
                    aidWeiXin.toUid = array![indexPath.row].to_uid_
                    aidWeiXin.orderId = array![indexPath.row].order_id_
                    aidWeiXin.isEvaluate = array![indexPath.row].is_evaluate_ == 0 ? false : true
                    aidWeiXin.bool = false
                    aidWeiXin.toUidUrl =  array![indexPath.row].to_uid_url_
                    aidWeiXin.isRefresh = { ()->() in
                        self!.isRefresh = true
                    }
                    self!.navigationController?.pushViewController(aidWeiXin, animated: true)
            }
            
            
            }, error: { (error) in
                
        })
    }
    
    //MARK: -- 返回组标题索引
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        let date = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "MM'at' HH:mm:ss.SSS"
        let strNowTime = timeFormatter.stringFromDate(date) as String
        let timeArray = strNowTime.componentsSeparatedByString(".")
        let NYR = timeArray[0].componentsSeparatedByString("at")
        
        if NYR[0] == dateArray[0] {
            label.text = "最近30天内的订单消息"
        }else{
           label.text = dateArray[section] + "月"
        }
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

