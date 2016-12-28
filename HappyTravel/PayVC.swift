//
//  PayVC.swift
//  HappyTravel
//
//  Created by 司留梦 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class PayVC: UIViewController, UITextFieldDelegate {

    var payLab:UILabel?
    var passwdTF:UITextField?
    var price:Int?
    var orderId:Int?
    var segmentIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "支付"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PayVC.payForInvitationReply(_:)), name: NotifyDefine.PayForInvitationReply, object: nil)
        initView()
    }
    
    func initView() {
        payLab = UILabel()
//        price = 200
        payLab!.text = "您即将预支付人民币\(Double(price!)/100)元"
        payLab!.textAlignment = .Center
        payLab!.font = UIFont.systemFontOfSize(15.0)
        payLab!.textColor = UIColor.blackColor()
        self.view.addSubview(payLab!)
        payLab?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(self.view).offset(20)
            make.centerX.equalTo(self.view)
            make.height.equalTo(20)
            make.left.equalTo(10)
        })
        
        let insuranceBtn = UIButton()
        insuranceBtn.setImage(UIImage(named: "guide-star-hollow"), forState: .Normal)
        insuranceBtn.setImage(UIImage(named: "guide-star-fill"), forState: .Selected)
        insuranceBtn.setTitle("同意购买商务保险,", forState: .Normal)
        insuranceBtn.titleLabel?.font = UIFont.systemFontOfSize(10.0)
        insuranceBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        insuranceBtn.contentHorizontalAlignment = .Left
        insuranceBtn.addTarget(self, action: #selector(sureInsuranceActure(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(insuranceBtn)
        insuranceBtn.snp_makeConstraints { (make) in
//            let left = (UIScreen.mainScreen().bounds.width-110-60)/2
            make.top.equalTo(payLab!.snp_bottom).offset(10)
            make.width.equalTo(110)
            make.height.equalTo(20)
            make.left.equalTo(self.view).offset(20)
//            make.left.equalTo(self.view).offset(left)
        }
        
        let webBtn = UIButton()
        let attrs = [
            NSFontAttributeName : UIFont.systemFontOfSize(10.0),
            NSForegroundColorAttributeName : UIColor.blueColor(),
            NSUnderlineStyleAttributeName : 1]
        let attributedString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string:"《保险说明》", attributes:attrs)
        attributedString.appendAttributedString(buttonTitleStr)
        webBtn.setAttributedTitle(attributedString, forState: .Normal)
        webBtn.addTarget(self, action: #selector(webView(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(webBtn)
        webBtn.snp_makeConstraints { (make) in
            make.top.equalTo(payLab!.snp_bottom).offset(10)
            make.width.equalTo(60)
            make.height.equalTo(20)
            make.left.equalTo(insuranceBtn.snp_right)
        }
        
        passwdTF = UITextField()
        passwdTF!.borderStyle = .RoundedRect
        passwdTF!.placeholder = "请输入密码"
        passwdTF!.textAlignment = .Left
        passwdTF!.contentVerticalAlignment = .Center
        passwdTF!.keyboardType = .NumberPad
        passwdTF!.secureTextEntry = true
        passwdTF!.delegate = self
        passwdTF!.becomeFirstResponder()
        passwdTF!.resignFirstResponder()
        self.view.addSubview(passwdTF!)
        passwdTF!.snp_makeConstraints { (make) in
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo(30)
            make.top.equalTo(webBtn.snp_bottom).offset(5)
        }
        
        let sureBtn = UIButton()
        sureBtn.setTitle("确认支付", forState: .Normal)
        sureBtn.setBackgroundImage(UIImage(named: "bottom-selector-bg"), forState: .Normal)
        sureBtn.addTarget(self, action: #selector(surePay(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(sureBtn)
        sureBtn.snp_makeConstraints { (make) in
            make.left.equalTo(passwdTF!.snp_left)
            make.right.equalTo(passwdTF!.snp_right)
            make.top.equalTo(passwdTF!.snp_bottom).offset(10)
            make.height.equalTo(40)
        }

    }
    
    func surePay(sender: UIButton) {
        var errMsg = ""
        let passwd = passwdTF!.text
        if passwd?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            errMsg = "请输入支付密码"
        }
        if errMsg.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let warningAlert = UIAlertController.init(title: "提示", message: errMsg, preferredStyle: .Alert)
            let sure = UIAlertAction.init(title: "好的", style: .Cancel, handler: { (action) in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.15)), dispatch_get_main_queue(), { () in
//                    self.payForInvitationRequest()
                })
            })
            warningAlert.addAction(sure)
            self.presentViewController(warningAlert, animated: true, completion: nil)
        } else {
            if DataManager.currentUser?.cash < price {
                self.moneyIsTooLess()
            } else {
                let dict:[String: AnyObject] = ["uid_": (DataManager.currentUser?.uid)!,
                                                "order_id_": orderId!,
                                                "passwd_": passwd!]
                SocketManager.sendData(.PayForInvitationRequest, data: dict)
            }
            
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        //打印出文本框中的值
        print(textField.text)
        return true
    }
    
    func sureInsuranceActure(sender:UIButton) {
        let isSelected = sender.selected
        sender.selected = !isSelected
        let sureInsurancePrice = isSelected ? 0 : 20
        let money = price! + sureInsurancePrice*100
        payLab!.text = "您即将预支付人民币\(Double(money)/100)元"
        
    }
    func webView(sender:UIButton) {
        let webVc = BaseWebView()
        self.navigationController?.pushViewController(webVc, animated: true)
        
    }

    /**
     支付回调
     
     - parameter notification:
     */
    func payForInvitationReply(notification: NSNotification) {
        
        
        if let result = notification.userInfo!["result_"] as? Int {
            var msg = ""
            switch result {
            case 0:
                MobClick.event(CommonDefine.BuriedPoint.payForOrderSuccess)
                msg = "预支付成功"
                if segmentIndex! == 0 {
                    SocketManager.sendData(.ObtainTripRequest, data: ["uid_": DataManager.currentUser!.uid,
                        "order_id_": 0,
                        "count_": 10])
                } else {
                    SocketManager.sendData(.AppointmentRecordRequest, data: ["uid_": DataManager.currentUser!.uid,
                        "last_id_": 0,
                        "count_": 10])
                }
            case -1:
                msg = "密码错误"
            case -2:
                MobClick.event(CommonDefine.BuriedPoint.payForOrderFail)
                msg = "余额不足"
                moneyIsTooLess()
                return
            default:
                break
            }
            let alert = UIAlertController.init(title: "提示", message: msg, preferredStyle: .Alert)
            let sure = UIAlertAction.init(title: "好的", style: .Cancel, handler: nil)
            alert.addAction(sure)
            presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }

    
    /**
     余额不足操作
     */
    func moneyIsTooLess() {
        let alert = UIAlertController.init(title: "余额不足", message: "\n请前往充值", preferredStyle: .Alert)
        
        let ok = UIAlertAction.init(title: "前往充值", style: .Default, handler: { (action: UIAlertAction) in
            let rechargeVC = RechargeVC()
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
