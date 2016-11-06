//
//  UploadUserPictureVC.swift
//  HappyTravel
//
//  Created by CloudTopDevOne on 2016/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import Qiniu
import XCGLogger
import SVProgressHUD


class UploadCell: UITableViewCell {
    var titleLable:UILabel! = UILabel()
    var iconImage:UIImageView! = UIImageView()
    let backView:UIView! = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if !self.isEqual(nil) {
            contentView.backgroundColor = colorWithHexString("#f2f2f2")
            selectionStyle = .None
            titleLable.font = UIFont.systemFontOfSize(15)
            titleLable.textColor = UIColor.blackColor()
            titleLable.userInteractionEnabled = true
            contentView.addSubview(titleLable)
            titleLable.snp_makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.height.equalTo(42)
            }
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(titleLabTapped))
            titleLable.addGestureRecognizer(tapGesture)
            
            backView.layer.cornerRadius = 5
            backView.backgroundColor = UIColor.whiteColor()
            contentView.addSubview(backView)
            backView.snp_makeConstraints { (make) in
                make.top.equalTo(titleLable.snp_bottom)
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.bottom.equalTo(-8)
            }
        
            iconImage.contentMode = .Center
            iconImage.layer.masksToBounds = true
            iconImage.userInteractionEnabled = true
            backView.addSubview(iconImage)
            iconImage.snp_makeConstraints { (make) in
                make.top.equalTo(0)
                make.bottom.equalTo(0)
                make.width.equalTo(162)
                make.centerX.equalTo(backView.snp_centerX)
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func titleLabTapped() {
        
    }
}

class UploadUserPictureVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var tableView:UITableView?
    let titles:[String]! = ["正面","背面","示例","注意"]
    var selectImages:[UIImage] = [UIImage.init(named: "tianjia")!,UIImage.init(named: "tianjia")!,UIImage.init(named: "example")!]
    var index:NSInteger = 0
    var token:NSString = ""
    var imagePicker:UIImagePickerController? = nil
    var photoPaths:[String] = ["",""]
    var photoURL = [NSString: NSString]()
    var photoKeys = [String]()
    var qiniuHost = "http://ofr5nvpm7.bkt.clouddn.com/"
    //MARK: -- LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        SVProgressHUD.showProgressMessage(ProgressMessage: "验证认证环境中，请稍后！")
        SocketManager.sendData(.UploadImageToken, data: nil)
        initTableView()
        initNav()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadUserPictureVC.uploadImageToken(_:)), name: NotifyDefine.UpLoadImageToken, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(autoUserCardResult(_:)), name: NotifyDefine.AuthenticateUserCard, object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initImagePick()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        SVProgressHUD.dismiss()
    }
    //MARK: -- Nav
    func initNav()  {
        title = "上传身份信息"  
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "提交", style: .Plain, target: self, action: #selector(rightItemTapped(_:)))
    }
    func rightItemTapped(item: UIBarButtonItem) {
        for path in photoPaths {
            if path == "" {
                SVProgressHUD.showWainningMessage(WainningMessage: "请一次提交照片正反两面信息",ForDuration:1, completion:nil)
                return
            }
        }
        
        item.enabled = false
        let qnManager = QNUploadManager()
        SVProgressHUD.showProgressMessage(ProgressMessage: "提交中...")
        for (index,path) in photoPaths.enumerate() {
            qnManager.putFile(path, key: "settings/auth/\(photoKeys[index])", token: self.token as String, complete: { (info, key, resp) -> Void in
                
                if info.statusCode != 200 || resp == nil{
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    SVProgressHUD.showErrorMessage(ErrorMessage: "提交失败，请稍后再试！", ForDuration: 1, completion: nil)
                    return
                }
        
                if (info.statusCode == 200 ){
                    let respDic: NSDictionary? = resp
                    let value:String? = respDic!.valueForKey("key") as? String
                    self.photoURL["pic\(index)"] = self.qiniuHost+value!
                    if self.photoURL.count == 2{
                        var param = [NSString : AnyObject]()
                        param["uid_"] = DataManager.currentUser!.uid
                        param["front_pic_"] = self.photoURL["pic1"]
                        param["back_pic_"] = self.photoURL["pic0"]
                        SocketManager.sendData(.AuthenticateUserCard, data:param)
                    }
                }
                
            }, option: nil)
            
        }
        
    }
    //MARK: -- tableView
    func initTableView() {
        
        view.backgroundColor = colorWithHexString("#f2f2f2")
        tableView = UITableView.init(frame: CGRectZero, style: .Plain)
        tableView!.backgroundColor = colorWithHexString("#f2f2f2")
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.rowHeight = 182
        tableView!.registerClass(UploadCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView!.tableFooterView = UIView()
        tableView!.separatorStyle = .None
        view.addSubview(tableView!)
        tableView!.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }
        return 0
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let sectionLabel = UILabel.init(text: "    注意：请服务者手持身份证正反图像，进行上传", font: UIFont.systemFontOfSize(13), textColor: colorWithHexString("#999999"))
            sectionLabel.frame = CGRectMake(0, 0, ScreenWidth, 30)
            return sectionLabel
        }
        return UIView()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UploadCell? = tableView.dequeueReusableCellWithIdentifier("cell") as? UploadCell
        cell?.titleLable.text = titles[indexPath.section]
        cell?.titleLable.textColor = indexPath.section == 2 ? colorWithHexString("#999999"):UIColor.blackColor()
        cell?.iconImage.image = selectImages[indexPath.section]
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section == 2 {
            return
        }
        
        index = indexPath.section
        let sheetController = UIAlertController.init(title: "选择图片", message: nil, preferredStyle: .ActionSheet)
        let cancelAction:UIAlertAction! = UIAlertAction.init(title: "取消", style: .Cancel) { action in
            
        }
        let cameraAction:UIAlertAction! = UIAlertAction.init(title: "相机", style: .Default) { action in
            self.imagePicker?.sourceType = .Camera
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }
        let labAction:UIAlertAction! = UIAlertAction.init(title: "相册", style: .Default) { action in
            self.imagePicker?.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }
        sheetController.addAction(cancelAction)
        sheetController.addAction(cameraAction)
        sheetController.addAction(labAction)
        presentViewController(sheetController, animated: true, completion: nil)
        
    }

    //MARK: -- imagePicker
    func initImagePick() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = true
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        selectImages[index] = image.reSizeImage(CGSizeMake(162, 125))
        tableView!.reloadData()
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        
        //先把图片转成NSData
        let data = UIImageJPEGRepresentation(image, 0.5)
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        
        //Home目录
        let homeDirectory = NSHomeDirectory()
        let documentPath = homeDirectory + "/Documents"
        //文件管理器
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        do {
            try fileManager.createDirectoryAtPath(documentPath, withIntermediateDirectories: true, attributes: nil)
            
        }
        catch _ {
        }
        let timestemp:Int = Int(NSDate().timeIntervalSince1970)
        let key = "/\(DataManager.currentUser!.uid)\(timestemp)\(index).png"
        photoKeys.append(key)
        fileManager.createFileAtPath(documentPath.stringByAppendingString(key), contents: data, attributes: nil)
        //得到选择后沙盒中图片的完整路径
        let filePath: String = String(format: "%@%@", documentPath, key)
        
        photoPaths[index] = filePath
    }
    //MARK: --
  
    //上传图片Token
    func uploadImageToken(notice: NSNotification?) {
        let data = notice?.userInfo!["data"] as! NSDictionary
        let code = data.valueForKey("code")
        if code?.intValue == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法验证，请稍后再试", ForDuration: 1, completion: { 
                    self.navigationController?.popViewControllerAnimated(true)
            })
            return
        }
        SVProgressHUD.dismiss()
        token = data.valueForKey("img_token_") as! NSString
    }
    //认证结果
    func autoUserCardResult(notice: NSNotification?) {
        navigationItem.rightBarButtonItem?.enabled = true
        let data = notice?.userInfo!["data"] as! NSDictionary
        let resultCode = data.valueForKey("review_status_")?.integerValue
        switch resultCode {
        case 0 as NSInteger :
            SVProgressHUD.dismiss()
            let alter: UIAlertController = UIAlertController.init(title: "提交成功", message: nil, preferredStyle: .Alert)
            let backActiong: UIAlertAction = UIAlertAction.init(title: "确定", style: .Default) { (action) in
                alter.dismissViewControllerAnimated(true, completion:nil)
                 self.navigationController?.popViewControllerAnimated(true)
            }
            alter.addAction(backActiong)
            presentViewController(alter, animated: true, completion: nil)
            
        default:
            SVProgressHUD.showErrorMessage(ErrorMessage: "提交失败，请稍后再试", ForDuration: 1, completion: nil)
        }
    }

}