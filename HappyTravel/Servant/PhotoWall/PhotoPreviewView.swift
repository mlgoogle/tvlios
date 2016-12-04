//
//  PhotoPreviewView.swift
//  viossvc
//
//  Created by 陈奕涛 on 16/12/3.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import Foundation
import SnapKit

class PhotoPreviewView: UIView {
    
    private static var view = PhotoPreviewView.init(frame: UIScreen.mainScreen().bounds)
    class func defaultView() ->PhotoPreviewView {
        return view
    }
    
    var photoInfo:PhotoModel?
    
    var photo:UIImageView?
    
    static func showOnline(photoInfo: PhotoModel) {
        let view = PhotoPreviewView.defaultView()
        view.setPhotoInfoModel(photoInfo)
        UIApplication.sharedApplication().keyWindow?.addSubview(view)
    }
    
    static func showLocal(image: UIImage) {
        let view = PhotoPreviewView.defaultView()
        view.photo?.image = image
        UIApplication.sharedApplication().keyWindow?.addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = true
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        let gst = UITapGestureRecognizer()
        gst.addTarget(self, action: #selector(touched(_:)))
        addGestureRecognizer(gst)
        createView()
    }
    
    func touched(sender: UITapGestureRecognizer) {
        PhotoPreviewView.defaultView().removeFromSuperview()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        photo = UIImageView()
        photo?.contentMode = .ScaleAspectFit
        addSubview(photo!)
        photo?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(self)
        })
    }
    
    func setPhotoInfoModel(info: PhotoModel) {
        photoInfo = info
        photo?.kf_setImageWithURL(NSURL(string: photoInfo!.thumbnail_url_!))
        if photoInfo?.photo_url_ != nil {
            photo?.kf_setImageWithURL(NSURL(string: photoInfo!.photo_url_!))
        }
        
    }
    
}
