//
//  AboutUSVC.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/28.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import WebKit
class AboutUSVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "关于我们"
        let webView = WKWebView()
        view.addSubview(webView)
        webView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        let url = NSURL(string: "http://www.yundiantrip.com")
        webView.loadRequest(NSURLRequest(URL: url!))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
