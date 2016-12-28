//
//  baseWebView.swift
//  HappyTravel
//
//  Created by 司留梦 on 16/12/27.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit
import WebKit
class BaseWebView: UIViewController {
    var requestUrl:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "保险说明"
        self.view.backgroundColor = UIColor.redColor()
        let webView = WKWebView()
        view.addSubview(webView)
        webView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        let url = NSURL(string: "http://www.yundiantrip.com")
//        let url = NSURL(string: requestUrl!)
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
