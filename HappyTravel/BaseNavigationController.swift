//
//  BaseNavigationController.swift
//  HappyTravel
//
//  Created by macbook air on 17/3/8.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseNavigationController: UINavigationController,UINavigationControllerDelegate ,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.enabled = true
        self.interactivePopGestureRecognizer?.delegate = self
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewWillAppear(animated: Bool) {
//        self.navigationBar.shadowImage = UIImage.init(named: "nav_clear")
//        self.navigationBar.setBackgroundImage(UIImage.init(named: "nav_main"), for: .any, barMetrics: .default)
    }
    //MARK: 重新写左面的导航
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        
        super.pushViewController(viewController, animated: true)
        
        let btn : UIButton = UIButton.init(type: .Custom)
        
        btn.setTitle("", forState: .Normal)
        
        btn.setBackgroundImage(UIImage.init(named: "return"), forState: .Normal)
        
        btn.addTarget(self, action: #selector(popself), forControlEvents: .TouchUpInside)
        
        btn.frame = CGRect.init(x: 0, y: 0, width: 12, height: 20)
        
        let barItem : UIBarButtonItem = UIBarButtonItem.init(customView: btn)
        viewController.navigationItem.leftBarButtonItem = barItem
        interactivePopGestureRecognizer?.delegate = self
    }
    func popself(){
        SVProgressHUD.dismiss()
        if viewControllers.count > 1 {
            self.popViewControllerAnimated(true)
        }else{

        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (viewControllers.count <= 1)
        {
            return false;
        }
        
        return true;
    }
    
}
