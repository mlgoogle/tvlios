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
            selectionStyle = .none
            titleLable.font = UIFont.systemFont(ofSize: S15)
            titleLable.textColor = UIColor.black
            titleLable.isUserInteractionEnabled = true
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
            backView.backgroundColor = UIColor.white
            contentView.addSubview(backView)
            backView.snp_makeConstraints { (make) in
                make.top.equalTo(titleLable.snp_bottom)
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.bottom.equalTo(-8)
            }
        
            iconImage.contentMode = .center
            iconImage.layer.masksToBounds = true
            iconImage.isUserInteractionEnabled = true
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
        view.backgroundColor = UIColor.white
        SVProgressHUD.showProgressMessage(ProgressMessage: "验证认证环境中，请稍后！")
        SocketManager.sendData(.uploadImageToken, data: nil)
        initTableView()
        initNav()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(UploadUserPictureVC.uploadImageToken(_:)), name: NSNotification.Name(rawValue: NotifyDefine.UpLoadImageToken), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(autoUserCardResult(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AuthenticateUserCard), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initImagePick()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
        SVProgressHUD.dismiss()
    }
    //MARK: -- Nav
    func initNav()  {
        title = "上传身份信息"  
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "提交", style: .plain, target: self, action: #selector(rightItemTapped(_:)))
    }
    func rightItemTapped(_ item: UIBarButtonItem) {
        for path in photoPaths {
            if path == "" {
                SVProgressHUD.showWainningMessage(WainningMessage: "请一次提交照片正反两面信息",ForDuration:1, completion:nil)
                return
            }
        }
        
        item.isEnabled = false
        let qnManager = QNUploadManager()
        SVProgressHUD.showProgressMessage(ProgressMessage: "提交中...")
        for (index,path) in photoPaths.enumerated() {
            qnManager?.putFile(path, key: "settings/auth/\(photoKeys[index])", token: self.token as String, complete: { (info, key, resp) -> Void in
                
                if info?.statusCode != 200 || resp == nil{
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    SVProgressHUD.showErrorMessage(ErrorMessage: "提交失败，请稍后再试！", ForDuration: 1, completion: nil)
                    return
                }
        
                if (info?.statusCode == 200 ){
                    let respDic: NSDictionary? = resp as NSDictionary?
                    let value:String? = respDic!.value(forKey: "key") as? String
                    self.photoURL["pic\(index)"] = self.qiniuHost+value!
                    if self.photoURL.count == 2{
                        var param = [NSString : AnyObject]()
                        param["uid_"] = DataManager.currentUser!.uid as AnyObject?
                        param["front_pic_"] = self.photoURL["pic1"]
                        param["back_pic_"] = self.photoURL["pic0"]
                        SocketManager.sendData(.authenticateUserCard, data:param as AnyObject?)
                    }
                }
                
            }, option: nil)
            
        }
        
    }
    //MARK: -- tableView
    func initTableView() {
        
        view.backgroundColor = colorWithHexString("#f2f2f2")
        tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView!.backgroundColor = colorWithHexString("#f2f2f2")
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.rowHeight = 182
        tableView!.register(UploadCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView!.tableFooterView = UIView()
        tableView!.separatorStyle = .none
        view.addSubview(tableView!)
        tableView!.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let sectionLabel = UILabel.init(text: "    注意：请服务者手持身份证正反图像，进行上传", font: UIFont.systemFont(ofSize: 13), textColor: colorWithHexString("#999999"))
            sectionLabel.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 30)
            return sectionLabel
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UploadCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as? UploadCell
        cell?.titleLable.text = titles[indexPath.section]
        cell?.titleLable.textColor = indexPath.section == 2 ? colorWithHexString("#999999"):UIColor.black
        cell?.iconImage.image = selectImages[indexPath.section]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 2 {
            return
        }
        
        index = indexPath.section
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

    //MARK: -- imagePicker
    func initImagePick() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = true
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        selectImages[index] = image.reSizeImage(CGSize(width: 162, height: 125))
        tableView!.reloadData()
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
        let key = "/\(DataManager.currentUser!.uid)\(timestemp)\(index).png"
        photoKeys.append(key)
        fileManager.createFile(atPath: documentPath + key, contents: data, attributes: nil)
        //得到选择后沙盒中图片的完整路径
        let filePath: String = String(format: "%@%@", documentPath, key)
        
        photoPaths[index] = filePath
    }
    //MARK: --
  
    //上传图片Token
    func uploadImageToken(_ notice: Notification?) {
        let data = notice?.userInfo!["data"] as! NSDictionary
        let code = data.value(forKey: "code")
        if (code as AnyObject).int32Value == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "暂时无法验证，请稍后再试", ForDuration: 1, completion: { 
                    self.navigationController?.popViewController(animated: true)
            })
            return
        }
        SVProgressHUD.dismiss()
        token = data.value(forKey: "img_token_") as! NSString
    }
    //认证结果
    func autoUserCardResult(_ notice: Notification?) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        let data = notice?.userInfo!["data"] as! NSDictionary
        let resultCode = data.value(forKey: "review_status_") as? Int
        if resultCode! == 0 {
            SVProgressHUD.dismiss()
            let alter: UIAlertController = UIAlertController.init(title: "提交成功", message: nil, preferredStyle: .alert)
            let backActiong: UIAlertAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
                alter.dismiss(animated: true, completion:nil)
                 self.navigationController?.popViewController(animated: true)
            }
            alter.addAction(backActiong)
            present(alter, animated: true, completion: nil)
        } else {
            SVProgressHUD.showErrorMessage(ErrorMessage: "提交失败，请稍后再试", ForDuration: 1, completion: nil)
        }
    }

}
