//
//  ServantReportFooterView.swift
//  HappyTravel
//
//  Created by 千山暮雪 on 2017/3/22.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit

class ServantReportFooterView: UIView,UITextViewDelegate {
    
    var textView:UITextView?
    var placeholder:UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        addViews()
    }
    
    func addViews() {
        
        let titleLabel:UILabel = UILabel.init()
        titleLabel.font = UIFont.systemFontOfSize(16)
        titleLabel.textColor = UIColor.init(decR: 153, decG: 153, decB: 153, a: 1)
        titleLabel.text = "问题补充"
        self.addSubview(titleLabel)
        
        textView = UITextView.init()
        textView?.font = UIFont.systemFontOfSize(16)
        textView?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        textView?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        textView?.delegate = self
        textView?.returnKeyType = .Done
        self.addSubview(textView!)
        
        placeholder = UILabel.init()
        placeholder?.textColor = UIColor.init(decR: 153, decG: 153, decB: 153, a: 1)
        placeholder?.font = UIFont.systemFontOfSize(16)
        placeholder?.backgroundColor = UIColor.clearColor()
        placeholder?.text = "请输入问题补充"
        textView?.addSubview(placeholder!)
        
        // 加约束
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(16)
            make.width.equalTo(150)
            make.height.equalTo(45)
        }
        
        textView?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(self).offset(16)
            make.top.equalTo(titleLabel.snp_bottom)
            make.right.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-6)
        })
        
        placeholder?.snp_makeConstraints(closure: { (make) in
            make.left.top.equalTo(6)
            make.width.equalTo(150)
            make.height.equalTo(16)
        })
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.text.characters.count == 0 {
            textView.addSubview(placeholder!)
        }else {
            placeholder?.removeFromSuperview()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
