//
//  AppointmentRemarksCell.swift
//  HappyTravel
//
//  Created by J-bb on 16/11/21.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import UIKit

class AppointmentRemarksCell: UITableViewCell, UITextViewDelegate {

    var titleLabel:UILabel = {
       
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(S15)
        label.text = "备注信息"
        return label
    }()
    
    
    var remarksTextView:UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFontOfSize(S15)
        textView.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        textView.textColor = UIColor.init(decR: 200, decG: 200, decB: 200, a: 1)
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.returnKeyType = .Done
        return textView
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.addSubview(titleLabel)
        contentView.addSubview(remarksTextView)
        remarksTextView.delegate = self
        addSubviewContrains()
    }
    
    
    func addSubviewContrains() {
        
        titleLabel.snp_makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.width.equalTo(80)
            make.top.equalTo(15)
        }
        remarksTextView.snp_makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp_right).offset(15)
            make.top.equalTo(15)
            make.bottom.equalTo(-23)
            make.right.equalTo(-15)
            make.height.equalTo(90)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n")
        {
            textView.endEditing(true)
            return false;
        }
        
        return true;
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
