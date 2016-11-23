//
//  RecommendServantsVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/22.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class RecommendServantsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ServantIntroCellDelegate {
    //记录是邀约？预约？   ture为邀约  false 为预约
    var isNormal = true
    
    var servantsTable:UITableView?
    var servantsInfo:Array<UserInfo>? = []
    var appointment_id_ = 0
    
    var servantInfo:Dictionary<Int, UserInfo> = [:]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "推荐服务者"
        
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        registerNotice()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    func initView() {
        servantsTable = UITableView(frame: CGRect.zero, style: .plain)
        servantsTable?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        servantsTable?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        servantsTable?.delegate = self
        servantsTable?.dataSource = self
        servantsTable?.estimatedRowHeight = 256
        servantsTable?.rowHeight = UITableViewAutomaticDimension
        servantsTable?.separatorStyle = .none
        servantsTable?.register(ServantIntroCell.self, forCellReuseIdentifier: "ServantIntroCell")
        view.addSubview(servantsTable!)
        servantsTable?.snp_makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
    }
    
    func registerNotice(){
            NotificationCenter.default.addObserver(self, selector: #selector(RecommendServantsVC.servantDetailInfo(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ServantDetailInfo), object: nil)
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "最佳服务者"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = colorWithHexString("#666666")
            headerView.textLabel?.font = UIFont.systemFont(ofSize: S13)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servantsInfo!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServantIntroCell", for: indexPath) as! ServantIntroCell
        cell.delegate = self
        let userInfo = servantsInfo![indexPath.row]
        cell.setInfo(userInfo)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ServantIntroCellDeleagte
    func chatAction(_ servantInfo: UserInfo?) {
        let dict:Dictionary<String, AnyObject> = ["uid_": servantInfo!.uid as AnyObject]
        SocketManager.sendData(.getServantDetailInfo, data:dict as AnyObject?)
        self.servantInfo[(servantInfo?.uid)!] = servantInfo
    }
    /**
     服务者详情回调
     
     - parameter notification:
     */
    func servantDetailInfo(_ notification: Notification?) {
        
        let data = notification?.userInfo!["data"]
        if data!["error_"]! != nil {
            XCGLogger.error("Get UserInfo Error:\(data!["error"])")
            return
        }

        servantInfo[data!["uid_"] as! Int]?.setInfo(.servant, info: data as? Dictionary<String, AnyObject>)
        let user = servantInfo[data!["uid_"] as! Int]
        DataManager.updateUserInfo(user!)
        let servantPersonalVC = ServantPersonalVC()
        servantPersonalVC.isNormal = isNormal
        servantPersonalVC.appointment_id_ = appointment_id_
        servantPersonalVC.personalInfo = DataManager.getUserInfo(data!["uid_"] as! Int)
        navigationController?.pushViewController(servantPersonalVC, animated: true)
        
    }
}
