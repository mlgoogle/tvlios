//
//  SVProgressHUDExt.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/2.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import SVProgressHUD

extension SVProgressHUD{
    
    public class func showErrorMessage(ErrorMessage message: String, ForDuration duration: Double, completion: (() -> Void)?) {
        initStyle()
        SVProgressHUD.showErrorWithStatus(message)
        dismissWithDuration(Duration: duration,completion:completion)
    }
    
    public class func showSuccessMessage(SuccessMessage message: String, ForDuration duration: Double, completion: (() -> Void)?){
        initStyle()
        SVProgressHUD.showSuccessWithStatus(message)
        dismissWithDuration(Duration: duration,completion:completion)
    }
    
    public class func showWainningMessage(WainningMessage message: String, ForDuration duration: Double, completion: (() -> Void)?){
        initStyle()
        SVProgressHUD.showInfoWithStatus(message)
        dismissWithDuration(Duration: duration,completion:completion)
    }
    
    public class func showProgressMessage(ProgressMessage message: String){
        initStyle()
        SVProgressHUD.showWithStatus(message)
        SVProgressHUD.dismissWithDuration(Duration: 15, completion: nil)
    }

    public class func initStyle(){
        SVProgressHUD.setDefaultStyle(.Dark)
        SVProgressHUD.setDefaultMaskType(.None)
    }
    
    public class func dismissWithDuration(Duration duration: Double,completion: (() -> Void)?){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64 (duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            SVProgressHUD.dismiss()
            if ((completion) != nil) {
                completion!()
            }
        })
    }
}