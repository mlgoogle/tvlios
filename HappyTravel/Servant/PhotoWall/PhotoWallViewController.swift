//
//  PhotoWallViewController.swift
//  viossvc
//
//  Created by 陈奕涛 on 16/12/1.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import Foundation
import SVProgressHUD
import MJRefresh


class PhotoWallViewController: UITableViewController, PhotoWallCellDelegate {
    
    var pageIndex = 1
    var date:[String] = []
    var array:[AnyObject] = []
    var curModel:PhotoWallModel?
    var firstLaunch = true

    var timer:NSTimer?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    var info:UserInfoModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.registerClass(PhotoWallCell.self, forCellReuseIdentifier: "PhotoWallCell")
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
    }
    
    func headerRefresh() {
        pageIndex = 1
        didRequest(1)
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
    }
    
    func footerRefresh() {
        pageIndex += 1
        didRequest(pageIndex)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        headerRefresh()
    }
    
    deinit {
        endRefresh()
        SVProgressHUD.dismiss()
    }
    
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
    }
    
    func didRequest(pageIndex: Int) {
        guard info != nil else {return}
        let dict = ["uid_": info!.uid_,
                    "size_": 20,
                    "num_": pageIndex]
        let model = PhotoWallRequestModel(value: dict)
        APIHelper.servantAPI().requestPhotoWall(model, complete: { (response) in
            
            self.didRequestComplete(response as? PhotoWallModel)

            }) { (error) in
                
        }

    }

    func didRequestComplete(data: AnyObject?) {
        if let model = data as? PhotoWallModel {
            if pageIndex == 1 {
                curModel = model
                header.endRefreshing()
                footer.state = .Idle
            } else {
                if model.photo_list_.count > 0 {
                    for photoModel in model.photo_list_ {
                        curModel?.photo_list_.append(photoModel)
                    }
                    footer.endRefreshing()
                } else {
                    footer.endRefreshing()
                    footer.state = .NoMoreData
                    return
                }
            }
        } else {
            if pageIndex == 1 {
                header.endRefreshing()
            } else {
                footer.endRefreshing()
                footer.state = .NoMoreData
            }
            
            return
        }

        
        array.removeAll()
        date.removeAll()
        
        if curModel != nil && curModel?.photo_list_.count > 0 {
            var subArray:[PhModel] = []
            var day = ""
            for photo in curModel!.photo_list_ {
                let time = photo.upload_time_!
                if #available(iOS 9.0, *) {
                    let end = time.localizedStandardRangeOfString(" ")
                    let sub = time.substringToIndex(end!.startIndex)
                    if day == "" {
                        day = sub
                    }
                    if day != sub {
                        array.append(subArray)
                        date.append(day)
                        subArray = []
                        day = sub
                    }
                    subArray.append(photo)
                } else {
                    // Fallback on earlier versions
                }
            }
            array.append(subArray)
            date.append(day)
            tableView.reloadData()
        }
        
    }
    
    //MARK: - TableView
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        
        let line = UIView()
        line.backgroundColor = colorWithHexString("#0x141f31")
        view.addSubview(line)
        line.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(40)
            if section == 0 {
                make.top.equalTo(view.snp_centerY).offset(5)
            } else {
                make.top.equalTo(view)
            }
            make.bottom.equalTo(view)
            make.width.equalTo(3)
        })
        
        let point = UIView()
        point.backgroundColor = line.backgroundColor
        point.layer.masksToBounds = true
        point.layer.cornerRadius = 15 / 2.0
        view.addSubview(point)
        point.snp_makeConstraints(closure: { (make) in
            if section == 0 {
                make.centerY.equalTo(line.snp_top)
                make.centerX.equalTo(line.snp_centerX)
            } else {
                make.center.equalTo(line)
            }
            make.width.equalTo(15)
            make.height.equalTo(15)
        })
        
        let title = UILabel()
        title.backgroundColor = UIColor.clearColor()
        title.text = date[section]
        title.font = UIFont.systemFontOfSize(15)
        view.addSubview(title)
        title.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(point)
            make.left.equalTo(point.snp_right).offset(14)
        })
        
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return array.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = array[section].count
        return cnt / 3 + (cnt % 3 > 0 ? 1 : 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoWallCell", forIndexPath: indexPath) as? PhotoWallCell
        if cell != nil {
            cell?.delegate = self
            let secArr = array[indexPath.section]
            var arr:[AnyObject] = []
            for i in indexPath.row*3..<secArr.count {
                arr.append(secArr[i])
            }
            cell?.update(arr)
        }
        
        return cell ?? PhotoWallCell()
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    //MARK: - PhotoWallCellDelegate
    func touchedPhotoItem(photoInfo: PhModel) {
        PhotoPreviewView.showOnline(photoInfo)
    }
    
}
