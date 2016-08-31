//
//  DistanceOfTravelVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/24.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class DistanceOfTravelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var segmentSC:UISegmentedControl?
    var table:UITableView?
    var messageInfo:Array<UserInfo>? = []
    var segmentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "我的行程"
        
        initView()
    }
    
    func initView() {
        let segmentBGV = UIImageView()
        segmentBGV.image = UIImage.init(named: "head-bg")?.imageWithAlignmentRectInsets(UIEdgeInsetsMake(128, 0, 0, 0))
        view.addSubview(segmentBGV)
        segmentBGV.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(60)
        }
        
        let segmentItems = ["商务游", "高端游"]
        segmentSC = UISegmentedControl(items: segmentItems)
        segmentSC!.tag = 1001
        segmentSC!.addTarget(self, action: #selector(DistanceOfTravelVC.segmentChange), forControlEvents: UIControlEvents.ValueChanged)
        segmentSC!.selectedSegmentIndex = 0
        segmentSC!.layer.masksToBounds = true
        segmentSC?.layer.cornerRadius = 5
        segmentSC?.backgroundColor = UIColor.clearColor()
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        segmentSC!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        segmentSC?.tintColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
        view.addSubview(segmentSC!)
        segmentSC!.snp_makeConstraints { (make) in
            make.center.equalTo(segmentBGV)
            make.height.equalTo(30)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0)
        }
        
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(DistanceOfTravelCell.self, forCellReuseIdentifier: "DistanceOfTravelCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(segmentBGV.snp_bottom)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
        return messageInfo!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DistanceOfTravelCell", forIndexPath: indexPath) as! DistanceOfTravelCell
        cell.setInfo(nil)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func segmentChange(sender: AnyObject?) {
        segmentIndex = (sender?.selectedSegmentIndex)!
        table?.reloadData()
    }
    
}
