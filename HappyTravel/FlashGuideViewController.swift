//
//  FlashGuideViewController.swift
//  TestAdress
//
//  Created by J-bb on 17/1/14.
//  Copyright © 2017年 J-bb. All rights reserved.
//

import UIKit

class FlashGuideViewController: UIViewController , ShowHomePageActionDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        let images:Array<UIImage> = [UIImage(named: "444.jpg")!, UIImage(named: "222.jpg")!, UIImage(named: "333.jpg")!, UIImage(named: "111.jpg")!]
        let flashGuideView = FlashGuideView(imagesArray: images)
        flashGuideView.delegate = self
        view.addSubview(flashGuideView)
    }
    
    func selectAtLastPage() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(1.1, forKey: "guideVersion")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController() as! ViewController
        vc.modalTransitionStyle = .CrossDissolve
//        presentViewController(vc, animated: true, completion: nil)
        UIApplication.sharedApplication().keyWindow?.rootViewController = vc
    }
    
    
    

}
