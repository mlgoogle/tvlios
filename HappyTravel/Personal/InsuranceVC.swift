//
//  InsuranceVC.swift
//  HappyTravel
//
//  Created by 司留梦 on 17/1/9.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD

class InsuranceVC: UIViewController {

    var insuranceTV:UITextView?
    var descLab:UILabel?
    var historyBtn:UIButton?
//    var moneyLab:UILabel? 客户端不显示保险金额
    var sureBtn:UIButton?
    var order_price:Int64 = 0
    var insurance_price:Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "保险说明"
        self.initUI()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let model = InsuranceBaseInfo()
        model.insurance_type_ = 0
        model.order_price_ = 1
        UserSocketAPI.insuranceInfo(model, complete: { (response) in
            if let model = response as? InsuranceInfoModel {
                self.insurance_price = model.insurance_price_
            }
            }, error: { (err) in
        })
    }
    
    func initUI() {
        insuranceTV = UITextView()
        insuranceTV?.backgroundColor = UIColor.purpleColor()
        insuranceTV?.text = "先前，苹果宣布将于1月6日8点在中国正式开启“红色星期五”促销活动，购买指定iPhone与Mac机型即可免费赠送红色一副Beats Solo3耳机。但不到5分钟，赠送的耳机就被哄抢一空，不少果粉甚至无法提交订单.先前，苹果宣布将于1月6日8点在中国正式开启“红色星期五”促销活动，购买指定iPhone与Mac机型即可免费赠送红色一副Beats Solo3耳机。但不到5分钟，赠送的耳机就被哄抢一空，不少果粉甚至无法提交订单.先前，苹果宣布将于1月6日8点在中国正式开启“红色星期五”促销活动，购买指定iPhone与Mac机型即可免费赠送红色一副Beats Solo3耳机。但不到5分钟，赠送的耳机就被哄抢一空，不少果粉甚至无法提交订单.先前，苹果宣布将于1月6日8点在中国正式开启“红色星期五”促销活动，购买指定iPhone与Mac机型即可免费赠送红色一副Beats Solo3耳机。但不到5分钟，赠送的耳机就被哄抢一空，不少果粉甚至无法提交订单"
        self.view.addSubview(insuranceTV!)
        insuranceTV?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.bottom.equalTo(self.view).offset(-200)
        })
        
        descLab = UILabel()
        descLab?.text = "为了保证此次的服务质量，该保险为强制保险.游客保险费用由优悦承担,助理保险费用自行购买"
        descLab?.numberOfLines = 0
        descLab?.font = UIFont.systemFontOfSize(12.0)
        descLab?.textColor = UIColor.redColor()
        self.view.addSubview(descLab!)
        descLab?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.top.equalTo(insuranceTV!.snp_bottom).offset(10)
            make.height.equalTo(30)
        })
        
        historyBtn = UIButton()
        historyBtn?.setTitle("历史保单记录", forState: .Normal)
        historyBtn?.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        historyBtn?.backgroundColor = UIColor.blueColor()
        historyBtn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        historyBtn?.addTarget(self, action: #selector(historyAction(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(historyBtn!)
        historyBtn?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(self.view).offset(10)
            make.top.equalTo(descLab!.snp_bottom).offset(10)
            make.height.equalTo(20)
            make.width.equalTo(100)
        })
        
        sureBtn = UIButton()
        
        sureBtn?.setTitle("确定", forState: .Normal)
        sureBtn?.layer.cornerRadius = 10
        sureBtn?.layer.borderWidth = 0.1
        sureBtn?.layer.masksToBounds = true
        sureBtn?.layer.borderColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1).CGColor
        sureBtn?.setBackgroundImage(UIImage(named: "bottom-selector-bg"), forState: .Normal)
        sureBtn?.addTarget(self, action: #selector(sureAction(_:)), forControlEvents: .TouchUpInside)
//        sureBtn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.view.addSubview(sureBtn!)
        sureBtn?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(historyBtn!.snp_bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.height.equalTo(40)
            make.width.equalTo(100)
        })

    }
    
    func historyAction(sender: UIButton) {
        NSLog("跳转到历史保单记录")
    }
    
    func sureAction(sender: UIButton) {
        SVProgressHUD.showSuccessMessage(SuccessMessage: "购买成功", ForDuration: 0.5, completion: { () in
            self.navigationController?.popViewControllerAnimated(true)
        })
//        let model = InsurancePayBaseInfo()
//        model.insurance_price = insurance_price
//        model.insurance_username_ = String(CurrentUser.uid_)//用户id
//        UserSocketAPI.insurancePay(model, complete: { (response) in
//            if let model = response as? InsuranceSuccessModel {
//                if model.is_success_ == 0{
//                    SVProgressHUD.showSuccessMessage(SuccessMessage: "购买成功", ForDuration: 0.5, completion: { () in
////                        self.navigationController?.popViewControllerAnimated(true)
//                    })
//                }
//            }
//            }, error: { (err) in
//        })
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
