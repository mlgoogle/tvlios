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


/**
 * 15158110304
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
    var dynamicListModel:ServantDynamicListModel?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    // 头视图
    var headerView:ServantHeaderView?
    
    // 是否关注状态
    var follow = false
    
    
    
    // MARK: - 函数方法
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // 查询关注状态并更新UI
        updateFollowStatus()
        // 查询粉丝数
        updateFollowCount()
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
    // 15158110034
    // 查询动态列表
    func addData() {
        
        let servantInfo:ServantInfoModel = ServantInfoModel()
        servantInfo.uid_ = (personalInfo?.uid_)!
        servantInfo.page_num_ = 0
        
        APIHelper.servantAPI().requestDynamicList(servantInfo, complete: { [weak self](response) in
            
            // 没有动态
            if response == nil {
                self?.tableView?.reloadData()
            }else {
                // 有动态
                self!.dynamicListModel = (response as! ServantDynamicListModel)
                
                self?.tableView?.reloadData()
            }
            
            }, error: nil)
        
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
        // 只有一条文字的Cell展示
        tableView?.registerClass(ServantOneLabelCell.self, forCellReuseIdentifier: "ServantOneLabelCell")
        // 只有一张图片的Cell展示
        tableView?.registerClass(ServantOnePicCell.self, forCellReuseIdentifier: "ServantOnePicCell")
        // 复合Cell展示
        tableView?.registerClass(ServantPicAndLabelCell.self, forCellReuseIdentifier: "ServantPicAndLabelCell")
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
//        return (dataArray?.count)!
        if dynamicListModel == nil {
            return 0
        }
        return (dynamicListModel?.dynamic_list_.count)!
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        /*  只有文字的cell  */
//        let cell = tableView.dequeueReusableCellWithIdentifier("ServantOneLabelCell", forIndexPath: indexPath) as! ServantOneLabelCell
//        cell.selectionStyle = .None
//        if indexPath.row < dynamicListModel?.dynamic_list_.count {
//            
//            cell.headerView?.kf_setImageWithURL(NSURL.init(string: (personalInfo?.head_url_)!))
//            cell.nameLabel?.text = personalInfo?.nickname_
//            
//            let dynamicModel:servantDynamicModel = (dynamicListModel?.dynamic_list_[indexPath.row])!
//            let textString = dynamicModel.dynamic_text_
//            cell.detailLabel?.text = textString
//        }
        
        /*  只有一张图片的cell  */
        let cell = tableView.dequeueReusableCellWithIdentifier("ServantOnePicCell", forIndexPath: indexPath) as! ServantOnePicCell
        cell.selectionStyle = .None
        if indexPath.row < dynamicListModel?.dynamic_list_.count {
            cell.headerView?.kf_setImageWithURL(NSURL.init(string: (personalInfo?.head_url_)!))
            cell.nameLabel?.text = personalInfo?.nickname_
            
            let dynamicModel:servantDynamicModel = (dynamicListModel?.dynamic_list_[indexPath.row])!
            let imageUrls = dynamicModel.dynamic_url_
            cell.updateImg(imageUrls!)
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        headerView = ServantHeaderView.init(frame: CGRectMake(0, 0, ScreenWidth, 379))
        headerView!.headerDelegate = self
        headerView!.didAddNewUI(personalInfo!)
        return headerView
//=======
//        let header:ServantHeaderView = ServantHeaderView.init(frame: CGRectMake(0, 0, ScreenWidth, 379))
//        header.didAddNewUI(personalInfo!)
//        header.headerDelegate = self
//        return header
//>>>>>>> 7b53b1e0ad1a2ca4edb76c6b2d3f14f538d616b2
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
            
            let titleString = personalInfo?.nickname_
            topTitle?.text = titleString
            leftBtn?.setImage(UIImage.init(named: "nav-back-select"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "nav-jb-select"), forState: .Normal)
        }
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
        relationAid.userInfo  = personalInfo!
        //detailInfo为nil 暂时注销
//        relationAid.detailInfo = detailInfo!
        navigationController?.pushViewController(relationAid, animated: true)
    }
    
    // 查询关注状态
    func updateFollowStatus() {
        
        let req = FollowModel()
        req.follow_to_ = (personalInfo?.uid_)!
        req.follow_type_ = 3
        APIHelper.followAPI().followStatus(req, complete: { [weak self](response) in
            
            let model:FollowedModel = response as! FollowedModel
            if model.result_ == 0 {
                self!.follow = true
            }else {
                self!.follow = false
            }
            self!.headerView!.uploadAttentionStatus(self!.follow)
            
            }, error: nil)
    }
    
    // 加关注
    func addAttention() {
        let req = FollowModel()
        req.follow_to_ = (personalInfo?.uid_)!
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
        req.follow_to_ = (personalInfo?.uid_)!
        req.follow_type_ = 2
        APIHelper.followAPI().followStatus(req, complete: { [weak self](response) in
            
            let model:FollowedModel = response as! FollowedModel
            if model.result_ == 0 {
                self!.follow = false
            }
            self!.headerView!.uploadAttentionStatus(self!.follow)
            self?.updateFollowCount()
            SVProgressHUD.showSuccessMessage(SuccessMessage: "取消关注成功", ForDuration: 1.5, completion: {
            })
            
            }, error: nil)
    }
    
    // 查询粉丝数量
    func updateFollowCount() {
        let req = FollowCountRequestModel()
        req.uid_ = personalInfo!.uid_
        req.type_ = 2
        APIHelper.followAPI().followCount(req, complete: {(response) in
            
            let model = response as! FollowCountModel
            let count = model.follow_count_
            self.headerView?.updateFansCount(count)
            
            }, error: nil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
