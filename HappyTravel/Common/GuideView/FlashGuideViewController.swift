//
//  FlashGuideViewController.swift
//  TestAdress
//
//  Created by J-bb on 17/1/14.
//  Copyright © 2017年 J-bb. All rights reserved.
//

import UIKit

protocol FlashGuideViewControllerDelegate: NSObjectProtocol {
    
    func guideEnd()
}

class FlashGuideViewController: UIViewController , ShowHomePageActionDelegate{

    weak var delegate:FlashGuideViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let images:Array<UIImage> = [UIImage(named: "guide01.jpg")!, UIImage(named: "guide02.jpg")!]
        let flashGuideView = FlashGuideView(imagesArray: images)
        flashGuideView.delegate = self
        view.addSubview(flashGuideView)
    }
    
    func selectAtLastPage() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(1.2, forKey: "guideVersion")
        delegate?.guideEnd()
    }
    
    
    

}
