//
//  CommonMethod.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/12/4.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import Qiniu

typealias CompleteBlock = (AnyObject?) ->()
typealias ErrorBlock = (NSError) ->()

/**
 七牛上传图片
 
 - parameter image:     图片
 - parameter imagePath: 图片服务器路径
 - parameter imageName: 图片名
 - parameter tags: 图片标记
 - parameter complete:  图片完成Block
 */
func qiniuUploadImage(image: UIImage, imagePath: String, imageName:String, tags:[String: AnyObject], complete:CompleteBlock) {
    let timestemp = NSDate().timeIntervalSince1970
    let timeStr = String.init(timestemp).stringByReplacingOccurrencesOfString(".", withString: "")
    //0,将图片存到沙盒中
    let filePath = cacheImage(image, imageName: "/tmp_" + timeStr)
    //1,请求token
    APIHelper.commonAPI().uploadPhotoToken( { (response) in
        if let model = response as? UploadPhotoModel {
            let qiniuManager = QNUploadManager()
            qiniuManager.putFile(filePath, key: imagePath + imageName + "_\(timeStr)", token: model.img_token_, complete: { (info, key, resp) in
                try! NSFileManager.defaultManager().removeItemAtPath(filePath)
                if resp == nil{
                    NSLog(info.debugDescription)
                    complete([tags, "failed"])
                    return
                }
                //3,返回URL
                let respDic: NSDictionary? = resp
                let value:String? = respDic!.valueForKey("key") as? String
                let imageUrl = "http://ofr5nvpm7.bkt.clouddn.com/" + value!
                complete([tags, imageUrl])
                }, option: nil)
        }
    }, error: nil)
    
}

/**
 缓存图片
 
 - parameter image:     图片
 - parameter imageName: 图片名
 - returns: 图片沙盒路径
 */
func cacheImage(image: UIImage ,imageName: String) -> String {
    let data = UIImageJPEGRepresentation(image, 0.5)
    let homeDirectory = NSHomeDirectory()
    let documentPath = homeDirectory + "/Documents"
    let fileManager: NSFileManager = NSFileManager.defaultManager()
    do {
        try fileManager.createDirectoryAtPath(documentPath, withIntermediateDirectories: true, attributes: nil)
    }
    catch _ {
    }
    let key = "\(imageName).png"
    fileManager.createFileAtPath(documentPath.stringByAppendingString(key), contents: data, attributes: nil)
    //得到选择后沙盒中图片的完整路径
    let filePath: String = String(format: "%@%@", documentPath, key)
    return filePath
}


