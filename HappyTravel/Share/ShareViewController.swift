//
//  ShareViewController.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/12.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD

class ShareItem: UICollectionViewCell {
   
    lazy var shareIcon: UIImageView = {
       let icon = UIImageView.init()
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    
    lazy var shareTitle: UILabel = {
       let label = UILabel.init(text: "", font: UIFont.systemFont(ofSize: S15), textColor: colorWithHexString("#666666"))
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(shareIcon)
        shareIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(AtapteWidthValue(10))
            
            make.width.equalTo(CGSize(width: AtapteWidthValue(60), height: AtapteWidthValue(60)))
        }
        
        contentView.addSubview(shareTitle)
        shareTitle.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(shareIcon.snp.bottom).offset(12)
            make.height.equalTo(S15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ShareViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    let shareTitles = ["微信","朋友圈"]
    let shareImageNames = ["share-wechat","share-wechat-moment"]
    var shareImage: UIImage = UIImage()
    //分享按钮
    lazy var shareCollection: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
       layout.itemSize = CGSize.init(width: ScreenWidth / 2 - 20, height: AtapteWidthValue(102))
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
       let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.layer.cornerRadius = 8
        collection.backgroundColor = UIColor.white
        collection.register(ShareItem.classForCoder(), forCellWithReuseIdentifier: "ShareItem")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        return collection
    }()
    //取消按钮
    lazy var cancelBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("取消", for: UIControlState())
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = UIFont.systemFont(ofSize: S18)
        btn.setTitleColor(colorWithHexString("#666666"), for: UIControlState())
        btn.backgroundColor = UIColor.white
        btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        return btn
    }()
    func cancelBtnTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(shareResult), name: NSNotification.Name(rawValue: NotifyDefine.WeChatShareResult), object: nil)
        
        initView()
    }
    func initView() {
        let bgView = UIView.init(frame: view.bounds)
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.5
        view.addSubview(bgView)
        
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(AtapteWidthValue(-10))
            make.left.equalTo(AtapteWidthValue(10))
            make.right.equalTo(AtapteWidthValue(-10))
            make.height.equalTo(AtapteWidthValue(50))
        }
        
        
        initShareCollectionView()
        view.addSubview(shareCollection)
        shareCollection.snp.makeConstraints { (make) in
            make.bottom.equalTo(cancelBtn.snp.top).offset(-AtapteWidthValue(10))
            make.left.equalTo(AtapteWidthValue(10))
            make.right.equalTo(AtapteWidthValue(-10))
            make.height.equalTo(AtapteWidthValue(160))
        }
    }
    /**
     初始化collection
     */
    func initShareCollectionView() {
        shareCollection.delegate = self
        shareCollection.dataSource = self
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareTitles.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: ScreenWidth, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      
        let sectionHeader: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath)
        let headerLabel = UILabel.init(text: "分享到", font: UIFont.systemFont(ofSize: S18), textColor: colorWithHexString("#666666"))
        headerLabel.textAlignment = .center
        headerLabel.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: AtapteWidthValue(50))
        sectionHeader.addSubview(headerLabel)
        return sectionHeader
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item: ShareItem = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareItem", for: indexPath) as! ShareItem
        item.shareIcon.image = UIImage.init(named: shareImageNames[indexPath.row])
        item.shareTitle.text = shareTitles[indexPath.row]
        return item
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message: WXMediaMessage = WXMediaMessage.init()
        message.setThumbImage(shareImage)
        let imageObject: WXImageObject = WXImageObject.init()
        imageObject.imageData = UIImageJPEGRepresentation(shareImage, 0.5)
        message.mediaObject = imageObject
        
        let req: SendMessageToWXReq = SendMessageToWXReq.init()
        req.bText = false
        req.message = message
        req.scene = Int32(indexPath.row)
        WXApi.send(req)
    }
    func shareResult(_ notice: Notification) {
        let dic = notice.object as! [String : Any]
        if dic == nil {
            return
        }
        let message: String = dic["result"] as! String
        if message == "分享成功" {
            SVProgressHUD.showSuccessMessage(SuccessMessage: "分享成功", ForDuration: 1, completion: { () in
                self.dismiss(animated: true, completion: nil)
            })
        }else{
            SVProgressHUD.showErrorMessage(ErrorMessage: "分享失败！", ForDuration: 1, completion:  { () in
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
