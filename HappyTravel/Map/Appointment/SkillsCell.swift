//
//  SkillsCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/18.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift

enum SkillsCellStyle : Int {
    case normal = 0
    case addNew = 1
    case select = 2
    case delete = 3
    case other = 4
}

@objc protocol SkillsCellDelegate : NSObjectProtocol {
    
    @objc optional func selectedAction(_ info: Dictionary<SkillInfo, Bool>)
    
    @objc optional func addNewAction()
    
    @objc optional func deleteAction(_ index: Int, info: Dictionary<SkillInfo, Bool>)
    
}

class SkillsCell : UITableViewCell {
    
    weak var delegate:SkillsCellDelegate?
    
    var style:SkillsCellStyle = .normal
    var allButtonWidth:Float = 20.0
    var skills:Array<Dictionary<SkillInfo, Bool>>?
    var collectionView:UICollectionView?
    let tags = ["bgView": 1001,
                "noTallyLabel": 1002,
                "bottomControl": 1003,
                "deleteIcon": 1004,
                "tallyBtn": 1005,
                "addnewBtn": 1006]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.white

        
        contentView.isUserInteractionEnabled = true
//        let layout = SkillWidthLayout.init()
//        layout.delegate = self
//        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
//        collectionView?.delegate = self
//        collectionView?.dataSource = self
//        collectionView?.scrollEnabled = false
//        collectionView?.backgroundColor = UIColor.clearColor()
//        collectionView?.registerClass(SingleSkillCell.self, forCellWithReuseIdentifier: "skillCell")
//        contentView.addSubview(collectionView!)
//
//        collectionView?.snp_makeConstraints(closure: { (make) in
//            
//            make.edges.equalTo(contentView)
//        })
        var noTallyLabel = contentView.viewWithTag(tags["noTallyLabel"]!) as? UILabel
        if noTallyLabel == nil {
            noTallyLabel = UILabel(frame: CGRect.zero)
            noTallyLabel!.tag = tags["noTallyLabel"]!
            noTallyLabel!.font = UIFont.systemFont(ofSize: S12)
            noTallyLabel!.numberOfLines = 0
            noTallyLabel?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
            noTallyLabel?.textAlignment = .center
            noTallyLabel!.layer.cornerRadius = 30 / 2.0
            noTallyLabel?.layer.masksToBounds = true
            noTallyLabel?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            noTallyLabel?.layer.borderWidth = 1
            noTallyLabel!.backgroundColor = UIColor.white
            contentView.addSubview(noTallyLabel!)
            noTallyLabel!.snp_makeConstraints { (make) in
                make.top.equalTo(contentView).offset(20)
                make.left.equalTo(contentView).offset(20)
                make.bottom.equalTo(contentView).offset(-20)
                make.height.equalTo(30)
                make.width.equalTo(30)
            }
        }
        noTallyLabel?.isHidden = false
        noTallyLabel!.text = "无"
        
