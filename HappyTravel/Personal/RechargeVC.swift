//
//  RechargeVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import SwiftyJSON
import Alamofire
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


extension String {
    var MD5:String {
        let cString = self.cString(using: String.Encoding.utf8)
        let length = CUnsignedInt(
            self.lengthOfBytes(using: String.Encoding.utf8)
        )
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(cString!,length,result)
        return String(format:"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                      result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],
                      result[9],result[10],result[11],result[12],result[13],result[14],result[15])
    }
}

class RechargeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var table:UITableView?
    var payBtn:UIButton?
    var selectedIndex = 0
    var selectedIcon:UIImageView?
    var amount:String?
    var rechageID:String?
    var chargeNumber:Int?
    
    let tags = ["amountLab": 1001,
                "amountTextField": 1002,
                "channelIcon": 1003,
                "channelLab": 1004,
                "separateLine": 1005,
                "payBtn": 1006,
                "selectedIcon": 1007]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "充值"
        
        initView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(RechargeVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RechargeVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RechargeVC.wechatPaySuccessed(_:)), name: NSNotification.Name(rawValue: NotifyDefine.WeChatPaySuccessed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RechargeVC.wxPlaceOrderReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.WXplaceOrderReply), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RechargeVC.wxPayStatusReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.WXPayStatusReply), object: nil)
    }
    
    func wxPayStatusReply(_ notification: Notification) {
        if let dict = notification.userInfo {
            if let code = dict["return_code_"] as? Int {
                if code == 3 {
                    DataManager.currentUser!.cash = dict["user_cash_"] as! Int
                    let alert = UIAlertController.init(title: "支付结果", message: "支付成功!", preferredStyle: .alert)
                    
                    weak var weakSelf = self
                    let ok = UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 0.3)) / Double(NSEC_PER_SEC), execute: { () in
                            weakSelf!.navigationController?.popViewController(animated: true)
                        })
                        
                    })
                    
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func wxPlaceOrderReply(_ notification: Notification) {
        if let dict = notification.userInfo {
            jumpToBizPay(dict)
        }
    }
    
    func wechatPaySuccessed(_ notification: Notification) {
        let dict:[String: AnyObject] = ["uid_": DataManager.currentUser!.uid as AnyObject,
                                        "recharge_id_": Int(rechageID!)!,
                                        "pay_result_": 1]
        SocketManager.sendData(.clientWXPayStatusRequest, data: dict as AnyObject?)
        
    }
    
    func keyboardWillShow(_ notification: Notification?) {
        let frame = (notification!.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let inset = UIEdgeInsetsMake(0, 0, (frame?.size.height)!, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .grouped)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table?.separatorStyle = .none
        view.addSubview(table!)
        table?.snp_makeConstraints({ (make) in
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 1
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "支付方式"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "AmountCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .none
                cell?.contentView.isUserInteractionEnabled = true
                cell?.isUserInteractionEnabled = true
                cell?.selectionStyle = .none
            }
            
            var amountLab = cell?.contentView.viewWithTag(tags["amountLab"]!) as? UILabel
            if amountLab == nil {
                amountLab = UILabel()
                amountLab?.tag = tags["amountLab"]!
                amountLab?.backgroundColor = UIColor.clear
                amountLab?.text = "金额"
                amountLab?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(amountLab!)
                amountLab?.snp_makeConstraints({ (make) in
                    make.left.equalTo(cell!.contentView).offset(20)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                    make.width.equalTo(40)
                })
            }
        
            var amountTextField = cell?.contentView.viewWithTag(tags["amountTextField"]!) as? UITextField
            if amountTextField == nil {
                amountTextField = UITextField()
                amountTextField?.delegate = self
                amountTextField?.tag = tags["amountTextField"]!
                amountTextField?.backgroundColor = UIColor.clear
                if let chargeNum = chargeNumber {
                    amountTextField?.text = "\(chargeNum)"
                }else{
                    amountTextField?.placeholder = "请输入充值金额"
                }
                
                amountTextField?.rightViewMode = .whileEditing
                amountTextField?.keyboardType = .numberPad
                amountTextField?.clearButtonMode = .whileEditing
                cell?.contentView.addSubview(amountTextField!)
                amountTextField?.snp_makeConstraints({ (make) in
                    make.left.equalTo(amountLab!.snp_right).offset(10)
                    make.top.equalTo(amountLab!)
                    make.bottom.equalTo(amountLab!)
                    make.right.equalTo(cell!.contentView).offset(-20)
                })              }
            return cell!
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .none
                cell?.contentView.isUserInteractionEnabled = true
                cell?.isUserInteractionEnabled = true
                cell?.selectionStyle = .none
            }
            
            var channelIcon = cell?.contentView.viewWithTag(tags["channelIcon"]!) as? UIImageView
            if channelIcon == nil {
                channelIcon = UIImageView()
                channelIcon?.tag = tags["channelIcon"]!
                channelIcon?.backgroundColor = UIColor.clear
                cell?.contentView.addSubview(channelIcon!)
                channelIcon?.snp_makeConstraints({ (make) in
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
                channelLab?.backgroundColor = UIColor.clear
                channelLab?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(channelLab!)
                channelLab?.snp_makeConstraints({ (make) in
                    make.left.equalTo(channelIcon!.snp_right).offset(10)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                })
            }
            
            var selectedIcon = cell?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIImageView
            if selectedIcon == nil {
                selectedIcon = UIImageView()
                selectedIcon?.tag = tags["selectedIcon"]!
                selectedIcon?.backgroundColor = UIColor.clear
                cell?.contentView.addSubview(selectedIcon!)
                selectedIcon?.snp_makeConstraints({ (make) in
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.centerY.equalTo(channelLab!)
                    make.width.equalTo(20)
                    make.height.equalTo(20)
                })
            }
            selectedIcon?.image = indexPath.row == selectedIndex ? UIImage.init(named: "pay-selected") : UIImage.init(named: "pay-unselect")
            if indexPath.row == 0 {
                self.selectedIcon = selectedIcon
            }
    
            if indexPath.row == 1 {
                channelIcon?.image = UIImage.init(named: "alipay")
                channelLab?.text = "支付宝支付"
            } else if indexPath.row == 0 {
                channelIcon?.image = UIImage.init(named: "wechat-pay")
                channelLab?.text = "微信支付"
            }
            
            var separateLine = cell?.contentView.viewWithTag(tags["separateLine"]!)
            if separateLine == nil {
                separateLine = UIView()
                separateLine?.tag = tags["separateLine"]!
                separateLine?.backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
                cell?.contentView.addSubview(separateLine!)
                separateLine?.snp_makeConstraints({ (make) in
                    make.left.equalTo(channelIcon!)
                    make.right.equalTo(cell!.contentView).offset(40)
                    make.bottom.equalTo(cell!.contentView).offset(0.5)
                    make.height.equalTo(1)
                })
            }
            separateLine?.isHidden = indexPath.row == 0 ? false : true

            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "PayCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .none
                cell?.contentView.isUserInteractionEnabled = true
                cell?.isUserInteractionEnabled = true
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
            
            var payBtn = cell?.contentView.viewWithTag(tags["payBtn"]!) as? UIButton
            if payBtn == nil {
                payBtn = UIButton()
                payBtn?.tag = tags["payBtn"]!
                payBtn?.backgroundColor = UIColor.init(decR: 170, decG: 170, decB: 170, a: 1)
                payBtn?.setTitle("确认充值", for: UIControlState())
                payBtn?.layer.cornerRadius = 5
                payBtn?.layer.masksToBounds = true
                payBtn?.addTarget(self, action: #selector(RechargeVC.payAction(_:)), for: .touchUpInside)
                cell?.contentView.addSubview(payBtn!)
                payBtn?.snp_makeConstraints({ (make) in
                    make.left.equalTo(cell!.contentView).offset(15)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.right.equalTo(cell!.contentView).offset(-15)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                    make.height.equalTo(40)
                })
                self.payBtn = payBtn
                
            }
            
            if chargeNumber != nil {
                payBtn?.backgroundColor = UIColor.init(red: 32/255.0, green: 43/255.0, blue: 80/255.0, alpha: 1)
                payBtn?.isEnabled = true
            }else{
                payBtn?.backgroundColor = UIColor.init(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
                payBtn?.isEnabled = false
            }
            
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedIndex = indexPath.row
            selectedIcon?.image = UIImage.init(named: "pay-unselect")
            if let icon = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIImageView {
                icon.image = UIImage.init(named: "pay-selected")
                selectedIcon = icon
            }
        }
    }
    
    
    //MARK: - UITextField
    func textFieldDidEndEditing(_ textField: UITextField) {
        amount = textField.text
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        amount = ""
        payBtn?.backgroundColor = UIColor.init(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
        payBtn?.isEnabled = false
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            payBtn?.backgroundColor = UIColor.init(red: 32/255.0, green: 43/255.0, blue: 80/255.0, alpha: 1)
            payBtn?.isEnabled = true
        } else {
            payBtn?.backgroundColor = UIColor.init(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
            payBtn?.isEnabled = false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location > 8 {
            return false
        }
        if textField.text?.lengthOfBytes(using: String.Encoding.utf8) == 1 &&
        string == "" {
            payBtn?.backgroundColor = UIColor.init(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
            payBtn?.isEnabled = false
        } else {
            payBtn?.backgroundColor = UIColor.init(red: 32/255.0, green: 43/255.0, blue: 80/255.0, alpha: 1)
            payBtn?.isEnabled = true
        }
        return true
    }
    
    func payAction(_ sender: UIButton) {
        
        
        if selectedIndex == 1 {
            DataManager.currentUser?.cash = 10
            let orderStr = "app_id=2016102102273564&biz_content=%7B%22timeout_express%22%3A%2230m%22%2C%22seller_id%22%3A%22%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22total_amount%22%3A%220.01%22%2C%22subject%22%3A%221%22%2C%22body%22%3A%22%E6%88%91%E6%98%AF%E6%B5%8B%E8%AF%95%E6%95%B0%E6%8D%AE%22%2C%22out_trade_no%22%3A%22BBCXFY4KAL3U6DB%22%7D&charset=utf-8&method=alipay.trade.app.pay&sign_type=RSA&timestamp=2016-09-01%2013%3A49%3A34&version=1.0&sign=imFFzjpv%2BUt8iPLyFmrUqTUceLKWBZmn%2Bixy4siNLs3VmIw5jNddnLf1V0JdtkVQgAUhNWiw8oDTVlv6HuUAHj7Ja0Rz%2BdsYcr4MzTiqy1NHYYvoLUVFOlQGy1QXU6bMzYnhrQnjjkTf0hnNJiy6fVEA7iPRFnWr8cScHgA2JZI%3D"
            AlipaySDK.defaultService().payOrder(orderStr, fromScheme: "ydTravrlAlipay", callback: { (data: [AnyHashable: Any]!) in
                XCGLogger.debug("\(data)")
            })
        } else if selectedIndex == 0 {
            rechargeWithWX()
            
        }
        
    }
    
    func rechargeWithWX() {
        let dict:[String: AnyObject] = ["uid_": DataManager.currentUser!.uid as AnyObject,
                                        "title_": "V领队-余额充值" as AnyObject,
                                        "price_": Int(amount!)! * 100]
        SocketManager.sendData(.wxPlaceOrderRequest, data: dict as AnyObject?)
    
    }
    
    func jumpToBizPay(_ dict: [AnyHashable: Any]) {
        rechageID = dict["recharge_id_"] as? String
        let req = PayReq()
        req.partnerId = dict["partnerid"] as? String
        req.prepayId = dict["prepayid"] as? String
        req.nonceStr = dict["noncestr"] as? String
        req.timeStamp = UInt32.init((dict["timestamp"] as? String)!)!
        req.package = dict["package"] as? String
        req.sign = dict["sign"] as? String
        if WXApi.send(req) {
            XCGLogger.debug("suc")
        } else {
            XCGLogger.debug("err")
        }
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
