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
    case Normal = 0
    case AddNew = 1
    case Select = 2
    case Delete = 3
}

@objc protocol SkillsCellDelegate : NSObjectProtocol {
    
    optional func selectedAction(info: Dictionary<SkillInfo, Bool>)
    
    optional func addNewAction()
    
    optional func deleteAction(index: Int, info: Dictionary<SkillInfo, Bool>)
    
}

class SkillsCell : UITableViewCell {
    
    weak var delegate:SkillsCellDelegate?
    
    var style:SkillsCellStyle = .Normal
    var allButtonWidth:CGFloat = 20.0
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
        selectionStyle = .None
        contentView.backgroundColor = UIColor.whiteColor()

        
        contentView.userInteractionEnabled = true
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
            noTallyLabel = UILabel(frame: CGRectZero)
            noTallyLabel!.tag = tags["noTallyLabel"]!
            noTallyLabel!.font = UIFont.systemFontOfSize(12)
            noTallyLabel!.numberOfLines = 0
            noTallyLabel?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
            noTallyLabel?.textAlignment = .Center
            noTallyLabel!.layer.cornerRadius = 30 / 2.0
            noTallyLabel?.layer.masksToBounds = true
            noTallyLabel?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
            noTallyLabel?.layer.borderWidth = 1
            noTallyLabel!.backgroundColor = UIColor.whiteColor()
            contentView.addSubview(noTallyLabel!)
            noTallyLabel!.snp_makeConstraints { (make) in
                make.top.equalTo(contentView).offset(20)
                make.left.equalTo(contentView).offset(20)
                make.bottom.equalTo(contentView).offset(-20)
                make.height.equalTo(30)
                make.width.equalTo(30)
            }
        }
        noTallyLabel?.hidden = false
        noTallyLabel!.text = "无"
        
        var addnewBtn = contentView.viewWithTag(tags["addnewBtn"]!) as? UIButton
        if addnewBtn == nil {
            addnewBtn = UIButton()
            addnewBtn?.tag = tags["addnewBtn"]!
            addnewBtn?.backgroundColor = UIColor.whiteColor()
            addnewBtn?.layer.cornerRadius = 30 / 2.0
            addnewBtn?.layer.masksToBounds = true
            addnewBtn?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
            addnewBtn?.layer.borderWidth = 1
            addnewBtn?.setTitle("+", forState: .Normal)
            addnewBtn?.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), forState: .Normal)
            addnewBtn?.addTarget(self, action: #selector(SkillsCell.addNewAction(_:)), forControlEvents: .TouchUpInside)
            contentView.addSubview(addnewBtn!)
            addnewBtn?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(contentView).offset(20)
                make.top.equalTo(contentView).offset(20)
                make.bottom.equalTo(contentView).offset(-20)
                make.height.equalTo(30)
                make.width.equalTo(30)
            })
        }
    }
    
    func setInfo(skills: Array<Dictionary<SkillInfo, Bool>>?) {
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
            for (index, value) in skills!.enumerate() {
                for (skill, selected) in value {
                    var tallyBtn = contentView.viewWithTag(self.tags["tallyBtn"]! * 10 + index) as? UIButton
                    if tallyBtn == nil {
                        tallyBtn = UIButton()
                        tallyBtn!.tag = self.tags["tallyBtn"]! * 10 + index
                        tallyBtn!.backgroundColor = UIColor.whiteColor()
                        tallyBtn?.layer.cornerRadius = 30 / 2.0
                        tallyBtn?.layer.masksToBounds = true
                        tallyBtn?.layer.borderWidth = 1
                        tallyBtn?.setTitleColor(UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1), forState: .Normal)
                        tallyBtn?.setTitleColor(UIColor.grayColor(), forState: .Disabled)
                        tallyBtn?.addTarget(self, action: #selector(SkillsCell.selectAction(_:)), forControlEvents: .TouchUpInside)
                        contentView.addSubview(tallyBtn!)
                        tallyBtn!.snp_makeConstraints { (make) in
                            let previousView = contentView.viewWithTag(tallyBtn!.tag - 1)
                            if previousView == nil {
                                allButtonWidth = allButtonWidth + 20 + skill.labelWidth
                                make.top.equalTo(self.contentView).offset(20)
                                make.left.equalTo(self.contentView).offset(20)
                            } else {
                                if allButtonWidth + 20 > contentView.mj_w {
                                    
                                    
                                    allButtonWidth = 20.0
                                    make.top.equalTo(previousView!.snp_bottom).offset(10)
                                    make.left.equalTo(self.contentView).offset(20)
                                } else {
                                    allButtonWidth = allButtonWidth + 20 + skill.labelWidth
                                    make.top.equalTo(previousView!)
                                    make.left.equalTo(previousView!.snp_right).offset(10)
                                }
                            }
                            
                            if index == skills!.count - 1 && style == .Normal {
                                make.bottom.equalTo(contentView).offset(-20)
                            }
                            make.height.equalTo(30)
                        }
                    }
                    tallyBtn!.setTitle("    \(skill.skill_name_!)    ", forState: .Normal)
                    tallyBtn?.enabled = !selected
                    tallyBtn?.layer.borderColor = selected == false ? UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor : UIColor.grayColor().CGColor
                    
                    var deleteIcon = contentView.viewWithTag(self.tags["deleteIcon"]!) as? UILabel
                    if deleteIcon == nil {
                        deleteIcon = UILabel()
                        deleteIcon?.backgroundColor = UIColor.whiteColor()
                        deleteIcon?.layer.masksToBounds = true
                        deleteIcon?.layer.cornerRadius = 20 / 2.0
                        deleteIcon?.layer.borderColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1).CGColor
                        deleteIcon?.layer.borderWidth = 1
                        deleteIcon?.text = " - "
                        deleteIcon?.textColor = UIColor.init(red: 183/255.0, green: 39/255.0, blue: 43/255.0, alpha: 1)
                        contentView.addSubview(deleteIcon!)
                        deleteIcon?.snp_makeConstraints(closure: { (make) in
                            make.right.equalTo(tallyBtn!.snp_right).offset(5)
                            make.top.equalTo(tallyBtn!).offset(-5)
                            make.width.equalTo(20)
                            make.height.equalTo(20)
                        })
                    }
                    if style != .Delete {
                        deleteIcon?.hidden = true
                    }
//                    allButtonWidth = 20.0
                    lastTallyItemView = tallyBtn
                }
                
            }
            
            if let noTallyLabel = contentView.viewWithTag(self.tags["noTallyLabel"]!) as? UILabel {
                noTallyLabel.snp_removeConstraints()
                noTallyLabel.hidden = true
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
                noTallyLabel.hidden = false
            }
        }

        if let addnewBtn = contentView.viewWithTag(self.tags["addnewBtn"]!) as? UIButton {
            addnewBtn.hidden = style == .AddNew ? false : true
            if lastTallyItemView != nil {
                addnewBtn.snp_remakeConstraints(closure: { (make) in
                    if  allButtonWidth > contentView.mj_w {
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
    
    func selectAction(sender: UIButton) {
        let tag = sender.tag - self.tags["tallyBtn"]! * 10
        if style == .Select {
            sender.enabled = false
            sender.layer.borderColor = UIColor.grayColor().CGColor
            delegate?.selectedAction!(skills![tag])
        } else if style == .Delete {
            delegate?.deleteAction!(tag, info: skills![tag])
        }
        
    }
    
    func addNewAction(sender: UIButton) {
        if style == .AddNew {
            delegate?.addNewAction!()
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - SkillWidthLayoutDelegate

extension SkillsCell:SkillWidthLayoutDelegate {
    
    func  autoLayout(layout:SkillWidthLayout, atIndexPath:NSIndexPath)->CGFloat {
        
        let skillInfoDict = skills![atIndexPath.item]
        let skillInfo = skillInfoDict.keys.first! as SkillInfo
        return skillInfo.labelWidth
    }
}

//MARK: - UICollectionView
extension SkillsCell:UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        delegate?.addNewAction!()

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count = skills == nil ? 0 : skills?.count
        
        return count!
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("skillCell", forIndexPath: indexPath) as! SingleSkillCell
        let skillInfoDict = skills![indexPath.item]
        let skillInfo = skillInfoDict.keys.first! as SkillInfo
        var cellStyle = SkillsCellStyle.Normal
        switch style {
        case .Select:
            if skillInfoDict[skillInfo] == true {
                cellStyle = .Select
            } else {
                cellStyle = .Normal
            }
            break
        case .Normal:
            
            cellStyle = .Normal
            break
        case .Delete:
            cellStyle = .Delete
            break
        case .AddNew:
            cellStyle = .AddNew
            break
        default:
            break
        }
        cell.setupDataWith(skillInfo.skill_name_!, style: cellStyle)
        return cell
    }
}
