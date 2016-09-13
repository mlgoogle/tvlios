//
//  CompleteBaseInfoVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/9.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import Alamofire

class CompleteBaseInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AddressSelVCDelegate {
    
    var table:UITableView?
    
    var nickname:String?
    
    var sex = 0
    
    var address:String?
    
    var cells:Dictionary<Int, UITableViewCell> = [:]
    
    let tags = ["titleLab": 1001,
                "nicknameField": 1002,
                "description": 1003,
                "separateLine": 1004,
                "headBG": 1005,
                "headView": 1006,
                "selectedRetLab": 1007]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "完善基本资料"
        
        initView()
        
        registerNotify()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationItem.rightBarButtonItem == nil {
            let sureBtn = UIButton.init(frame: CGRectMake(0, 0, 40, 30))
            sureBtn.setTitle("完成", forState: .Normal)
            sureBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            sureBtn.backgroundColor = UIColor.clearColor()
            sureBtn.addTarget(self, action: #selector(AddressSelVC.sureAction(_:)), forControlEvents: .TouchUpInside)
            
            let sureItem = UIBarButtonItem.init(customView: sureBtn)
            navigationItem.rightBarButtonItem = sureItem
            
        }
    }
    
    func sureAction(sender: UIButton) {
        let addr = "http://restapi.amap.com/v3/geocode/geo?key=389880a06e3f893ea46036f030c94700&s=rsv3&city=35&address=%E6%9D%AD%E5%B7%9E"
        Alamofire.request(.GET, addr).responseJSON() { response in
            let geocodes = ((response.result.value as? Dictionary<String, AnyObject>)!["geocodes"] as! Array<Dictionary<String, AnyObject>>).first
            let location = (geocodes!["location"] as! String).componentsSeparatedByString(",")
            XCGLogger.debug("\(location)")
            
            let nicknameField = self.cells[1]?.contentView.viewWithTag(self.tags["nicknameField"]!) as? UITextField
            self.nickname = nicknameField?.text
            let dict:Dictionary<String, AnyObject> = ["uid_": (DataManager.currentUser?.uid)!,
                                                      "nickname_": self.nickname!,
                                                      "gender_": self.sex,
                                                      "head_url_": "http://www.abc.com",
                                                      "address_": self.address!,
                                                      "longitude_": 121.604742,//Float.init(location[0])!,
                                                      "latitude_": 31.212959]//Float.init(location[1])!]
            SocketManager.sendData(.SendImproveData, data: dict)
        }
        
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        table?.separatorStyle = .None
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompleteBaseInfoVC.improveDataSuccessed(_:)), name: NotifyDefine.ImproveDataSuccessed, object: nil)
    }
    
    func improveDataSuccessed(notification: NSNotification?) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("BaseInfoHeadCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.backgroundColor = UIColor.clearColor()
                cell?.contentView.backgroundColor = UIColor.clearColor()
                cell?.selectionStyle = .None
            }
            
            var bgView = cell?.contentView.viewWithTag(tags["headBG"]!)
            if bgView == nil {
                bgView = UIView()
                bgView?.backgroundColor = UIColor.clearColor()
                cell?.contentView.addSubview(bgView!)
                bgView?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView)
                    make.right.equalTo(cell!.contentView)
                    make.top.equalTo(cell!.contentView)
                    make.bottom.equalTo(cell!.contentView)
                    make.height.equalTo(UIScreen.mainScreen().bounds.size.width / 2.0)
                })
            }
            
            var headView = cell?.contentView.viewWithTag(tags["headView"]!) as? UIImageView
            if headView == nil {
                headView = UIImageView()
                headView?.tag = tags["headView"]!
                headView?.layer.cornerRadius = 100 / 2.0
                headView?.layer.masksToBounds = true
                headView?.image = UIImage.init(named: "default-head")
                cell?.contentView.addSubview(headView!)
                headView?.snp_makeConstraints(closure: { (make) in
                    make.center.equalTo(bgView!)
                    make.width.equalTo(100)
                    make.height.equalTo(100)
                })
            }
            
            cells[indexPath.row] = cell!
            return cell!
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("BaseInfoCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.selectionStyle = .None
            }
            cell?.accessoryType = indexPath.row == 1 ? .None : .DisclosureIndicator
            
            var titleLab = cell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel
            if titleLab == nil {
                titleLab = UILabel()
                titleLab?.tag = tags["titleLab"]!
                titleLab?.backgroundColor = UIColor.clearColor()
                titleLab?.textColor = UIColor.blackColor()
                titleLab?.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(titleLab!)
                titleLab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(20)
                    make.centerY.equalTo(cell!.contentView)
                    make.width.equalTo(100)
                })
            }
            let title = ["昵称", "性别", "常住地"]
            titleLab?.text = title[indexPath.row - 1]
            
            var separateLine = cell?.contentView.viewWithTag(tags["separateLine"]!)
            if separateLine == nil {
                separateLine = UIView()
                separateLine?.tag = tags["separateLine"]!
                separateLine?.backgroundColor = UIColor.init(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
                cell?.contentView.addSubview(separateLine!)
                separateLine?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!)
                    make.right.equalTo(cell!.contentView).offset(40)
                    make.bottom.equalTo(cell!.contentView).offset(0.5)
                    make.height.equalTo(1)
                })
            }
            separateLine?.hidden = (indexPath.row == 0 || indexPath.row == 3) ? true : false
            
            var nicknameField = cell?.contentView.viewWithTag(tags["nicknameField"]!) as? UITextField
            if nicknameField == nil {
                nicknameField = UITextField()
                nicknameField!.tag = tags["nicknameField"]!
                nicknameField!.secureTextEntry = false
                nicknameField!.delegate = self
                nicknameField!.textColor = UIColor.blackColor()
                nicknameField!.rightViewMode = .WhileEditing
                nicknameField!.clearButtonMode = .WhileEditing
                nicknameField!.backgroundColor = UIColor.clearColor()
                nicknameField!.textAlignment = .Right
                nicknameField!.attributedPlaceholder = NSAttributedString.init(string: "10个字符以内", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
                cell?.contentView.addSubview(nicknameField!)
                nicknameField!.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(titleLab!)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.height.equalTo(25)
                })
            }
            nicknameField?.hidden = indexPath.row == 1 ? false : true
            
            var selectedRetLab = cell?.contentView.viewWithTag(tags["selectedRetLab"]!) as? UILabel
            if selectedRetLab == nil {
                selectedRetLab = UILabel()
                selectedRetLab?.tag = tags["selectedRetLab"]!
                selectedRetLab?.backgroundColor = UIColor.clearColor()
                selectedRetLab?.textColor = UIColor.grayColor()
                selectedRetLab?.textAlignment = .Right
                selectedRetLab?.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(selectedRetLab!)
                selectedRetLab?.snp_makeConstraints(closure: { (make) in
                    make.right.equalTo(cell!.contentView).offset(-10)
                    make.centerY.equalTo(titleLab!)
                })
            }
            
            cells[indexPath.row] = cell!
            return cell!
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            XCGLogger.debug("余额")
        } else if indexPath.row == 2 {
            XCGLogger.debug("性别选择")
            let alertCtrl = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let male = UIAlertAction.init(title: "男", style: .Default, handler: { (sender: UIAlertAction) in
                self.sex = 1
                let sexLab = self.cells[2]?.contentView.viewWithTag(self.tags["selectedRetLab"]!) as? UILabel
                sexLab?.text = "男"
            })
            
            let female = UIAlertAction.init(title: "女", style: .Default, handler: { (sender: UIAlertAction) in
                self.sex = 0
                let sexLab = self.cells[2]?.contentView.viewWithTag(self.tags["selectedRetLab"]!) as? UILabel
                sexLab?.text = "女"
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (sender: UIAlertAction) in
                
            })
            
            alertCtrl.addAction(male)
            alertCtrl.addAction(female)
            alertCtrl.addAction(cancel)
            
            presentViewController(alertCtrl, animated: true, completion: nil)
            
        } else if indexPath.row == 3 {
            XCGLogger.debug("常住地选择")
            let addressSelVC = AddressSelVC()
            addressSelVC.delegate = self
            navigationController?.pushViewController(addressSelVC, animated: true)
        }
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["nicknameField"]!:
            nickname = textField.text
            break
        default:
            break
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 9 {
            return false
        }
        if textField.tag == tags["nicknameField"]! {
            nickname = textField.text! + string
        }
        
        return true
    }

    //MARK: - AddressSelVCDelegate
    func addressSelected(address: String?) {
        self.address = address
        let addressLab = self.cells[3]?.contentView.viewWithTag(self.tags["selectedRetLab"]!) as? UILabel
        addressLab?.text = address!
        XCGLogger.debug("\(self.address!)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

