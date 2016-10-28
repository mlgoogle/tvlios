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
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.mainScreen().scale);
        self.drawInRect(CGRectMake(0, 0, reSize.width, reSize.height));
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSizeMake(self.size.width * scaleSize, self.size.height * scaleSize)
        return reSizeImage(reSize)
    }
}