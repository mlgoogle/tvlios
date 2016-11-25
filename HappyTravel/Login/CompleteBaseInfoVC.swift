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
import SVProgressHUD
import Qiniu
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


class CompleteBaseInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AddressSelVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var headerUrl:String?
    var table:UITableView?
    
    var token:String?
    
    var cityName: String? = UserDefaults.standard.value(forKey: UserDefaultKeys.homeLocation) as? String
    
    var headView:UIImageView?
    
    var headImagePath:String?
    
    var headImageName:String?
    
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
    
    var imagePicker:UIImagePickerController? = nil
    
    var userInfo:UserInfo?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "完善基本资料"
        userInfo = DataManager.currentUser
        initView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        
        
        
        if navigationItem.rightBarButtonItem == nil {
            let sureBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
            sureBtn.setTitle("完成", for: UIControlState())
            sureBtn.setTitleColor(UIColor.white, for: UIControlState())
            sureBtn.backgroundColor = UIColor.clear
            sureBtn.addTarget(self, action: #selector(AddressSelVC.sureAction(_:)), for: .touchUpInside)
            
            let sureItem = UIBarButtonItem.init(customView: sureBtn)
            navigationItem.rightBarButtonItem = sureItem
            
        }
        
        SVProgressHUD.showProgressMessage(ProgressMessage: "初始化上传头像环境，请稍后！")
        _ = SocketManager.sendData(.uploadImageToken, data: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DataManager.currentUser?.registerSstatus = 1
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func sureAction(_ sender: UIButton) {
        
        
        guard headImageName != nil || DataManager.currentUser?.headUrl != nil else {
           
            SVProgressHUD.showWainningMessage(WainningMessage: "您还没有上传头像哦", ForDuration: 1.5, completion: nil)
            return
        }
        let nicknameField = self.cells[1]?.contentView.viewWithTag(self.tags["nicknameField"]!) as? UITextField
        guard nicknameField?.text?.characters.count > 0 else {
            
            SVProgressHUD.showWainningMessage(WainningMessage: "您还没有填写用户名哦", ForDuration: 1.5, completion: nil)
            return
        }
        let sexLab = self.cells[2]?.contentView.viewWithTag(self.tags["selectedRetLab"]!) as? UILabel
        guard sexLab?.text?.characters.count > 0 else {
            SVProgressHUD.showWainningMessage(WainningMessage: "您还没有选择性别呢", ForDuration: 1.5, completion: nil)

            return
        }
        guard address?.characters.count > 0 else {
            
            SVProgressHUD.showWainningMessage(WainningMessage: "您还没有选择常住地哦", ForDuration: 1.5, completion: nil)
            return
        }
        
        
        guard headImagePath != nil else {
            updateBaseInfo((userInfo?.headUrl)!)
            
            return
        }
        let qiniuHost = "http://ofr5nvpm7.bkt.clouddn.com/"
        let qnManager = QNUploadManager()
        SVProgressHUD.showProgressMessage(ProgressMessage: "提交中...")
        unowned let weakSelf = self
        qnManager?.putFile(headImagePath!, key: "user_center/head\(headImageName!)", token: token!, complete: { (info, key, resp) -> Void in
            
            if info?.statusCode != 200 || resp == nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                SVProgressHUD.showErrorMessage(ErrorMessage: "提交失败，请稍后再试！", ForDuration: 1, completion: nil)
                return
            }
            
            if (info?.statusCode == 200 ){
                let respDic: NSDictionary? = resp as NSDictionary?
                let value:String? = respDic!.value(forKey: "key") as? String
                let url = qiniuHost + value!
                weakSelf.updateBaseInfo(url)
//                
//                let addr = "http://restapi.amap.com/v3/geocode/geo?key=389880a06e3f893ea46036f030c94700&s=rsv3&city=35&address=%E6%9D%AD%E5%B7%9E"
//                Alamofire.request(.GET, addr).responseJSON() { response in
//                    let geocodes = ((response.result.value as? Dictionary<String, AnyObject>)!["geocodes"] as! Array<Dictionary<String, AnyObject>>).first
//                    let location = (geocodes!["location"] as! String).componentsSeparatedByString(",")
//                    XCGLogger.debug("\(location)")
//                    
//                    let nicknameField = self.cells[1]?.contentView.viewWithTag(self.tags["nicknameField"]!) as? UITextField
//                    self.nickname = nicknameField?.text
//                    let dict:Dictionary<String, AnyObject> = ["uid_": (DataManager.currentUser?.uid)!,
//                        "nickname_": self.nickname!,
//                        "gender_": self.sex,
//                        "head_url_": url,
//                        "address_": self.address!,
//                        "longitude_": Float.init(location[0])!,
//                        "latitude_": Float.init(location[1])!]
//                    self.headerUrl = url
//                    SocketManager.sendData(.SendImproveData, data: dict)
//                }
            }
            
        }, option: nil)
        
    }
    
    /**
     
     上面太长且重用 提取出来
     - parameter url:
     */
    func updateBaseInfo(_ url:String) {
        
        let addr = "http://restapi.amap.com/v3/geocode/geo?key=389880a06e3f893ea46036f030c94700&s=rsv3&city=35&address=%E6%9D%AD%E5%B7%9E"
        Alamofire.request(addr).responseJSON() { response in
            let geocodes = ((response.result.value as? Dictionary<String, AnyObject>)!["geocodes"] as! Array<Dictionary<String, AnyObject>>).first
            let location = (geocodes!["location"] as! String).components(separatedBy: ",")
            XCGLogger.debug("\(location)")
            
            let nicknameField = self.cells[1]?.contentView.viewWithTag(self.tags["nicknameField"]!) as? UITextField
            self.nickname = nicknameField?.text
            let dict:Dictionary<String, Any> = ["uid_": (DataManager.currentUser?.uid)! as AnyObject,
                "nickname_": self.nickname!,
                "gender_": self.sex,
                "head_url_": url,
                "address_": self.address!,
                "longitude_": Float.init(location[0])!,
                "latitude_": Float.init(location[1])!]
            self.headerUrl = url
            _ = SocketManager.sendData(.sendImproveData, data: dict)
        }
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .plain)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table?.separatorStyle = .none
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        view.addSubview(table!)
        table?.snp.makeConstraints({ (make) in
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
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(CompleteBaseInfoVC.improveDataSuccessed(_:)), name: NSNotification.Name(rawValue: NotifyDefine.ImproveDataSuccessed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CompleteBaseInfoVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CompleteBaseInfoVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CompleteBaseInfoVC.uploadImageToken(_:)), name: NSNotification.Name(rawValue: NotifyDefine.UpLoadImageToken), object: nil)
        
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
    
    func improveDataSuccessed(_ notification: Notification?) {
        SVProgressHUD.dismiss()
        _ = navigationController?.popViewController(animated: true)
        DataManager.currentUser?.headUrl = headerUrl
        DataManager.currentUser?.nickname = nickname
        DataManager.currentUser?.gender = sex
        DataManager.currentUser?.address = address
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotifyDefine.ImproveDataNoticeToOthers), object: nil, userInfo: nil)
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "BaseInfoHeadCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .none
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
                cell?.selectionStyle = .none
            }
            
            var bgView = cell?.contentView.viewWithTag(tags["headBG"]!)
            if bgView == nil {
                bgView = UIView()
                bgView?.backgroundColor = UIColor.clear
                cell?.contentView.addSubview(bgView!)
                bgView?.snp.makeConstraints({ (make) in
                    make.left.equalTo(cell!.contentView)
                    make.right.equalTo(cell!.contentView)
                    make.top.equalTo(cell!.contentView)
                    make.bottom.equalTo(cell!.contentView)
                    make.height.equalTo(UIScreen.main.bounds.size.width / 2.0)
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
                headView?.snp.makeConstraints({ (make) in
                    make.center.equalTo(bgView!)
                    make.width.equalTo(100)
                    make.height.equalTo(100)
                })
                
            }
            self.headView = headView
            cells[indexPath.row] = cell!
            
            guard headImageName == nil else {
                return cell!
            }
            
            guard userInfo != nil else {
                return cell!
            }
            guard userInfo?.headUrl != nil else {
                return cell!
            }
            
            
            if userInfo!.headUrl!.hasPrefix("http"){
                
                let headUrl = URL(string: userInfo!.headUrl!)
                headView?.kf.setImage(with: headUrl, placeholder: UIImage(named: "default-head"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                    
                }
            } else if userInfo!.headUrl!.hasPrefix("var"){
                let headerUrl = URL(fileURLWithPath: userInfo!.headUrl!)
                headView?.kf.setImage(with: headerUrl, placeholder: UIImage(named: "default-head"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                    
                }
            }
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "BaseInfoCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.selectionStyle = .none
            }
            cell?.accessoryType = indexPath.row == 1 ? .none : .disclosureIndicator
            
            var titleLab = cell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel
            if titleLab == nil {
                titleLab = UILabel()
                titleLab?.tag = tags["titleLab"]!
                titleLab?.backgroundColor = UIColor.clear
                titleLab?.textColor = UIColor.black
                titleLab?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(titleLab!)
                titleLab?.snp.makeConstraints({ (make) in
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
                separateLine?.snp.makeConstraints({ (make) in
                    make.left.equalTo(titleLab!)
                    make.right.equalTo(cell!.contentView).offset(40)
                    make.bottom.equalTo(cell!.contentView).offset(0.5)
                    make.height.equalTo(1)
                })
            }
            separateLine?.isHidden = (indexPath.row == 0 || indexPath.row == 3) ? true : false
            
            var nicknameField = cell?.contentView.viewWithTag(tags["nicknameField"]!) as? UITextField
            if nicknameField == nil {
                nicknameField = UITextField()
                nicknameField!.tag = tags["nicknameField"]!
                nicknameField!.isSecureTextEntry = false
                nicknameField!.delegate = self
                nicknameField!.textColor = UIColor.black
                nicknameField!.rightViewMode = .whileEditing
                nicknameField!.clearButtonMode = .whileEditing
                nicknameField!.backgroundColor = UIColor.clear
                nicknameField!.textAlignment = .right
                nicknameField!.attributedPlaceholder = NSAttributedString.init(string: "10个字符以内", attributes: [NSForegroundColorAttributeName: UIColor.gray])
                cell?.contentView.addSubview(nicknameField!)
                nicknameField!.snp.makeConstraints({ (make) in
                    make.left.equalTo(titleLab!)
                    make.top.equalTo(cell!.contentView).offset(10)
                    make.bottom.equalTo(cell!.contentView).offset(-10)
                    make.right.equalTo(cell!.contentView).offset(-20)
                    make.height.equalTo(25)
                })
            }
            nicknameField?.isHidden = indexPath.row == 1 ? false : true
            
            var selectedRetLab = cell?.contentView.viewWithTag(tags["selectedRetLab"]!) as? UILabel
            if selectedRetLab == nil {
                selectedRetLab = UILabel()
                selectedRetLab?.tag = tags["selectedRetLab"]!
                selectedRetLab?.backgroundColor = UIColor.clear
                selectedRetLab?.textColor = UIColor.gray
                selectedRetLab?.textAlignment = .right
                selectedRetLab?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(selectedRetLab!)
                selectedRetLab?.snp.makeConstraints({ (make) in
                    make.right.equalTo(cell!.contentView).offset(-10)
                    make.centerY.equalTo(titleLab!)
                })
            }
            
            cells[indexPath.row] = cell!
            
            
            guard userInfo != nil else {
                return cell!
            }
            
            if userInfo?.nickname != nil {
                nicknameField?.text = userInfo?.nickname
                nickname = userInfo?.nickname
            }
            
            if indexPath.row == 2 {
                sex = (userInfo?.gender)!
                selectedRetLab?.text = userInfo?.gender == 0 ? "女" : "男"
            } else if indexPath.row == 3 {
                if userInfo?.address != nil && userInfo?.address?.characters.count > 0 {
                    address = userInfo?.address
                    selectedRetLab?.text = userInfo?.address
                }else{
                    address = cityName
                    selectedRetLab?.text = cityName
                }
            }
            
            return cell!
        }

    }
    
    func setHeadImage() {
        initImagePick()

        let sheetController = UIAlertController.init(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        let cancelAction:UIAlertAction! = UIAlertAction.init(title: "取消", style: .cancel) { action in
            
        }
        let cameraAction:UIAlertAction! = UIAlertAction.init(title: "相机", style: .default) { action in
            self.imagePicker?.sourceType = .camera
            self.present(self.imagePicker!, animated: true, completion: nil)
        }
        let labAction:UIAlertAction! = UIAlertAction.init(title: "相册", style: .default) { action in
            self.imagePicker?.sourceType = .photoLibrary
            self.present(self.imagePicker!, animated: true, completion: nil)
        }
        sheetController.addAction(cancelAction)
        sheetController.addAction(cameraAction)
        sheetController.addAction(labAction)
        present(sheetController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            setHeadImage()
        } else if indexPath.row == 2 {
            XCGLogger.debug("性别选择")
            let alertCtrl = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let male = UIAlertAction.init(title: "男", style: .default, handler: { (sender: UIAlertAction) in
                self.sex = 1
                let sexLab = self.cells[2]?.contentView.viewWithTag(self.tags["selectedRetLab"]!) as? UILabel
                sexLab?.text = "男"
            })
            
            let female = UIAlertAction.init(title: "女", style: .default, handler: { (sender: UIAlertAction) in
                self.sex = 0
                let sexLab = self.cells[2]?.contentView.viewWithTag(self.tags["selectedRetLab"]!) as? UILabel
                sexLab?.text = "女"
            })
            
            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (sender: UIAlertAction) in
                
            })
            
            alertCtrl.addAction(male)
            alertCtrl.addAction(female)
            alertCtrl.addAction(cancel)
            
            present(alertCtrl, animated: true, completion: nil)
            
        } else if indexPath.row == 3 {
            XCGLogger.debug("常住地选择")
            let addressSelVC = AddressSelVC()
            addressSelVC.delegate = self
            navigationController?.pushViewController(addressSelVC, animated: true)
        }
    }
    
    //MARK: - UITextField
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case tags["nicknameField"]!:
            nickname = textField.text
            break
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location > 9 {
            return false
        }
        if textField.tag == tags["nicknameField"]! {
            nickname = textField.text! + string
        }
        
        return true
    }

    //MARK: - AddressSelVCDelegate
    func addressSelected(_ address: String?) {
        self.address = address
        let addressLab = self.cells[3]?.contentView.viewWithTag(self.tags["selectedRetLab"]!) as? UILabel
        addressLab?.text = address!
        XCGLogger.debug("\(self.address!)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIImagePickreControllerDelegate
    func initImagePick() {
        if imagePicker == nil {
            imagePicker = UIImagePickerController()
            imagePicker?.delegate = self
            imagePicker?.allowsEditing = true
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        headView?.image = image.reSizeImage(CGSize(width: 100, height: 100))
        
        imagePicker?.dismiss(animated: true, completion: nil)
        
        //先把图片转成NSData
        let data = UIImageJPEGRepresentation(image, 0.5)
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        
        //Home目录
        let homeDirectory = NSHomeDirectory()
        let documentPath = homeDirectory + "/Documents"
        //文件管理器
        let fileManager: FileManager = FileManager.default
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        do {
            try fileManager.createDirectory(atPath: documentPath, withIntermediateDirectories: true, attributes: nil)
            
        }
        catch _ {
        }
        let timestemp:Int = Int(Date().timeIntervalSince1970)
        let fileName = "/\(DataManager.currentUser!.uid)_\(timestemp).png"
        headImageName = fileName
        fileManager.createFile(atPath: documentPath + fileName, contents: data, attributes: nil)
        //得到选择后沙盒中图片的完整路径
        let filePath: String = String(format: "%@%@", documentPath, fileName)
        headImagePath = filePath
    }
    //MARK: --
    
    //上传图片Token
    func uploadImageToken(_ notice: Notification?) {
        let data = notice?.userInfo!["data"] as! NSDictionary
        let code = data.value(forKey: "code")
        if (code as AnyObject).int32Value == 0 {
            return
        }
        SVProgressHUD.dismiss()
        token = data.value(forKey: "img_token_") as? String
    }
}

