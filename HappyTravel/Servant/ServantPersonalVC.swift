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
import SVProgressHUD


public class ServantPersonalVC : UIViewController, UITableViewDelegate,UITableViewDataSource, ServantHeaderViewDelegate, ServantPersonalCellDelegate{
    
    // MARK: - 属性
    var servantInfo:UserInfoModel?
    var detailInfo:ServantDetailModel?
    
    // 自定义导航条、左右按钮和title
    var topView:UIView?
    var leftBtn:UIButton?
    var rightBtn:UIButton?
    var topTitle:UILabel?
    
    var tableView:UITableView?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    // 头视图
    var headerView:ServantHeaderView?
    // 是否关注状态
    var follow = false
    var fansCount = 0
    
    
    var pageNum:Int = 0
    var dataArray = [ServantDynamicModel]()
    var timer:NSTimer? // 刷新用
    
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
        
        print(servantInfo)
        
        // 查询关注状态并更新UI
        updateFollowStatus()
        // 查询粉丝数
        updateFollowCount()
        
        initViews()
        
        //隐藏红点
        let viewHidden = tabBarController?.view.viewWithTag(10)
        viewHidden?.hidden = true
        
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
    }
    
    // 加载页面
    func initViews(){
        tableView = UITableView.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight), style: .Grouped)
        tableView?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        tableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .None
        tableView?.estimatedRowHeight = 120
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.separatorStyle = .None
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        // 只有一条文字的Cell展示
        tableView?.registerClass(ServantOneLabelCell.self, forCellReuseIdentifier: "ServantOneLabelCell")
        // 只有一张图片的Cell展示
        tableView?.registerClass(ServantOnePicCell.self, forCellReuseIdentifier: "ServantOnePicCell")
        // 复合Cell展示
        tableView?.registerClass(ServantPicAndLabelCell.self, forCellReuseIdentifier: "ServantPicAndLabelCell")
        view.addSubview(tableView!)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(ServantPersonalVC.headerRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(ServantPersonalVC.footerRefresh))
        tableView?.mj_header = header
        tableView?.mj_footer = footer
        
        // 设置顶部 topView
        topView = UIView.init(frame: CGRectMake(0, 0, ScreenWidth, 64))
        topView?.backgroundColor = UIColor.clearColor()
        view.addSubview(topView!)
        // 挡住 header
        let topbar = UIView.init(frame: CGRectMake(0, 0, ScreenWidth, 20))
        topbar.backgroundColor = UIColor.whiteColor()
        topView?.addSubview(topbar)
        
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
    
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // 右上角举报
    func reportAction() {
        
        servantReport(0)
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row < dataArray.count {
            
            let model:ServantDynamicModel = dataArray[indexPath.row]
            let detailText:String = model.dynamic_text_!
            let urlStr = model.dynamic_url_
            let urlArray = urlStr!.componentsSeparatedByString(",")
            
            if urlStr?.characters.count == 0 {
                // 只有文字的Cell
                let cell = tableView.dequeueReusableCellWithIdentifier("ServantOneLabelCell", forIndexPath: indexPath) as! ServantOneLabelCell
                cell.delegate = self
                cell.selectionStyle = .None
                
                cell.headerView?.kf_setImageWithURL(NSURL.init(string: (servantInfo?.head_url_)!))
                cell.nameLabel?.text = servantInfo?.nickname_
                
                cell.updateLabelText(model)
                
                return cell
                
            } else if detailText.characters.count  == 0 && urlArray.count == 1 {
                // 只有一张图片的cell
                let cell = tableView.dequeueReusableCellWithIdentifier("ServantOnePicCell", forIndexPath: indexPath) as! ServantOnePicCell
                cell.delegate = self
                cell.selectionStyle = .None
                
                cell.headerView?.kf_setImageWithURL(NSURL.init(string: (servantInfo?.head_url_)!))
                cell.nameLabel?.text = servantInfo?.nickname_
                
                cell.updateImage(model)
                return cell
                
            } else {
                // 复合cell
                let cell = tableView.dequeueReusableCellWithIdentifier("ServantPicAndLabelCell", forIndexPath: indexPath) as! ServantPicAndLabelCell
                cell.delegate = self
                cell.selectionStyle = .None
                
                cell.headerView?.kf_setImageWithURL(NSURL.init(string: (servantInfo?.head_url_)!))
                cell.nameLabel?.text = servantInfo?.nickname_
                
                cell.updateUI(model)
                
                return cell
            }
            
        }
        
        return UITableViewCell.init()
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        headerView = ServantHeaderView.init(frame: CGRectMake(0, 0, ScreenWidth, 379))
        headerView!.headerDelegate = self
        headerView!.didAddNewUI(servantInfo!)
        headerView?.updateFansCount(self.fansCount)
        headerView?.uploadAttentionStatus(self.follow)
        return headerView
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 379
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footer:ServantFooterView?
        
        if dataArray.count == 0 {
            footer = ServantFooterView.init(frame:CGRectMake(0, 0, ScreenWidth, 55),detail: "Ta很神秘，还未发布任何动态")
        }else {
            footer = ServantFooterView.init(frame:CGRectMake(0, 0, ScreenWidth, 55),detail: "暂无更多动态")
        }
        
        return footer
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
        } else {
            let alpha:CGFloat = 1 - ((64 - offsetY) / 64)
            topView?.backgroundColor = color.colorWithAlphaComponent(alpha)
            
            let titleString = servantInfo?.nickname_
            topTitle?.text = titleString
            leftBtn?.setImage(UIImage.init(named: "nav-back-select"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "nav-jb-select"), forState: .Normal)
        }
    }
    
    // MARK: 数据
    // 刷新数据
    func headerRefresh() {
        
        footer.state = .Idle
        pageNum = 0
        let detailInfo:ServantInfoModel = ServantInfoModel()
        detailInfo.uid_ = servantInfo!.uid_
        detailInfo.page_num_ = pageNum
        detailInfo.page_count_ = 10
        
        APIHelper.servantAPI().requestDynamicList(detailInfo, complete: { [weak self](response) in
            YD_NewPersonGuideManager.startGuide("servant-guide", mainGuideInfos: [["image" :"guide-servant-1","insets": UIEdgeInsetsMake(379-54, 25, 8888, -25)]], secGuideInfos: nil)
            
            if let models = response as? [ServantDynamicModel] {
                self?.dataArray = models
                self?.endRefresh()
            }
            if self?.dataArray.count < 10 {
                self?.noMoreData()
            }
            }, error: { [weak self](error) in
                self?.endRefresh()
            })
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
    }
    
    // 加载数据
    func footerRefresh() {
        
        pageNum += 1
        let detailInfo:ServantInfoModel = ServantInfoModel()
        detailInfo.uid_ = servantInfo!.uid_
        detailInfo.page_num_ = pageNum
        detailInfo.page_count_ = 10
        
        APIHelper.servantAPI().requestDynamicList(detailInfo, complete: { [weak self](response) in
            
            if let models = response as? [ServantDynamicModel] {
                self?.dataArray += models
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
    
    // 停止刷新
    func endRefresh() {
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
        tableView!.reloadData()
    }
    
    func noMoreData() {
        endRefresh()
        footer.state = .NoMoreData
        footer.setTitle("", forState: .NoMoreData)
    }
    
    // MARK: - 加微信和关注按钮
    func attentionAction(sender: UIButton) {
        
        if sender.selected {
            // 取消关注
            dismissAttention()
        }else {
            // 加关注
            addAttention()
        }
    }
    
    func addMyWechatAccount() {
        // 加微信
        let relationAid = RelationAidVC()
        relationAid.userInfo  = servantInfo!
        //detailInfo为nil 暂时注销
        relationAid.to_uid = (servantInfo?.uid_)!
        navigationController?.pushViewController(relationAid, animated: true)
    }
    
    // 查询关注状态
    func updateFollowStatus() {
        
        let req = FollowModel()
        req.follow_to_ = (servantInfo?.uid_)!
        req.follow_type_ = 3
        APIHelper.followAPI().followStatus(req, complete: { [weak self](response) in
            
            let model:FollowedModel = response as! FollowedModel
            if model.result_ == 0 {
                self!.follow = true
            }else {
                self!.follow = false
            }
            }, error: nil)
    }
    
    // 加关注
    func addAttention() {
        let req = FollowModel()
        req.follow_to_ = (servantInfo?.uid_)!
        req.follow_type_ = 1
        APIHelper.followAPI().followStatus(req, complete: { [weak self](response) in
            
            let model:FollowedModel = response as! FollowedModel
            if model.result_ == 0 {
                self!.follow = true
            }
            self!.headerView!.uploadAttentionStatus(self!.follow)
            self?.updateFollowCount()
            SVProgressHUD.showSuccessMessage(SuccessMessage: "关注成功", ForDuration: 1.5, completion: {
            })
            
            }, error: nil)
    }
    
    // 取关
    func dismissAttention() {
        
        let req = FollowModel()
        req.follow_to_ = (servantInfo?.uid_)!
        req.follow_type_ = 2
        APIHelper.followAPI().followStatus(req, complete: { [weak self](response) in
            
            let model:FollowedModel = response as! FollowedModel
            if model.result_ == 0 {
                self!.follow = false
            }
            self!.headerView!.uploadAttentionStatus(self!.follow)
            self?.updateFollowCount()
            SVProgressHUD.showSuccessMessage(SuccessMessage: "取消关注成功", ForDuration: 1.5, completion: nil)
        }, error: nil)
    }
    
    // 查询粉丝数量
    func updateFollowCount() {
        let req = FollowCountRequestModel()
        req.uid_ = servantInfo!.uid_
        req.type_ = 2
        APIHelper.followAPI().followCount(req, complete: {(response) in
            
            let model = response as! FollowCountModel
            let count = model.follow_count_
            self.fansCount = count
            self.headerView?.updateFansCount(count)
            }, error: nil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 点赞
    func servantIsLikedAction(sender: UIButton, model: ServantDynamicModel) {
        
        let req = ServantThumbUpModel()
        req.dynamic_id_ = model.dynamic_id_
        
        APIHelper.followAPI().servantThumbup(req, complete: { (response) in
            
            let result = response as! ServantThumbUpResultModel
            
            let likecount = result.dynamic_like_count_
            if result.result_ == 0 {
                sender.selected = true
                sender.setTitle(String(likecount), forState: .Selected)
                model.is_liked_ = 1
            } else if result.result_ == 1 {
                sender.selected = false
                sender.setTitle(String(likecount), forState: .Normal)
                model.is_liked_ = 0
            }
            model.dynamic_like_count_ = likecount
            self.tableView?.reloadData()
            
            }, error: nil)
    }
    
    // 图片点击放大
    func servantImageDidClicked(model: ServantDynamicModel, index: Int) {
        // 解析图片链接
        let urlString:String = model.dynamic_url_!
        let imageUrls:NSArray = urlString.componentsSeparatedByString(",")
        
        // 显示图片
        PhotoBroswerVC.show(self, type: PhotoBroswerVCTypePush , index: UInt(index)) {() -> [AnyObject]! in
            
            let photoArray:NSMutableArray = NSMutableArray()
            let count:Int = imageUrls.count
            
            for i  in 0..<count {
                
                let model: PhotoModel = PhotoModel.init()
                model.mid = UInt(i) + 1
                model.image_HD_U = imageUrls.objectAtIndex(i) as! String
                photoArray.addObject(model)
            }
            
            return photoArray as [AnyObject]
        }
    }
    
    // 举报动态
    func servantReport(dynamicId: Int) {
        
        let alert:UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancle:UIAlertAction = UIAlertAction.init(title: "取消", style: .Cancel) { (action) in
        }
        let certain:UIAlertAction = UIAlertAction.init(title: "举报", style: .Default) { [weak self](action) in
            
            // 进入举报页面
            let reportView:ServantReportViewController = ServantReportViewController.init()
            reportView.reportUId = self!.servantInfo?.uid_
            reportView.dynamicId = dynamicId
            self!.navigationController?.pushViewController(reportView, animated: true)
        }
        
        alert.addAction(cancle)
        alert.addAction(certain)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