        var addnewBtn = contentView.viewWithTag(tags["addnewBtn"]!) as? UIButton
        if addnewBtn == nil {
            addnewBtn = UIButton()
            addnewBtn?.tag = tags["addnewBtn"]!
            addnewBtn?.backgroundColor = UIColor.white
            addnewBtn?.layer.cornerRadius = 30 / 2.0
            addnewBtn?.layer.masksToBounds = true
            addnewBtn?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
            addnewBtn?.layer.borderWidth = 1
            addnewBtn?.setTitle("+", for: UIControlState())
            addnewBtn?.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), for: UIControlState())
            addnewBtn?.addTarget(self, action: #selector(SkillsCell.addNewAction(_:)), for: .touchUpInside)
            contentView.addSubview(addnewBtn!)
            addnewBtn?.snp_makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(20)
                make.top.equalTo(contentView).offset(20)
                make.bottom.equalTo(contentView).offset(-20)
                make.height.equalTo(30)
                make.width.equalTo(30)
            })
        }
    }
    
    func setInfo(_ skills: Array<Dictionary<SkillInfo, Bool>>?) {
        self.skills = skills
        
        
        for subview in  contentView.subviews {
            if subview.tag == self.tags["addnewBtn"]! || subview.tag == self.tags["noTallyLabel"]! {
                continue
            }
            subview.removeFromSuperview()
        }
        allButtonWidth = 20.0
        var lastTallyItemView:UIButton?
        if skills?.count != 0 {
            for (index, value) in skills!.enumerated() {
                for (skill, selected) in value {
                    var tallyBtn = contentView.viewWithTag(self.tags["tallyBtn"]! * 10 + index) as? UIButton
                    if tallyBtn == nil {
                        tallyBtn = UIButton()
                        tallyBtn!.tag = self.tags["tallyBtn"]! * 10 + index
                        tallyBtn!.backgroundColor = UIColor.white
                        tallyBtn?.titleEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 0)
                        tallyBtn?.layer.cornerRadius = 30 / 2.0
                        tallyBtn?.layer.masksToBounds = true
                        tallyBtn?.layer.borderWidth = 1
                        tallyBtn?.titleLabel?.font = UIFont.systemFont(ofSize: S12)
                        
                        tallyBtn?.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), for: .normal)
                        tallyBtn?.setTitleColor(UIColor.gray, for: .disabled)
                        tallyBtn?.addTarget(self, action: #selector(SkillsCell.selectAction(_:)), for: .touchUpInside)
                        contentView.addSubview(tallyBtn!)
                        /**
                         *  记录宽度
                         */
                        allButtonWidth = allButtonWidth + 10 + skill.labelWidth
                        tallyBtn!.snp_makeConstraints { (make) in
                            let previousView = contentView.viewWithTag(tallyBtn!.tag - 1)
                            if previousView == nil {
                                make.top.equalTo(self.contentView).offset(20)
                                make.left.equalTo(self.contentView).offset(20)
                            } else {
                                /**
                                 *  判断宽度 如果宽度大于屏幕宽度，另起一行
                                 */
                                if allButtonWidth > Float(ScreenWidth) {
                                    
                                    allButtonWidth = 20.0 + 10 + skill.labelWidth
                                    make.top.equalTo(previousView!.snp_bottom).offset(10)
                                    make.left.equalTo(self.contentView).offset(20)
                                } else {
                                    make.top.equalTo(previousView!)
                                    make.left.equalTo(previousView!.snp_right).offset(10)
                                }
                            }
                            
                            if index == skills!.count - 1 && style == .Normal {
                                make.bottom.equalTo(contentView).offset(-20)
                            }
                            make.height.equalTo(30)
                            make.width.equalTo(skill.labelWidth)
                        }
                    }
                    tallyBtn!.setTitle("    \(skill.skill_name_!)    ", for: .normal)
                    tallyBtn?.isEnabled = !selected
                    tallyBtn?.layer.borderColor = selected == false ? UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor : UIColor.gray.cgColor
                    
                    var deleteIcon = contentView.viewWithTag(self.tags["deleteIcon"]!) as? UILabel
                    if deleteIcon == nil {
                        deleteIcon = UILabel()
                        deleteIcon?.backgroundColor = UIColor.white
                        deleteIcon?.layer.masksToBounds = true
                        deleteIcon?.layer.cornerRadius = 20 / 2.0
                        deleteIcon?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).cgColor
                        deleteIcon?.layer.borderWidth = 1
                        deleteIcon?.text = " - "
                        deleteIcon?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
                        contentView.addSubview(deleteIcon!)
                        deleteIcon?.snp_makeConstraints({ (make) in
                            make.right.equalTo(tallyBtn!.snp_right).offset(5)
                            make.top.equalTo(tallyBtn!).offset(-5)
                            make.width.equalTo(20)
                            make.height.equalTo(20)
                        })
                    }
                    if style != .Delete {
                        deleteIcon?.isHidden = true
                    }
//                    allButtonWidth = 20.0
                    lastTallyItemView = tallyBtn
                }
                
            }
            
            if let noTallyLabel = contentView.viewWithTag(self.tags["noTallyLabel"]!) as? UILabel {
                noTallyLabel.snp_removeConstraints()
                noTallyLabel.isHidden = true
            }
         
        } else {
            if let noTallyLabel = contentView.viewWithTag(self.tags["noTallyLabel"]!) as? UILabel {
                noTallyLabel.snp_remakeConstraints { (make) in
                    make.top.equalTo(contentView).offset(20)
                    make.left.equalTo(contentView).offset(20)
                    make.bottom.equalTo(contentView).offset(-20)
                    make.height.equalTo(30)
                    make.width.equalTo(30)
                }
                noTallyLabel.isHidden = false
            }
        }

        if let addnewBtn = contentView.viewWithTag(self.tags["addnewBtn"]!) as? UIButton {
            addnewBtn.isHidden = style == .addNew ? false : true
            if lastTallyItemView != nil {
                addnewBtn.snp_remakeConstraints({ (make) in
                    if  allButtonWidth + 50 > Float(ScreenWidth) {
                        make.left.equalTo(contentView).offset(20)
                        make.top.equalTo(lastTallyItemView!.snp_bottom).offset(10)
                    } else {
                        make.left.equalTo(lastTallyItemView!.snp_right).offset(10)
                        make.top.equalTo(lastTallyItemView!)
                    }
                    make.bottom.equalTo(contentView).offset(-20)
                    make.height.equalTo(30)
                    make.width.equalTo(30)
                })
            }
        }
    }
    
    func selectAction(_ sender: UIButton) {
        let tag = sender.tag - self.tags["tallyBtn"]! * 10
        if style == .select {
            sender.isEnabled = false
            sender.layer.borderColor = UIColor.gray.cgColor
            delegate?.selectedAction!(skills![tag])
        } else if style == .delete {
            delegate?.deleteAction!(tag, info: skills![tag])
        }
        
    }
    
    func addNewAction(_ sender: UIButton) {
        if style == .addNew {
            delegate?.addNewAction!()
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - SkillWidthLayoutDelegate

extension SkillsCell:SkillWidthLayoutDelegate {
    
    func  autoLayout(_ layout:SkillWidthLayout, atIndexPath:IndexPath)->Float {
        
        let skillInfoDict = skills![atIndexPath.item]
        let skillInfo = skillInfoDict.keys.first! as SkillInfo
        return skillInfo.labelWidth
    }
}

//MARK: - UICollectionView
extension SkillsCell:UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.addNewAction!()

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count = skills == nil ? 0 : skills?.count
        
        return count!
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "skillCell", for: indexPath) as! SingleSkillCell
        let skillInfoDict = skills![indexPath.item]
        let skillInfo = skillInfoDict.keys.first! as SkillInfo
        var cellStyle = SkillsCellStyle.normal
        switch style {
        case .select:
            if skillInfoDict[skillInfo] == true {
                cellStyle = .select
            } else {
                cellStyle = .normal
            }
            break
        case .normal:
            
            cellStyle = .normal
            break
        case .delete:
            cellStyle = .delete
            break
        case .addNew:
            cellStyle = .addNew
            break
        default:
            break
        }
        cell.setupDataWith(skillInfo.skill_name_!, style: cellStyle)
        return cell
    }
}
