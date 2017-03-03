//
//  AidWenXinVC.swift
//  HappyTravel
//
//  Created by macbook air on 17/3/3.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD
class AidWenXinVC: UIViewController {

    var getRelation:getRelationStatusModel = getRelationStatusModel()
    var userInfo: UserInfoModel = UserInfoModel()
    
    var qrCode :UIImageView = UIImageView()
    var accountLabel: UILabel = UILabel()
    var accountName: UILabel = UILabel()
    var copyBtn: UIButton = UIButton()
    var evaluateBtn: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        title = "助理微信"
        setupUI()
    }

    func setupUI(){

        view.addSubview(qrCode)
        view.addSubview(accountLabel)
        view.addSubview(accountName)
        view.addSubview(copyBtn)
        view.addSubview(evaluateBtn)
        
        qrCode.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(76)
            make.height.equalTo(141)
            make.width.equalTo(141)
        }
        qrCode.layer.borderColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1).CGColor
        if getRelation.wx_url_ != nil {
            let headUrl = NSURL(string: getRelation.wx_url_!)
            qrCode.kf_setImageWithURL(headUrl, placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            }
        }
        
        
        accountLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(qrCode)
            make.top.equalTo(qrCode.snp_bottom).offset(21)
            make.height.equalTo(18)
        }
        accountLabel.textAlignment = .Center
        accountLabel.font = UIFont.systemFontOfSize(18)
        accountLabel.text = userInfo.nickname_! + "微信账号"
        accountLabel.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        
        accountName.snp_makeConstraints { (make) in
            make.centerX.equalTo(accountLabel)
            make.top.equalTo(accountLabel.snp_bottom).offset(10)
            make.height.equalTo(12)
        }
        accountName.textAlignment = .Center
        accountName.font = UIFont.systemFontOfSize(12)
        accountName.text = "widjk-156841355423"
        accountName.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        
        copyBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(accountName)
            make.top.equalTo(accountName.snp_bottom).offset(30)
            make.right.equalTo(view).offset(-62)
            make.left.equalTo(view).offset(62)
            make.height.equalTo(45)
        }
        copyBtn.setTitle("点击复制助理微信号", forState: UIControlState.Normal)
        copyBtn.setTitleColor(UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1), forState: UIControlState.Normal)
        copyBtn.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        copyBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        copyBtn.addTarget(self, action: #selector(copyBtnDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        evaluateBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            make.height.equalTo(45)
            make.bottom.equalTo(view).offset(-30)
        }
        evaluateBtn.setTitle("评价", forState: UIControlState.Normal)
        evaluateBtn.setTitleColor(UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), forState: UIControlState.Normal)
        evaluateBtn.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        evaluateBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        evaluateBtn.layer.cornerRadius = 22
        evaluateBtn.layer.masksToBounds = true
        evaluateBtn.addTarget(self, action: #selector(evaluateDidClick), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    //点击评价按钮
    func evaluateDidClick() {
        let orderEvaluate = OrderEvaluateVC()
        orderEvaluate.userInfo = userInfo
        navigationController?.pushViewController(orderEvaluate, animated: true)
        
    }
    //点击复制助理微信号按钮
    func copyBtnDidClick() {
        let pasteboard = UIPasteboard.generalPasteboard()
        if accountName.text?.characters != nil {
            pasteboard.string = accountName.text
            SVProgressHUD.showSuccessMessage(SuccessMessage: "复制成功", ForDuration: 1.0, completion: {
                SVProgressHUD.dismiss()
            })
        }
        
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
