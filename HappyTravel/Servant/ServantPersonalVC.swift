//
//  ServantPersonalVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/4.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh


/**
 * 13132696374
 * 18625090746
 * 15868912093
 * 15158114927
 */
public class ServantPersonalVC : UIViewController, UITableViewDelegate,UITableViewDataSource, ServantHeaderViewDelegate{
    
    // MARK: - 属性
    var personalInfo:UserInfoModel?
    var detailInfo:ServantDetailModel?
    
    // 自定义导航条、左右按钮和title
    var topView:UIView?
    var leftBtn:UIButton?
    var rightBtn:UIButton?
    var topTitle:UILabel?
    
    var tableView:UITableView?
    var dataArray:NSMutableArray?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    
    // MARK: - 函数方法
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        
        addData()
    }
    
    func addData() {
        APIHelper.servantAPI().servantDetail(<#T##model: UserBaseModel##UserBaseModel#>, complete: <#T##CompleteBlock?##CompleteBlock?##(AnyObject?) -> ()#>, error: <#T##ErrorBlock?##ErrorBlock?##(NSError) -> ()#>)
    }
    
    /**
     APIHelper.servantAPI().servantNearby(servantNearbyModel, complete: { [weak self](response) in
     if let models = response as? [UserInfoModel] {
     self?.annotations.removeAll()
     for servant in models {
     self?.servantsInfo[servant.uid_] = servant
     DataManager.insertData(servant)
     let latitude = servant.latitude_
     let longitude = servant.longitude_
     let point = MAPointAnnotation.init()
     
     */
    // 加载页面
    func initViews(){
        tableView = UITableView.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight), style: .Grouped)
        tableView?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        tableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .None
        tableView?.registerClass(ServantPersonalCell.self, forCellReuseIdentifier: "ServantPersonalCell")
        view.addSubview(tableView!)
        
        tableView?.snp_makeConstraints(closure: { (make) in
            make.left.right.top.bottom.equalTo(view)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(ServantPersonalVC.headerRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(ServantPersonalVC.footerRefresh))
        
        // 设置顶部 topView
        topView = UIView.init(frame: CGRectMake(0, 0, ScreenWidth, 64))
        topView?.backgroundColor = UIColor.clearColor()
        view.addSubview(topView!)
        
        leftBtn = UIButton.init(frame: CGRectMake(15, 27, 30, 30))
        leftBtn!.layer.masksToBounds = true
        leftBtn!.layer.cornerRadius = 15.0
        leftBtn!.setImage(UIImage.init(named: "nav-back"), forState: .Normal)
        topView?.addSubview(leftBtn!)
        leftBtn!.addTarget(self, action: #selector(ServantPersonalVC.backAction), forControlEvents: .TouchUpInside)
        
        rightBtn = UIButton.init(frame: CGRectMake(ScreenWidth - 45, 27, 30, 30))
        rightBtn!.layer.masksToBounds = true
        rightBtn!.layer.cornerRadius = 15.0
        rightBtn!.setImage(UIImage.init(named: "nav-jb"), forState: .Normal)
        topView?.addSubview(rightBtn!)
        rightBtn!.addTarget(self, action: #selector(ServantPersonalVC.reportAction), forControlEvents: .TouchUpInside)
        
        topTitle = UILabel.init(frame: CGRectMake((leftBtn?.Right)! + 10 , (leftBtn?.Top)!, (rightBtn?.Left)! - leftBtn!.Right - 20, (leftBtn?.Height)!))
        topView?.addSubview(topTitle!)
        topTitle?.font = UIFont.systemFontOfSize(17)
        topTitle?.textAlignment = .Center
        topTitle?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        
    }
    
    // 刷新数据
    func headerRefresh() {
    }
    
    // 加载数据
    func footerRefresh() {
    }
    
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func reportAction() {
        print("-----右上角举报实现~")
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ServantPersonalCell", forIndexPath: indexPath) as! ServantPersonalCell
        
        return cell
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header:ServantHeaderView = ServantHeaderView.init(frame: CGRectMake(0, 0, ScreenWidth, 379))
        header.didAddNewUI(personalInfo!)
        return header
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 379
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
//        let footer:ServantFooterView = ServantFooterView.init(frame:CGRectMake(0, 0, ScreenWidth, 55),detail: "Ta很神秘，还未发布任何动态")
        let footer:ServantFooterView = ServantFooterView.init(frame:CGRectMake(0, 0, ScreenWidth, 55),detail: "暂无更多动态")
        return footer
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 55
    }
    
    // 滑动的时候改变顶部 topView
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let color:UIColor = UIColor.whiteColor()
        let offsetY:CGFloat = scrollView.contentOffset.y
        
        if offsetY < 1 {
            topView?.backgroundColor = color.colorWithAlphaComponent(0)
            topTitle?.text = ""
            leftBtn?.setImage(UIImage.init(named: "nav-back"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "nav-jb"), forState: .Normal)
        }else {
            let alpha:CGFloat = 1 - ((64 - offsetY) / 64)
            topView?.backgroundColor = color.colorWithAlphaComponent(alpha)
            topTitle?.text = "导航标题~~"
            leftBtn?.setImage(UIImage.init(named: "nav-back-select"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "nav-jb-select"), forState: .Normal)
        }
    }
    
    
    // MARK: - 加微信和关注按钮
    func attentionAction() {
        // 加关注
    }
    func addMyWechatAccount() {
        // 加微信
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
