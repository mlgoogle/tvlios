//
//  POIInfoCell.swift
//  TestAdress
//
//  Created by J-bb on 16/12/29.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import UIKit

class POIInfoCell: UITableViewCell {

    var nameLabel:UILabel = {
       
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        return label
    }()

    var adressLabel:UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)

        return label
    }()
    
    var selectImageView:UIImageView = {
       let imageView = UIImageView()
        
        imageView.image = UIImage(named: "checkMark")
        return imageView
    }()
    
    
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.addSubview(nameLabel)
        contentView.addSubview(adressLabel)
        contentView.addSubview(selectImageView)
        
        nameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(5)
            make.right.equalTo(50)
            make.height.equalTo(20)
        }
        
        adressLabel.snp_makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.right.equalTo(nameLabel)
            make.left.equalTo(nameLabel)
            make.height.equalTo(20)
        }
        selectImageView.snp_makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-20)
        }
    }
    
    func setDataWithModel(poiModel:POIInfoModel) {
        nameLabel.text = poiModel.name
        adressLabel.text = poiModel.detail
        selectImageView.hidden = !poiModel.isSelect
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
