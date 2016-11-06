//
//  ForthwithVCFeedBackExt.swift
//  HappyTravel
//
//  Created by 木柳 on 2016/11/6.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

extension ForthwithVC{
    func jumpToFeedBackVC() {
        feedBack.hideContactInfoView = true
        feedBack.makeFeedbackViewControllerWithCompletionBlock { (feedBackController, error) in
            if feedBackController != nil{
                feedBackController.title = "用户反馈"
                let nav = UINavigationController.init(rootViewController: feedBackController)
                feedBackController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "关闭", style: .Plain, target: self, action: #selector(self.dismissFeedBack))
                self.presentViewController(nav, animated: true, completion: nil)
                
            }
        }
    }
    
    func dismissFeedBack()  {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}