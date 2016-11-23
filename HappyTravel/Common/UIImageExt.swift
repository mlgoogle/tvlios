//
//  UIImageExt.swift
//  HappyTravel
//
//  Created by CloudTopDevOne on 2016/10/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

import UIKit

extension UIImage {
    /**
     *  重设图片大小
     */
    func reSizeImage(_ reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(_ scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize)
    }
}
