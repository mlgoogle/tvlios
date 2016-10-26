//
//  RechargeVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

class RechargeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table:UITableView?
    var sureBtn:UIButton?
    var selectedIndex = 0
    
    let tags = ["amountLab": 1001,
                "amountTextField": 1002,
                "channelIcon": 1003,
                "channelLab": 1004,
                "separateLine": 1005,
                "payBtn": 1006,
                "selectedIcon": 1007]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "充值"
        
        initView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RechargeVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RechargeVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        table?.separatorStyle = .None
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
        hideKeyboard()
    }
    
    func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(InvoiceDetailVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 1
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "支付方式"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("AmountCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.contentView.userInteractionEnabled = true
                cell?.userInteractionEnabled = true
                cell?.selectionStyle = .None
            }
            
            var amountLab = cell?.contentView.viewWithTag(tags["amountLab"]!) as? UILabel
            if amountLab == nil {
                amountLab = UILabel()
                amountLab?.tag = tags["amountLab"]!
                amountLab?.backgroundColor = UIColor.clearColor()
                amountLab?.text = "金额"
                amountLab?.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(amountLab!)
                amountLab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(20)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                    make.width.equalTo(30)
                })
            }
        
            var amountTextField = cell?.contentView.viewWithTag(tags["amountTextField"]!) as? UITextField
            if amountTextField == nil {
                amountTextField = UITextField()
                amountTextField?.tag = tags["amountTextField"]!
                amountTextField?.backgroundColor = UIColor.clearColor()
                amountTextField?.placeholder = "请输入充值金额"
                amountTextField?.rightViewMode = .WhileEditing
                amountTextField?.clearButtonMode = .WhileEditing
                cell?.contentView.addSubview(amountTextField!)
                amountTextField?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(amountLab!.snp_right).offset(10)
                    make.top.equalTo(amountLab!)
                    make.bottom.equalTo(amountLab!)
                    make.right.equalTo(cell!.contentView).offset(-20)
                })
            }
            return cell!
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.contentView.userInteractionEnabled = true
                cell?.userInteractionEnabled = true
                cell?.selectionStyle = .None
            }
            
            var channelIcon = cell?.contentView.viewWithTag(tags["channelIcon"]!) as? UIImageView
            if channelIcon == nil {
                channelIcon = UIImageView()
                channelIcon?.tag = tags["channelIcon"]!
                channelIcon?.backgroundColor = UIColor.clearColor()
                cell?.contentView.addSubview(channelIcon!)
                channelIcon?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(20)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                    make.width.equalTo(25)
                    make.height.equalTo(25)
                })
            }
            
            var channelLab = cell?.contentView.viewWithTag(tags["channelLab"]!) as? UILabel
            if channelLab == nil {
                channelLab = UILabel()
                channelLab?.tag = tags["channelLab"]!
                channelLab?.backgroundColor = UIColor.clearColor()
                channelLab?.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(channelLab!)
                channelLab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(channelIcon!.snp_right).offset(10)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                })
            }
            
            var selectedIcon = cell?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIImageView
            if selectedIcon == nil {
                selectedIcon = UIImageView()
                selectedIcon?.tag = tags["selectedIcon"]!
                selectedIcon?.backgroundColor = UIColor.clearColor()
                cell?.contentView.addSubview(selectedIcon!)
                selectedIcon?.snp_makeConstraints(closure: { (make) in
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.centerY.equalTo(channelLab!)
                    make.width.equalTo(20)
                    make.height.equalTo(20)
                })
            }
            selectedIcon?.image = indexPath.row == selectedIndex ? UIImage.init(named: "pay-selected") : UIImage.init(named: "pay-unselect")
    
            if indexPath.row == 0 {
                channelIcon?.image = UIImage.init(named: "alipay")
                channelLab?.text = "支付宝支付"
            } else if indexPath.row == 1 {
                channelIcon?.image = UIImage.init(named: "wechat-pay")
                channelLab?.text = "微信支付"
            }
            
            var separateLine = cell?.contentView.viewWithTag(tags["separateLine"]!)
            if separateLine == nil {
                separateLine = UIView()
                separateLine?.tag = tags["separateLine"]!
                separateLine?.backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
                cell?.contentView.addSubview(separateLine!)
                separateLine?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(channelIcon!)
                    make.right.equalTo(cell!.contentView).offset(40)
                    make.bottom.equalTo(cell!.contentView).offset(0.5)
                    make.height.equalTo(1)
                })
            }
            separateLine?.hidden = indexPath.row == 0 ? false : true

            return cell!
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("PayCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.contentView.userInteractionEnabled = true
                cell?.userInteractionEnabled = true
                cell?.selectionStyle = .None
                cell?.backgroundColor = UIColor.clearColor()
                cell?.contentView.backgroundColor = UIColor.clearColor()
            }
            
            var payBtn = cell?.contentView.viewWithTag(tags["payBtn"]!) as? UIButton
            if payBtn == nil {
                payBtn = UIButton()
                payBtn?.tag = tags["payBtn"]!
                payBtn?.backgroundColor = UIColor.init(decR: 170, decG: 170, decB: 170, a: 1)
                payBtn?.setTitle("确认充值", forState: .Normal)
                payBtn?.layer.cornerRadius = 5
                payBtn?.layer.masksToBounds = true
                payBtn?.addTarget(self, action: #selector(RechargeVC.payAction(_:)), forControlEvents: .TouchUpInside)
                cell?.contentView.addSubview(payBtn!)
                payBtn?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(15)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-15)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                    make.height.equalTo(40)
                })
            }
            
            return cell!
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                XCGLogger.debug("余额")
            }
        } else if indexPath.section == 1 {
            selectedIndex = indexPath.row
            tableView.reloadData()
        } else if indexPath.section == 2 {
            
        }
    }
    
    
    //MARK: - UITextField
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 5 {
            return false
        }
        
        return true
    }
    
    func payAction(sender: UIButton) {
        DataManager.currentUser?.cash = 10
        let orderStr = "app_id=2016102102273564&biz_content=%7B%22timeout_express%22%3A%2230m%22%2C%22seller_id%22%3A%22%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22total_amount%22%3A%220.01%22%2C%22subject%22%3A%221%22%2C%22body%22%3A%22%E6%88%91%E6%98%AF%E6%B5%8B%E8%AF%95%E6%95%B0%E6%8D%AE%22%2C%22out_trade_no%22%3A%22BBCXFY4KAL3U6DB%22%7D&charset=utf-8&method=alipay.trade.app.pay&sign_type=RSA&timestamp=2016-09-01%2013%3A49%3A34&version=1.0&sign=imFFzjpv%2BUt8iPLyFmrUqTUceLKWBZmn%2Bixy4siNLs3VmIw5jNddnLf1V0JdtkVQgAUhNWiw8oDTVlv6HuUAHj7Ja0Rz%2BdsYcr4MzTiqy1NHYYvoLUVFOlQGy1QXU6bMzYnhrQnjjkTf0hnNJiy6fVEA7iPRFnWr8cScHgA2JZI%3D"
        AlipaySDK.defaultService().payOrder(orderStr, fromScheme: "ydTravrlAlipay", callback: { (data: [NSObject : AnyObject]!) in
            XCGLogger.debug("\(data)")
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}