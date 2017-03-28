//
//  OrderEvaluateVC.swift
//  HappyTravel
//
//  Created by macbook air on 17/3/3.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD
class OrderEvaluateVC: UIViewController {

    var toUidUrl: String?
    var order_id_:Int = 0
    var to_uid_: Int = 0
    var nickname: String?
    
    let sumImageView: UIView = UIView()
    let sumBtnView: UIView = UIView()
    let vImage: UIImageView = UIImageView()
    var aidImageView:UIImageView = UIImageView()
    var aidName:UILabel = UILabel()
    let textView: UITextView = UITextView()
    let placeholderLabel: UILabel = UILabel()
    var evaluateBtn: UIButton = UIButton()
    
    var evaluate: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        title = "订单评价"
        setupUI()
        // Do any additional setup after loading the view.
        //隐藏红点
        let viewHidden = tabBarController?.view.viewWithTag(10)
        viewHidden?.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setupUI(){
        view.addSubview(sumImageView)
        view.addSubview(sumBtnView)
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        sumImageView.addSubview(aidImageView)
        sumImageView.addSubview(vImage)
        view.addSubview(aidName)
        view.addSubview(evaluateBtn)
        
        sumImageView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(30)
            make.height.equalTo(83)
            make.width.equalTo(83)
        }
        aidImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(sumImageView)
        }
        if toUidUrl != nil {
            let headUrl = NSURL(string: toUidUrl!)
            aidImageView.kf_setImageWithURL(headUrl, placeholderImage: UIImage(named: "default-head"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            }
        }
        aidImageView.layer.cornerRadius = 83 / 2
        aidImageView.layer.masksToBounds = true
        aidImageView.layer.borderWidth = 1
        aidImageView.layer.borderColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1).CGColor
        aidImageView.userInteractionEnabled = true
        aidImageView.backgroundColor = UIColor.clearColor()
        
        vImage.snp_makeConstraints { (make) in
            make.height.equalTo(19)
            make.width.equalTo(19)
            make.right.equalTo(sumImageView).offset(-6)
            make.bottom.equalTo(sumImageView)
        }
        vImage.image = UIImage(named: "iconV")
        
        aidName.snp_makeConstraints { (make) in
            make.top.equalTo(sumImageView.snp_bottom).offset(10)
            make.height.equalTo(18)
            make.centerX.equalTo(view)
        }
        aidName.textAlignment = .Center
        aidName.font = UIFont.systemFontOfSize(18)
        aidName.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        aidName.text = nickname
        
        sumBtnView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(aidName.snp_bottom).offset(15)
            make.width.equalTo(205)
            make.height.equalTo(29)
        }
        for i in 0...4 {
            let starBtn:UIButton = UIButton()
            starBtn.tag = i + 10000
            sumBtnView.addSubview(starBtn)
            starBtn.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(sumBtnView)
                make.height.equalTo(29)
                make.width.equalTo(29)
                make.left.equalTo(sumBtnView).offset(i * 44)
            })
            starBtn.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
//starSelector  starUnselector
            starBtn.addTarget(self, action: #selector(starBtnDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        }
      textView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(141)
            make.top.equalTo(sumBtnView.snp_bottom).offset(40)
        }
        textView.autocorrectionType = .No
        textView.delegate = self
        textView.backgroundColor = UIColor(colorLiteralRed: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        textView.editable = true
        textView.layer.borderColor = UIColor(colorLiteralRed: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1).CGColor
        textView.layer.borderWidth = 1.0
        textView.font = UIFont.systemFontOfSize(14)
    
        placeholderLabel.snp_makeConstraints { (make) in
            make.left.equalTo(textView).offset(5)
            make.top.equalTo(textView).offset(5)
        }
        placeholderLabel.textColor = UIColor(colorLiteralRed: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        placeholderLabel.font = UIFont.systemFontOfSize(14)
        placeholderLabel.text = "写下您对此次服务的评价..."
        
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
    
    func starBtnDidClick(sender:UIButton) {
        switch sender.tag {
        case 10000:
            highlightBtn(10000)
            break
        case 10001:
            highlightBtn(10001)
            break
        case 10002:
            highlightBtn(10002)
            break
        case 10003:
            highlightBtn(10003)
            break
        case 10004:
            highlightBtn(10004)

            break
        default:
            break
        }
        
    }
    let selectorBtn: UIButton = UIButton()
    func highlightBtn(tag: Int) {
        let btn1 = view.viewWithTag(10000) as? UIButton
        let btn2 = view.viewWithTag(10001) as? UIButton
        let btn3 = view.viewWithTag(10002) as? UIButton
        let btn4 = view.viewWithTag(10003) as? UIButton
        let btn5 = view.viewWithTag(10004) as? UIButton
        selectorBtn.tag = tag
        if tag == 10000 {
            btn1!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn2!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
            btn3!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
            btn4!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
            btn5!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
        }
        if tag == 10001 {
            btn1!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn2!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn3!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
            btn4!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
            btn5!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
        }
        if tag == 10002 {
            btn1!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn2!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn3!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn4!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
            btn5!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
        }
        if tag == 10003{
            btn1!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn2!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn3!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn4!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
            btn5!.setBackgroundImage(UIImage.init(named: "guide-star-hollow"), forState: UIControlState.Normal)
        }
        if tag == 10004{
                btn1!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
                btn2!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
                btn3!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
                btn4!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
                btn5!.setBackgroundImage(UIImage.init(named: "guide-star-fill"), forState: UIControlState.Normal)
        }
    }
    
    //点击评价的按钮
    func evaluateDidClick() {
        var starInt:Int = 0
        switch selectorBtn.tag {
        case 10000:
            starInt = 1
            break
        case 10001:
            starInt = 2
            break
        case 10002:
            starInt = 3
            break
        case 10003:
            starInt = 4
            break
        case 10004:
            starInt = 5
            break
        default:
            break
        }
        if textView.text.characters.count < 255 {
            let dict: [String : AnyObject] = ["from_uid_": CurrentUser.uid_,
                                              "to_uid_": to_uid_,
                                              "order_id_": order_id_,
                                              "service_score_": starInt,
                                              "user_score_": starInt,
                                              "remarks_": textView.text]
            let model = CommentForOrderModel(value: dict)
            APIHelper.consumeAPI().commentForOrder(model, complete: { [weak self](response) in
                SVProgressHUD.showSuccessMessage(SuccessMessage: "评价成功", ForDuration: 0.5, completion: {
                    //评价完的时候请求订单数据,更新个人中心我的消费红点显示
                    var count = 0
                    let req = OrderListRequestModel()
                    req.uid_ = CurrentUser.uid_
                    APIHelper.consumeAPI().orderList(req, complete: { (response) in
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
                        },error:{ (error) in
                        })

                    SVProgressHUD.dismiss()
                    self!.evaluate!()
                    self!.navigationController?.popViewControllerAnimated(true)
                })
            }) { (error) in
            }
        } else {
            SVProgressHUD.showErrorMessage(ErrorMessage: "只能输入255个字,你输入的字数超过限制", ForDuration: 1.0, completion: { 
                SVProgressHUD.dismiss()
            })
        }
    }
}

extension OrderEvaluateVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(textView: UITextView) {
        placeholderLabel.text = ""
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        let str = textView.text! as NSString
        if str.length == 0 {
            placeholderLabel.text = "写下您对此次服务的评价..."
        }
        else{
            placeholderLabel.text = ""
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if range.location >= 255 {
            return false
        }
        var newLength: Int = 0
        if let count: Int = textView.text.characters.count{
            newLength = count + text.characters.count - range.length
        }
        return newLength < 255
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
}

