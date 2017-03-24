//
//  ServantReportViewController.swift
//  HappyTravel
//
//  Created by 千山暮雪 on 2017/3/22.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD

class ServantReportViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate{
    
    var tableView:UITableView?
    var dataArray:NSArray?
    var cellIndex:NSInteger? // 选中cell的index 和 种类id (0~5)
    var reportUId:Int?
    var dynamicId:Int?
    var footerView:ServantReportFooterView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        title = "举报"
        
        dataArray = ["淫秽色情类","诈骗类","政治有害类","赌博","暴恐类","其他有害类"]
        cellIndex = 0
        addViews()
    }
    
    func addViews() {
        
        tableView = UITableView.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 85), style: .Grouped)
        tableView?.separatorStyle = .SingleLine
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = 45
        view.addSubview(tableView!)
        tableView?.registerClass(ServantReportCell.self, forCellReuseIdentifier: "ServantReportCell")
        tableView?.snp_makeConstraints(closure: { (make) in
            make.left.right.top.equalTo(self.view)
            make.height.equalTo(ScreenHeight - 64 - 85)
        })
        
        let bottomView:UIView = UIView.init()
        bottomView.backgroundColor = UIColor.whiteColor()
        view.addSubview(bottomView)
        bottomView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(85)
        }
        
        let certainBtn:UIButton = UIButton.init(type: .Custom)
        bottomView.addSubview(certainBtn)
        certainBtn.backgroundColor = UIColor.init(decR: 252, decG: 163, decB: 17, a: 1)
        certainBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        certainBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        certainBtn.setTitle("确定", forState: .Normal)
        certainBtn.layer.masksToBounds = true
        certainBtn.layer.cornerRadius = 23
        certainBtn.snp_makeConstraints { (make) in
            make.top.equalTo(bottomView).offset(10)
            make.left.equalTo(bottomView).offset(16)
            make.right.equalTo(bottomView).offset(-16)
            make.height.equalTo(46)
        }
        certainBtn.addTarget(self, action: #selector(self.certainAction), forControlEvents: .TouchUpInside)
        
    }
    
    //MARK: UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataArray?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:ServantReportCell = tableView.dequeueReusableCellWithIdentifier("ServantReportCell") as! ServantReportCell
        cell.selectionStyle = .None
        if indexPath.row < dataArray?.count {
            let title:String = dataArray![indexPath.row] as! String
            cell.addTitle(title)
        }
        
        if indexPath.row == 0 {
            cell.didSelected()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header:UIView = UIView.init(frame: CGRectMake(0, 0, ScreenWidth, 55))
        header.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        
        let title:UILabel = UILabel.init(frame: CGRectMake(14, 0, 150, 55))
        title.font = UIFont.systemFontOfSize(16)
        title.textColor = UIColor.init(decR: 153, decG: 153, decB: 153, a: 1)
        title.text = "请选择举报原因"
        header.addSubview(title)
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        footerView = ServantReportFooterView.init(frame:CGRectMake(0, 0, ScreenWidth, 208))
        footerView?.textView?.delegate = self
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 228
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if cellIndex == indexPath.row {
            return
        }
        // 取消上一个选择
        let oldIndex:NSIndexPath = NSIndexPath.init(forRow: cellIndex!, inSection: 0)
        let oldCell:ServantReportCell = tableView.cellForRowAtIndexPath(oldIndex) as! ServantReportCell
        oldCell.didDisselecd()
        
        // 选中这个cell
        let newCell:ServantReportCell = tableView.cellForRowAtIndexPath(indexPath) as! ServantReportCell
        newCell.didSelected()
        
        // 记录选择的 cellIndex
        cellIndex = indexPath.row
    }
    
    // 确定实现发布
    func certainAction() {
        print("~~~~~~ 确定举报~")
        
        let report:ServantReportModel = ServantReportModel()
        report.uid_ = reportUId!
        report.from_id_ = CurrentUser.uid_
        report.report_id_ = cellIndex!
        report.report_text_ = footerView?.textView?.text
        report.dynamic_id_ = dynamicId!
        APIHelper.servantAPI().servantReport(report, complete: { (response) in
            
            SVProgressHUD.showSuccessMessage(SuccessMessage: "举报成功！", ForDuration: 1.5, completion: {
                self.navigationController?.popViewControllerAnimated(true)
            })
            }) { (error) in
                SVProgressHUD.showErrorMessage(ErrorMessage: "举报失败，请稍后再试~", ForDuration: 1.5, completion: {
                })
        }
    }
    
    
    //MARK:UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        
        if textView.text.characters.count == 0 {
//            textView.addSubview(placeholder!)
            textView.text = "请输入~~"
        }else {
//            placeholder?.removeFromSuperview()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        UIView.animateWithDuration(0.3) {
            self.tableView?.frame = CGRectMake((self.tableView?.frame.origin.x)!, (self.tableView?.frame.origin.y)! - 150 , ScreenWidth, (self.tableView?.frame.size.height)!)
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        UIView.animateWithDuration(0.3) {
            self.tableView?.frame = CGRectMake((self.tableView?.frame.origin.x)!, (self.tableView?.frame.origin.y)! + 150 , ScreenWidth, (self.tableView?.frame.size.height)!)
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
