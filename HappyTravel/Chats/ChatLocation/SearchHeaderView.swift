//
//  SearchHeaderView.swift
//  TestAdress
//
//  Created by J-bb on 16/12/30.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import UIKit

class SearchHeaderView: UITableViewHeaderFooterView {

    
    lazy var backView:UIView = {
        let view = UIView()
      
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
        return view
    }()
    
    lazy var searchImageView:UIImageView = {
       let imageView = UIImageView()
        
        imageView.image = UIImage(named: "chat_search")
        return imageView
    }()
    
    lazy var textField:UITextField = {
       let textField = UITextField()
        textField.font = UIFont.systemFontOfSize(16)
        textField.placeholder = "搜索"
        textField.returnKeyType = .Search
        textField.becomeFirstResponder()
        return textField
        
    }()
    
    lazy var cancelButton:UIButton = {
       
        let button = UIButton(type: .Custom)
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(UIColor(red: 102 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0), forState: .Normal)
        button.setTitle("取消", forState: .Normal)
        return button
    }()
    
   override init(reuseIdentifier: String?) {
    
    super.init(reuseIdentifier: reuseIdentifier)
    backgroundColor = UIColor(white: 1.0, alpha: 0.5)
    addSubview(backView)
    addSubview(cancelButton)
    backView.addSubview(textField)
    backView.addSubview(searchImageView)
    cancelButton.snp_makeConstraints { (make) in
        make.right.equalTo(-10)
        make.bottom.equalTo(-10)
        make.width.equalTo(44)
    }
    
    
    backView.snp_makeConstraints { (make) in
        make.left.equalTo(10)
        make.right.equalTo(cancelButton.snp_left).offset(-10)
        make.centerY.equalTo(cancelButton.snp_centerY)
        make.height.equalTo(40)
    }
    
    
    searchImageView.snp_makeConstraints { (make) in
        make.left.equalTo(10)
        make.centerY.equalTo(backView)
        make.height.equalTo(16)
        make.width.equalTo(16)
    }
    textField.snp_makeConstraints { (make) in
        make.left.equalTo(searchImageView.snp_right).offset(5)
        make.right.equalTo(10)
        make.height.equalTo(30)
        make.centerY.equalTo(backView)
    }
    
    
    
    }
    


    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
