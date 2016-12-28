//
//  PayVC.swift
//  HappyTravel
//
//  Created by 司留梦 on 16/12/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class PayVC: UIViewController {

    var payLab:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "支付"
        initView()
    }
    
    func initView() {
        payLab = UILabel()
        payLab!.text = "您即将预支付人民币200元"
        payLab!.textAlignment = .Center
        payLab!.font = UIFont.systemFontOfSize(14.0)
        payLab!.textColor = UIColor.blackColor()
        self.view.addSubview(payLab!)
        payLab?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(self.view).offset(20)
            make.centerX.equalTo(self.view)
            make.height.equalTo(20)
            make.left.equalTo(10)
        })
        
        let insuranceBtn = UIButton()
        insuranceBtn.setImage(UIImage(named: "cash"), forState: .Normal)
        insuranceBtn.setImage(UIImage(named: "recommend"), forState: .Selected)
        insuranceBtn.setTitle("同意购买商务保险,", forState: .Normal)
        insuranceBtn.titleLabel?.font = UIFont.systemFontOfSize(10.0)
        insuranceBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        insuranceBtn.contentHorizontalAlignment = .Left
        insuranceBtn.addTarget(self, action: #selector(sureInsuranceActure(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(insuranceBtn)
        insuranceBtn.snp_makeConstraints { (make) in
            let left = (UIScreen.mainScreen().bounds.width-110-60)/2
            make.top.equalTo(payLab!.snp_bottom).offset(10)
            make.width.equalTo(110)
            make.height.equalTo(20)
            make.left.equalTo(self.view).offset(left)
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

    }
    
    func sureInsuranceActure(sender:UIButton) {
        let isSelected = sender.selected
        sender.selected = !isSelected
        let price = isSelected ? 0 : 20
        payLab!.text = "您即将预支付人民币\(200+price)元"
        
    }
    func webView(sender:UIButton) {
        let webVc = BaseWebView()
        self.navigationController?.pushViewController(webVc, animated: true)
        
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
