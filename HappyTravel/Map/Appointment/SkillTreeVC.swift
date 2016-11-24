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
    
    func endEdit(_ skills: Array<Dictionary<SkillInfo, Bool>>)
    
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
        table = UITableView(frame: CGRect.zero, style: .grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 256
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .none
        table?.register(SkillsCell.self, forCellReuseIdentifier: "SkillsCell")
        view.addSubview(table!)
        table?.snp.makeConstraints({ (make) in
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SkillsCell", for: indexPath) as? SkillsCell
            cell?.delegate = self
            cell?.style = .delete
            cell?.setInfo(selectedSkills)
            return cell!
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SkillsCell", for: indexPath) as? SkillsCell
            cell?.delegate = self
            cell?.style = .select
            cell?.setInfo(skills)
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "OKCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "OKCell")
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
            
            var ok = cell?.contentView.viewWithTag(1001) as? UIButton
            if ok == nil {
                ok = UIButton()
                ok?.tag = 1001
                ok?.setTitle("确定", for: UIControlState())
                ok?.backgroundColor = UIColor.init(red: 30/255.0, green: 40/255.0, blue: 60/255.0, alpha: 1)
                ok?.setTitleColor(UIColor.white, for: UIControlState())
                ok?.layer.cornerRadius = 5
                ok?.layer.masksToBounds = true
                ok?.addTarget(self, action: #selector(SkillTreeVC.doneAction(_:)), for: .touchUpInside)
                cell?.contentView.addSubview(ok!)

                ok?.snp.makeConstraints({ (make) in
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        } else if section == 1 {
            return 40
        } else {
            return 10
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // MARK: - TallysCellDelegate
    func selectedAction(_ info: Dictionary<SkillInfo, Bool>) {
        selectedSkills.append(info)
        table?.reloadSections(IndexSet.init(integer: 0), with: .none)
        for (index, skillInfo) in skills.enumerated() {
            for (skill, _) in skillInfo {
                if skill.skill_id_ == info.keys.first?.skill_id_ {
                    skills[index][skill] = true
                    return
                }
            }
        }

    }
    
    func deleteAction(_ index: Int, info: Dictionary<SkillInfo, Bool>) {
        selectedSkills.remove(at: index)
        
        for (_index, skillInfo) in skills.enumerated() {
            for (skill, _) in skillInfo {
                if skill.skill_id_ == info.keys.first?.skill_id_ {
                    skills[_index][skill] = false
                    break
                }
            }
            
        }
        table?.reloadSections(IndexSet.init(integer: 0), with: .none)
        table?.reloadSections(IndexSet.init(integer: 1), with: .none)
    }
    
    // MARK: - DoneAction
    func doneAction(_ sender: UIButton) {
        delegate?.endEdit(selectedSkills)
        _ = navigationController?.popViewController(animated: true)
    }
}

