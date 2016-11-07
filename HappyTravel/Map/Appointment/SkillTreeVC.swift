//
//  SkillTreeVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/19.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
import RealmSwift

protocol SkillTreeVCDelegate : NSObjectProtocol {
    
    func endEdit(skills: Array<Dictionary<SkillInfo, Bool>>)
    
}

class SkillTreeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, SkillsCellDelegate {
    
    weak var delegate:SkillTreeVCDelegate?
    
    var table:UITableView?
    var skills:Array<Dictionary<SkillInfo, Bool>> = []

    var selectedSkills:Array<Dictionary<SkillInfo, Bool>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        navigationItem.title = "选择技能"
        
        initData()
        
        initView()
        
        registerNotify()
    }
    
    func initData() {
        if let infos = DataManager.getData(SkillInfo.self, filter: nil) as? Results<SkillInfo> {
            for info in infos {
                var selected = false
                for sk in selectedSkills {
                    for (skill, _) in sk {
                        if skill.skill_id_ == info.skill_id_ {
                            selected = true
                        }

                    }
                }
                skills.append([info: selected])
                
            }
            
        }
        
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .None
        table?.registerClass(SkillsCell.self, forCellReuseIdentifier: "SkillsCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func registerNotify() {
        
    }
    
    
    // MARK: - UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SkillsCell", forIndexPath: indexPath) as? SkillsCell
            cell?.delegate = self
            cell?.style = .Delete
            cell?.setInfo(selectedSkills)
            return cell!
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SkillsCell", forIndexPath: indexPath) as? SkillsCell
            cell?.delegate = self
            cell?.style = .Select
            cell?.setInfo(skills)
            return cell!
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("OKCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .Default, reuseIdentifier: "OKCell")
                cell?.selectionStyle = .None
                cell?.backgroundColor = UIColor.clearColor()
                cell?.contentView.backgroundColor = UIColor.clearColor()
            }
            
            var ok = cell?.contentView.viewWithTag(1001) as? UIButton
            if ok == nil {
                ok = UIButton()
                ok?.tag = 1001
                ok?.setTitle("确定", forState: .Normal)
                ok?.backgroundColor = UIColor.init(red: 30/255.0, green: 40/255.0, blue: 60/255.0, alpha: 1)
                ok?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                ok?.layer.cornerRadius = 5
                ok?.layer.masksToBounds = true
                ok?.addTarget(self, action: #selector(SkillTreeVC.doneAction(_:)), forControlEvents: .TouchUpInside)
                cell?.contentView.addSubview(ok!)
                ok?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(40)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.right.equalTo(cell!.contentView).offset(-40)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                    make.height.equalTo(40)
                })
            }
            
            return cell!
        }
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        } else if section == 1 {
            return 40
        } else {
            return 10
        }
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // MARK: - TallysCellDelegate
    func selectedAction(info: Dictionary<SkillInfo, Bool>) {
        selectedSkills.append(info)
        table?.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: .None)
        for (index, skillInfo) in skills.enumerate() {
            for (skill, _) in skillInfo {
                if skill.skill_id_ == info.keys.first?.skill_id_ {
                    skills[index][skill] = true
                    return
                }
            }
        }

    }
    
    func deleteAction(index: Int, info: Dictionary<SkillInfo, Bool>) {
        selectedSkills.removeAtIndex(index)
        
        for (_index, skillInfo) in skills.enumerate() {
            for (skill, _) in skillInfo {
                if skill.skill_id_ == info.keys.first?.skill_id_ {
                    skills[_index][skill] = false
                    break
                }
            }
            
        }
        table?.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: .None)
        table?.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: .None)
    }
    
    // MARK: - DoneAction
    func doneAction(sender: UIButton) {
        delegate?.endEdit(selectedSkills)
        navigationController?.popViewControllerAnimated(true)
    }
}

