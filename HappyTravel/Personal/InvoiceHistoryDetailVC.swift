//
//  InvoiceHistoryDetailVC.swift
//  HappyTravel
//
//  Created by J-bb on 16/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import RealmSwift
import XCGLogger
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class InvoiceHistoryDetailVC: UIViewController {
    
    var invoice_id_ = 0
    var headerView:InvouiceHistoryDetailHeader?
    var tableView:UITableView?
    var historyInfo:InvoiceHistoryInfo?
    // 每个分区行数
    var rows:Array = [5, 3, 1]
    var titles =  [["发票抬头", "收件人", "联系电话", "所在区域", "收件地址"],
                   ["发票类型","发票金额","申请时间"]]
    /// 开票类型
    var invoiceTypes = [1 : "差旅费",
                        2 :"文体用品",
                        3 : "餐饮发票",
                        4 : "其他"]

    lazy var dateFormatter:DateFormatter = {
        var dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "YYYY.MM.dd hh:mm"
        return dateFomatter
    }()

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        regitserNotification()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "开票详情"
        
        initViews()
        SocketManager.sendData(.invoiceDetailRequest, data: ["invoice_id_" : invoice_id_])
    }
    
    func initViews() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.estimatedRowHeight = 70
        tableView?.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
        headerView = InvouiceHistoryDetailHeader.init(frame: CGRect(x: 0, y: 0,  width: UIScreen.main.bounds.size.width, height: 65))
        tableView?.tableHeaderView = headerView
        tableView?.register(InvoiceHistoryDetailCustomCell.self, forCellReuseIdentifier: "detailCustomCell")
        tableView?.register(InvoiceHistoryDetailNormalCell.self, forCellReuseIdentifier: "detailNormalCell")
    }
    
    func regitserNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceHistoryDetailVC.receivedData(_:)), name: NSNotification.Name(rawValue: NotifyDefine.InvoiceDetailReply), object: nil)
    }
    
    /**
     回调
     - parameter notification:
     */
    func receivedData(_ notification:Notification) {
        
        if let dict = notification.userInfo!["data"] {
            let history = InvoiceHistoryInfo(value: dict)
            DataManager.updateInvoiceHistoryInfo(history)
            historyInfo = DataManager.getInvoiceHistoryInfo(invoice_id_)
            headerView?.setupInfo((historyInfo?.invoice_time_)!, invoiceSatus: historyInfo!.invoice_status_)
            tableView?.reloadData()
        }
        
    }
    
}


extension InvoiceHistoryDetailVC:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 70
        }
        
        return 44
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCustomCell", for: indexPath) as! InvoiceHistoryDetailCustomCell
            if historyInfo != nil {
                cell.setupData((historyInfo?.order_num_)!, first_time_: (historyInfo?.final_time_)!, final_time_: (historyInfo?.final_time_)!)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailNormalCell", for: indexPath) as! InvoiceHistoryDetailNormalCell
        
        let last = indexPath.row == rows[indexPath.section] - 1 ? true : false

        /**
         - 填充cell数据:
         */
        cell.setTitleLabelText(titles[indexPath.section][indexPath.row], isLast:last)
        
        if historyInfo != nil {
            var text = ""
            var isPrice = false
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0:
                    text = (historyInfo?.title_)!
                    break
                case 1:
                    text = (historyInfo?.user_name_)!
                    break
                case 2:
                    text = (historyInfo?.user_mobile_)!
                    break
                case 3:
                    text = (historyInfo?.area_)!
                    break
                case 4:
                    text = (historyInfo?.addr_detail_)!
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    if historyInfo?.invoice_type_ > 0  {
                        text = invoiceTypes[(historyInfo?.invoice_type_)!]!
                    }
                    break
                case 1:
                    text = String(historyInfo!.total_price_)
                    isPrice = true
                    break
                case 2:
                    text = dateFormatter.string(from: Date(timeIntervalSince1970: Double((historyInfo?.invoice_time_)!)))
                    break
                default:
                    break
                }
                
            }
            cell.setInfoLabelText(text, isPrice:isPrice)
//            setupCellInfo(indexPath)
        }

        
        return cell
        
    }
    


//    /**
//     - 填充cell数据:
//     */
//    func setupCellInfo(indexPath:NSIndexPath) {
//        let cell = tableView?.cellForRowAtIndexPath(indexPath) as! InvoiceHistoryDetailNormalCell
//
//
//    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {

            let includeVC = InvoiceIncludeServiceVC()
            includeVC.oid_str_ =  historyInfo?.oid_str_
            navigationController?.pushViewController(includeVC, animated: true)
        }
    }
    
}
