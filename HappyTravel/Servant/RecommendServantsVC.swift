//
//  RecommendServantsVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/22.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class RecommendServantsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ServantIntroCellDelegate {
    
    var servantsTable:UITableView?
    var servantsInfo:Array<UserInfo>? = []
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "推荐服务者"
        
        initView()
    }
    
    func initView() {
        servantsTable = UITableView(frame: CGRectZero, style: .Plain)
        servantsTable?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        servantsTable?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        servantsTable?.delegate = self
        servantsTable?.dataSource = self
        servantsTable?.estimatedRowHeight = 256
        servantsTable?.rowHeight = UITableViewAutomaticDimension
        servantsTable?.separatorStyle = .None
        servantsTable?.registerClass(ServantIntroCell.self, forCellReuseIdentifier: "ServantIntroCell")
        view.addSubview(servantsTable!)
        servantsTable?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servantsInfo!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServantIntroCell", forIndexPath: indexPath) as! ServantIntroCell
        cell.delegate = self
        for (index, userInfo) in servantsInfo!.enumerate() {
            if indexPath.row == index {
                cell.setInfo(userInfo)
            }
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ServantIntroCellDeleagte
    func chatAction(servantInfo: UserInfo?) {
        let chatVC = ChatVC()
        chatVC.servantInfo = servantInfo
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
