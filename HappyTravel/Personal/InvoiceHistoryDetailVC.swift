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
class InvoiceHistoryDetailVC: UIViewController {
    
    var invoice_id_ = 0
    var invoice_status = 0
    var headerView:InvouiceHistoryDetailHeader?
    var tableView:UITableView?
    var historyDetailModel: InvoiceDetailModel?
    // 每个分区行数
    var rows:Array = [5, 3, 1]
    var titles =  [["发票抬头", "收件人", "联系电话", "所在区域", "收件地址"],
                   ["发票类型","发票金额","申请时间"]]
    /// 开票类型
    var invoiceTypes = [1 : "差旅费",
                        2 :"文体用品",
                        3 : "餐饮发票",
                        4 : "其他"]

    lazy var dateFormatter:NSDateFormatter = {
        var dateFomatter = NSDateFormatter()
        dateFomatter.dateFormat = "YYYY.MM.dd hh:mm"
        return dateFomatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "开票详情"
        
        initViews()
        
        let mode = InvoiceDetailBaseInfo()
        mode.invoice_id_ = Int64(invoice_id_)
        APIHelper.consumeAPI().invoiceDetail(mode, complete: { (response) in
            if let detailMode = response as? InvoiceDetailModel {
                DataManager.insertData(detailMode)
                self.historyDetailModel = detailMode
                self.headerView?.setupInfo(Int(self.historyDetailModel!.invoice_time_), invoiceSatus: self.invoice_status)
            }
            self.tableView?.reloadData()
            }, error: { (err) in
        })
    }
    
    func initViews() {
        tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .None
        tableView?.estimatedRowHeight = 70
        tableView?.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView!)
        tableView?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
        headerView = InvouiceHistoryDetailHeader.init(frame: CGRectMake(0, 0,  UIScreen.mainScreen().bounds.size.width, 65))
        tableView?.tableHeaderView = headerView
        tableView?.registerClass(InvoiceHistoryDetailCustomCell.self, forCellReuseIdentifier: "detailCustomCell")
        tableView?.registerClass(InvoiceHistoryDetailNormalCell.self, forCellReuseIdentifier: "detailNormalCell")
    }
    
}


extension InvoiceHistoryDetailVC:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 70
        }
        
        return 44
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("detailCustomCell", forIndexPath: indexPath) as! InvoiceHistoryDetailCustomCell
            if historyDetailModel != nil {
                cell.setupData((historyDetailModel?.order_num_)!, first_time_: Int((historyDetailModel?.final_time_)!), final_time_: Int((historyDetailModel?.final_time_)!))
            }
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("detailNormalCell", forIndexPath: indexPath) as! InvoiceHistoryDetailNormalCell
        
        let last = indexPath.row == rows[indexPath.section] - 1 ? true : false

        /**
         - 填充cell数据:
         */
        cell.setTitleLabelText(titles[indexPath.section][indexPath.row], isLast:last)
        
        if historyDetailModel != nil {
            var text = ""
            var isPrice = false
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0:
                    text = (historyDetailModel?.title_)!
                    break
                case 1:
                    text = (historyDetailModel?.user_name_)!
                    break
                case 2:
                    text = (historyDetailModel?.user_mobile_)!
                    break
                case 3:
                    text = (historyDetailModel?.area_)!
                    break
                case 4:
                    text = (historyDetailModel?.addr_detail_)!
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    if historyDetailModel?.invoice_type_ > 0  {
                        text = invoiceTypes[(historyDetailModel?.invoice_type_)!]!
                    }
                    break
                case 1:
                    text = String(historyDetailModel!.total_price_)
                    isPrice = true
                    break
                case 2:
                    text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double((historyDetailModel?.invoice_time_)!)))
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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {

            let includeVC = InvoiceIncludeServiceVC()
            includeVC.oid_str_ =  historyDetailModel?.oid_str_
            navigationController?.pushViewController(includeVC, animated: true)
        }
    }
    
}
