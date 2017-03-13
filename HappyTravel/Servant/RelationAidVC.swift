//
//  RelationAidVC.swift
//  HappyTravel
//
//  Created by macbook air on 17/3/1.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD
class RelationAidVC: UIViewController {
    
    var userInfo: UserInfoModel = UserInfoModel()
    var payStatus: PayOrderStatusModel = PayOrderStatusModel()
    var to_uid: Int = -1
    
    var imageV : UIImageView?
    var vImage : UIImageView?
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-120)
        scrollView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: 600)
        scrollView.scrollEnabled = true
        scrollView.userInteractionEnabled = true
        scrollView.delegate = self
        scrollView.autoresizesSubviews = false
        
        return scrollView
    }()
    //确定支付view
    let payView: UIView = UIView()
    let payButton: UIButton = UIButton(type: UIButtonType.Custom)
    let payLabelBlack: UILabel = UILabel()
    let payLabelGray: UILabel = UILabel()
    
    //金额
    let moneyLabel:UILabel = UILabel()
    //个人简介view
    let introView: UIView = UIView()
    let introLabel: UILabel = UILabel()
    let introLine: UIView = UIView()
    let introText: UILabel = UILabel()
    let unfoldButton: UIButton = UIButton()
    
    //能力标签
    let powerView: UIView = UIView()
    let powerLabel: UILabel = UILabel()
    let powerLine: UIView = UIView()
    let businessBtn: UIButton = UIButton()
    let relaxationBtn: UIButton = UIButton()
    
    //服务价格
    let serveView: UIView = UIView()
    let serveLable: UILabel = UILabel()
    let serveLine: UIView = UIView()
    let serveDiscuss: UILabel = UILabel()
    
    //输入微信号View
    let wenXinView: UIView = UIView()
    let userTextField: UITextField = UITextField()
    let confireBtn: UIButton = UIButton()
    let shadow: UIButton = UIButton()
    let grayLine: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(scrollView)
        setupUI()
        
        let viewHidden = tabBarController?.view.viewWithTag(10)
        viewHidden?.hidden = true
    }
    
    //头像视图view
    func setupUI() {
        let titleV : UIView = UIView()
        navigationItem.titleView = titleV
        imageV = UIImageView(frame: CGRectMake(0, 0, 77, 77))
//        vImage = UIImageView(frame: CGRectMake(0, 0, 18, 18))
        if userInfo.head_url_ != nil {
            let headUrl = NSURL(string: userInfo.head_url_!)
            imageV!.kf_setImageWithURL(headUrl, placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            }
        }
        imageV?.layer.cornerRadius = 77 / 2
        imageV?.layer.masksToBounds = true
        imageV?.layer.borderWidth = 1
        imageV?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
        imageV!.userInteractionEnabled = true
        imageV!.backgroundColor = UIColor.clearColor()
        imageV?.center = CGPointMake(titleV.center.x, 0)
        titleV.addSubview(imageV!)
//        vImage?.image = UIImage.init(named: "iconV")
//        vImage?.center = CGPointMake(59, 59)
//        titleV.addSubview(vImage!)
        
        
        setupUIPay()
        setupUIMessage()
        setupUITextFiled()
    }
    //确定支付view
    func setupUIPay() {
        view.addSubview(payView)
        payView.addSubview(payButton)
        payView.addSubview(payLabelBlack)
        payView.addSubview(payLabelGray)
        
        payView.snp_makeConstraints { (make) in
            make.bottom.equalTo(view.snp_bottom).offset(-30)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(90)
        }
        
        payLabelBlack.snp_makeConstraints { (make) in
            make.top.equalTo(payView)
            make.centerX.equalTo(payView)
            make.height.equalTo(12)
            make.right.equalTo(payView)
            make.left.equalTo(payView)
        }
        payLabelBlack.textAlignment = .Center
        payLabelBlack.text = "支付完成后才可获得助理的联系方式"
        payLabelBlack.font = UIFont.systemFontOfSize(12)
        payLabelBlack.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        
        payLabelGray.snp_makeConstraints { (make) in
            make.top.equalTo(payLabelBlack.snp_bottom).offset(8)
            make.centerX.equalTo(payView)
            make.height.equalTo(10)
            make.right.equalTo(payView)
            make.left.equalTo(payView)
        }
        payLabelGray.textAlignment = .Center
        payLabelGray.text = "本平台保证交易双方都是实名认证"
        payLabelGray.font = UIFont.systemFontOfSize(10)
        payLabelGray.textColor = UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        
        payButton.snp_makeConstraints { (make) in
            make.top.equalTo(payLabelGray.snp_bottom).offset(15)
            make.centerX.equalTo(payView)
            make.right.equalTo(payView).offset(-15)
            make.left.equalTo(payView).offset(15)
            make.bottom.equalTo(payView)
            
        }
        payButton.setTitle("确认支付", forState: UIControlState.Normal)
        payButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        payButton.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        payButton.layer.cornerRadius = 22
        payButton.layer.masksToBounds = true
        payButton.addTarget(self, action: #selector(confireDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        
    }
    
    //显示简介内容
    func setupUIMessage() {
        //金额
        scrollView.addSubview(moneyLabel)
        moneyLabel.snp_makeConstraints { (make) in
            make.top.equalTo(scrollView).offset(58)
            make.centerX.equalTo(view)
            make.height.equalTo(19)
        }
        moneyLabel.textAlignment = .Center
        moneyLabel.text = "¥ 188.0"
        moneyLabel.font = UIFont.systemFontOfSize(25)
        moneyLabel.textColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        //个人简介
        scrollView.addSubview(introView)
        introView.addSubview(introLabel)
        introView.addSubview(introLine)
        introView.addSubview(introText)
        introView.addSubview(unfoldButton)
        introView.snp_makeConstraints { (make) in
            make.top.equalTo(moneyLabel.snp_bottom).offset(40)
            make.height.equalTo(115)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        introLabel.snp_makeConstraints { (make) in
            make.top.equalTo(introView)
            make.height.equalTo(16)
            make.centerX.equalTo(introView)
            
        }
        introLabel.textAlignment = .Center
        introLabel.font = UIFont.systemFontOfSize(16)
        introLabel.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        introLabel.text = "个人简介"
        
        introLine.snp_makeConstraints { (make) in
            make.top.equalTo(introLabel.snp_bottom).offset(5)
            make.centerX.equalTo(introLabel)
            make.height.equalTo(3)
            make.right.equalTo(introLabel)
            make.left.equalTo(introLabel)
        }
        introLine.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        
        introText.snp_makeConstraints { (make) in
            make.top.equalTo(introLine.snp_bottom).offset(15)
            make.left.equalTo(introView).offset(30)
            make.right.equalTo(introView).offset(-30)
            make.height.equalTo(54)
        }
        introText.textAlignment = .Left
        introText.font = UIFont.systemFontOfSize(14)
        introText.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        introText.numberOfLines = 0
        introText.text = "中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文中文"
        unfoldButton.snp_makeConstraints { (make) in
            make.top.equalTo(introText.snp_bottom).offset(10)
            make.centerX.equalTo(introLabel)
            make.height.equalTo(12)
        }
        unfoldButton.setTitle("展开", forState: UIControlState.Normal)
        unfoldButton.setTitleColor(UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1), forState: UIControlState.Normal)
        unfoldButton.setImage(UIImage.init(named: "unfold"), forState: UIControlState.Normal)
        unfoldButton.titleLabel?.font = UIFont.systemFontOfSize(11)
        unfoldButton.addTarget(self, action: #selector(unfoldBtnDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        let imageSize:CGSize = unfoldButton.imageView!.frame.size
        let titleSize:CGSize = unfoldButton.titleLabel!.frame.size
        unfoldButton.titleEdgeInsets = UIEdgeInsets(top: 0, left:-imageSize.width * 2, bottom: 0, right: 0)
        unfoldButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width * 2 - 5.0)
        
        //能力标签
        scrollView.addSubview(powerView)
        powerView.addSubview(powerLabel)
        powerView.addSubview(powerLine)
        powerView.addSubview(businessBtn)
        powerView.addSubview(relaxationBtn)
        
        powerView.snp_makeConstraints { (make) in
            make.top.equalTo(unfoldButton.snp_bottom).offset(26)
            make.height.equalTo(80)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        powerLabel.snp_makeConstraints { (make) in
            make.top.equalTo(powerView)
            make.centerX.equalTo(powerView)
            make.height.equalTo(16)
        }
        powerLabel.font = UIFont.systemFontOfSize(16)
        powerLabel.text = "能力标签"
        powerLabel.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        
        powerLine.snp_makeConstraints { (make) in
            make.top.equalTo(powerLabel.snp_bottom).offset(5)
            make.height.equalTo(3)
            make.left.equalTo(powerLabel)
            make.right.equalTo(powerLabel)
            make.centerX.equalTo(powerLabel)
        }
        powerLine.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        
        businessBtn.snp_makeConstraints { (make) in
            make.right.equalTo(powerView.snp_centerX).offset(-9)
            make.height.equalTo(41)
            make.top.equalTo(powerLine.snp_bottom).offset(15)
        }
        businessBtn.setTitle("商务陪同", forState: UIControlState.Normal)
        businessBtn.userInteractionEnabled = false
        businessBtn.titleLabel?.font = UIFont.systemFontOfSize(11)
        businessBtn.setBackgroundImage(UIImage.init(named: "powerBackground"), forState: UIControlState.Normal)
        businessBtn.setTitleColor(UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), forState: UIControlState.Normal)
        businessBtn.titleLabel?.textAlignment = .Center
        businessBtn.titleEdgeInsets = UIEdgeInsets(top: -10, left:0, bottom: 0, right: 0)
        
        relaxationBtn.snp_makeConstraints { (make) in
            make.left.equalTo(powerView.snp_centerX).offset(9)
            make.height.equalTo(41)
            make.top.equalTo(powerLine.snp_bottom).offset(15)
        }
        relaxationBtn.setTitle("休闲陪同", forState: UIControlState.Normal)
        relaxationBtn.userInteractionEnabled = false
        relaxationBtn.titleLabel?.font = UIFont.systemFontOfSize(11)
        relaxationBtn.setBackgroundImage(UIImage.init(named: "powerBackground"), forState: UIControlState.Normal)
        relaxationBtn.setTitleColor(UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), forState: UIControlState.Normal)
        relaxationBtn.titleLabel?.textAlignment = .Center
        relaxationBtn.titleEdgeInsets = UIEdgeInsets(top: -10, left:0, bottom: 0, right: 0)
        //服务价格
        scrollView.addSubview(serveView)
        serveView.addSubview(serveLable)
        serveView.addSubview(serveLine)
        serveView.addSubview(serveDiscuss)
        
        serveView.snp_makeConstraints { (make) in
            make.top.equalTo(powerView.snp_bottom).offset(25)
            make.centerX.equalTo(view)
            make.right.equalTo(view)
            make.left.equalTo(view)
        }
        serveLable.snp_makeConstraints { (make) in
            make.centerX.equalTo(serveView)
            make.height.equalTo(16)
            make.top.equalTo(serveView)
        }
        serveLable.text = "服务价格"
        serveLable.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        serveLable.font = UIFont.systemFontOfSize(16)
        
        serveLine.snp_makeConstraints { (make) in
            make.top.equalTo(serveLable.snp_bottom).offset(5)
            make.height.equalTo(3)
            make.left.equalTo(serveLable)
            make.right.equalTo(serveLable)
            make.centerX.equalTo(serveLable)
        }
        serveLine.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        
        serveDiscuss.snp_makeConstraints { (make) in
            make.top.equalTo(serveLine.snp_bottom).offset(15)
            make.height.equalTo(14)
            make.centerX.equalTo(serveLable)
        }
        serveDiscuss.text = "面议"
        serveDiscuss.font = UIFont.systemFontOfSize(14)
        serveDiscuss.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        
        
        
    }
    
    //显示用户输入微信号
    func setupUITextFiled() {
        let window = UIApplication.sharedApplication().keyWindow
        window?.addSubview(wenXinView)
        wenXinView.addSubview(userTextField)
        wenXinView.addSubview(confireBtn)
        wenXinView.addSubview(grayLine)
        wenXinView.hidden = true
        wenXinView.snp_makeConstraints { (make) in
            make.center.equalTo(window!)
            make.height.equalTo(161)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
        wenXinView.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        
        userTextField.snp_makeConstraints { (make) in
            make.top.equalTo(wenXinView).offset(20)
            make.left.equalTo(wenXinView).offset(15)
            make.right.equalTo(wenXinView).offset(-15)
            make.height.equalTo(61)
            
        }
        userTextField.placeholder = "输入您的微信号，方便助理通过您的微信验证"
        userTextField.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        var attributes: [String : AnyObject] = [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        attributes[NSFontAttributeName] = UIFont.systemFontOfSize(13)
        let attributedStr = NSAttributedString.init(string: userTextField.placeholder!, attributes: attributes)
        userTextField.attributedPlaceholder = attributedStr
        userTextField.textAlignment = .Center
        userTextField.contentVerticalAlignment = .Center
        
        confireBtn.snp_makeConstraints { (make) in
            make.left.equalTo(wenXinView)
            make.right.equalTo(wenXinView)
            make.bottom.equalTo(wenXinView)
            make.height.equalTo(51)
        }
        confireBtn.setTitle("确定", forState: UIControlState.Normal)
        confireBtn.setTitleColor(UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1), forState: UIControlState.Normal)
        confireBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        confireBtn.addTarget(self, action: #selector(confireBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        confireBtn.layer.borderColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1).CGColor
        
        grayLine.snp_makeConstraints { (make) in
            make.left.equalTo(wenXinView)
            make.right.equalTo(wenXinView)
            make.bottom.equalTo(confireBtn.snp_top)
            make.height.equalTo(1)
        }
        grayLine.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //确定支付按钮点击
    func confireDidClick() {
        wenXinView.hidden = false
        let window = UIApplication.sharedApplication().keyWindow
        window?.addSubview(shadow)
        shadow.snp_makeConstraints { (make) in
           make.right.left.bottom.top.equalTo(window!)
        }
        shadow.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        shadow.addTarget(self, action: #selector(shadowDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        window!.bringSubviewToFront(wenXinView)
    }
    
    //点击阴影
    func shadowDidClick() {
        wenXinView.hidden = true
        shadow.removeFromSuperview()
    }
    //填写完微信号后确定按钮点击
    func confireBtnClick() {

        if userTextField.text?.characters.count != 0 {
            let dict: [String : AnyObject] = ["from_uid_": CurrentUser.uid_,
                                              "to_uid_": to_uid,   //to_uid
                                              "service_prince_": 188,
                                              "wx_id_": userTextField.text ?? ""]
            
            let model = PayOrderRequestModel(value: dict)
            APIHelper.consumeAPI().payOrder(model, complete: {[weak self](response) in
                if let model = response as? PayOrderStatusModel{
                    self!.payStatus = model
                    if model.result_ == 0 {
                        
                        let getDict: [String : AnyObject] = ["order_id_": model.order_id_,
                                                             "uid_form_": CurrentUser.uid_,
                                                             "uid_to_": self!.to_uid]  //to_uid
                        let getModel = GetRelationRequestModel(value: getDict)
                        
                        APIHelper.consumeAPI().getRelation(getModel, complete: { [weak self](response) in
                            
                            if let model = response as? GetRelationStatusModel{
                                //支付完成的时候请求订单数据,显示小红点
                                var count = 0
                                let req = OrderListRequestModel()
                                req.uid_ = CurrentUser.uid_
                                APIHelper.consumeAPI().orderList(req, complete: { [weak self](response) in
                                    if let models = response as? [OrderListCellModel]{
                                        for model in models{
                                            if model.is_evaluate_ == 0{
                                                count = count + 1
                                            }
                                            else{
                                                continue
                                            }
                                        }
                                        if count == 0 {
                                            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.OrderListNo, object: nil, userInfo: nil)
                                        }
                                        else{
                                            
                                            NSNotificationCenter.defaultCenter().postNotificationName(NotifyDefine.OrderList, object: nil, userInfo: nil)
                                        }
                                    }
                                    },error:{ [weak self](error) in
                                    })

                                SVProgressHUD.showSuccessMessage(SuccessMessage: "支付成功", ForDuration: 1.0, completion: {
                                    self!.shadowDidClick()
                                    
                                    let aidWeiXin = AidWenXinVC()
                                    aidWeiXin.getRelation = model
                                    aidWeiXin.userInfo = (self?.userInfo)!
//                                    aidWeiXin.detailInfo = (self?.detailInfo)!
                                    aidWeiXin.isRefresh = {()->() in
                                        
                                    }
                                    aidWeiXin.bool = true
                                    self!.navigationController?.pushViewController(aidWeiXin, animated: true)
                                })
                            }
                           
                            
                            }, error: { (error) in
                                SVProgressHUD.showErrorWithStatus("支付失败,请查看余额是否不足")
                        })
                        
                    }
                }
                
            }) { (error) in
                
            }
        }
        else{
            SVProgressHUD.showWainningMessage(WainningMessage: "请输入微信号方便助理跟你取得联系", ForDuration: 1.5, completion: {
                SVProgressHUD.dismiss()
            })
        
        }
    
        
    }
    
    
    let selectorBtn: UIButton = UIButton()
    //展开按钮的点击
    func unfoldBtnDidClick(sender: UIButton) {
        unfoldButton.selected = selectorBtn.selected
        selectorBtn.selected = !sender.selected
        if unfoldButton.selected {
            unfoldButton.setImage(UIImage(named: "packUp"), forState: UIControlState.Selected)
            unfoldButton.setTitle("收起", forState: UIControlState.Selected)
            let imageSize:CGSize = unfoldButton.imageView!.frame.size
            let titleSize:CGSize = unfoldButton.titleLabel!.frame.size
            unfoldButton.titleEdgeInsets = UIEdgeInsets(top: 0, left:-imageSize.width * 2, bottom: 0, right: 0)
            unfoldButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width * 2 - 5.0)
            introText.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(114)
            })
            introView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(175)
            })
            view.layoutIfNeeded()
            
        }
        else{
            unfoldButton.setTitle("展开", forState: UIControlState.Normal)
            unfoldButton.setTitleColor(UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1), forState: UIControlState.Normal)
            unfoldButton.setImage(UIImage.init(named: "unfold"), forState: UIControlState.Normal)
            let imageSize:CGSize = unfoldButton.imageView!.frame.size
            let titleSize:CGSize = unfoldButton.titleLabel!.frame.size
            unfoldButton.titleEdgeInsets = UIEdgeInsets(top: 0, left:-imageSize.width * 2, bottom: 0, right: 0)
            unfoldButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width * 2 - 5.0)
            introText.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(54)
            })
            introView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(115)
                })
            view.layoutIfNeeded()
            
        }
    }
    
    
}


extension RelationAidVC : UIScrollViewDelegate,UITextFieldDelegate{
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        var scale:CGFloat = 1.0
        if offsetY < 0  // 下拉
        {
            scale = min(1.5, 1.0 - offsetY / 200.0)
        } else if offsetY > 0
        {
            scale = max(0.45, 1 - offsetY / 200);
        }
        imageV?.transform = CGAffineTransformMakeScale(scale, scale)
        vImage?.transform = CGAffineTransformMakeScale(scale, scale)
        var frame = imageV?.frame
        var vFrame = vImage?.frame
        frame?.origin.y = -(imageV?.layer.cornerRadius)! / 2.0
        vFrame?.origin.y = -(vImage?.layer.cornerRadius)! / 2.0
        imageV?.frame = frame!
        vImage?.frame = vFrame!
    }
    
    
    
    
    
}
