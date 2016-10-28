//
//  UploadUserPictureVC.swift
//  HappyTravel
//
//  Created by CloudTopDevOne on 2016/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import Qiniu

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
            contentView.addSubview(titleLable)
            titleLable.snp_makeConstraints { (make) in
                make.top.equalTo(15)
                make.left.equalTo(15)
                make.height.equalTo(15)
            }
            
            
            backView.layer.cornerRadius = 5
            backView.backgroundColor = UIColor.whiteColor()
            contentView.addSubview(backView)
            backView.snp_makeConstraints { (make) in
                make.top.equalTo(titleLable.snp_bottom).offset(12)
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.bottom.equalTo(-8)
            }
        
            iconImage.contentMode = .Center
            iconImage.layer.masksToBounds = true
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
}

class UploadUserPictureVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var tableView:UITableView! = UITableView.init(frame: CGRectZero, style: .Plain)
    
    let titles:[String]! = ["正面","背面","示例","注意"]
    var selectImages:[UIImage]! = [UIImage.init(named: "tianjia")!,UIImage.init(named: "tianjia")!,UIImage.init(named: "example")!]
    var index:NSInteger = 0
    var imagePicker:UIImagePickerController? = nil
    var photoPaths:[String] = []
    
    //MARK: -- LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initImagePick()
        initTableView()
        initNav()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    deinit{
        
    }
    //MARK: -- Nav
    func initNav()  {
        title = "上传身份信息"
        
        let nextLabel = UILabel.init(text: "下一步", font: UIFont.systemFontOfSize(15), textColor: UIColor.whiteColor())
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: nextLabel)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "下一步", style: .Plain, target: self, action: #selector(rightItemTapped(_:)))
    }
    func rightItemTapped(item: UIBarButtonItem) {
        let token = "7IH8GbgsJ1h0pVye98BPKqcGGvtyu1aouVSyeYo7:UslVOLze87dvvwIcxnw8FIehLkk=:eyJzY29wZSI6Im1hcmtkb3duIiwiZGVhZGxpbmUiOjE0Nzc2NTI4MTh9"
        let qnManager = QNUploadManager()
        for path in photoPaths {
            qnManager.putFile(path, key: nil, token: token, complete: { (info, key, resp) -> Void in
                if (info.statusCode == 200 && resp != nil){
                    
                }else{
                    
                }
                
                }, option: nil)
            
        }
        
    }
    //MARK: -- tableView
    func initTableView() {
        tableView.backgroundColor = colorWithHexString("#f2f2f2")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 180
        tableView.registerClass(UploadCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
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
        selectImages![index] = image.reSizeImage(CGSizeMake(162, 125))
        tableView.reloadData()
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
        catch let _ {
        }
        fileManager.createFileAtPath(documentPath.stringByAppendingString("/image.png"), contents: data, attributes: nil)
        //得到选择后沙盒中图片的完整路径
        let filePath: String = String(format: "%@%@", documentPath, "/image.png")
        
        photoPaths.append(filePath)
    }
    //MARK: -- DATA
    func initData() {
        
    }
    
   
}
