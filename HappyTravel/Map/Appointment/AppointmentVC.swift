//
//  AppointmentVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/10/17.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import RealmSwift
import XCGLogger


class AppointmentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DateSelectorSheetDelegate , CitysSelectorSheetDelegate, SkillsCellDelegate, SkillTreeVCDelegate {
    
    var table:UITableView?
    var agent = false
    var serviceCitys:Dictionary<Int, CityInfo> = [:]
    var citysAlertController:UIAlertController?
    var dateAlertController:UIAlertController?
    var curIndexPath:NSIndexPath?
    var selectedBtn:UIButton?
    
    var cityInfo:CityInfo?
    var startDate:NSDate?
    var endDate:NSDate?
    var gender = false
    var name:String?
    var tel:String?

    var skills:Array<Dictionary<SkillInfo, Bool>> = []
    lazy var dateFormatter:NSDateFormatter = {
        var dateFromatter = NSDateFormatter()
        dateFromatter.dateFormat = "yyyy-MM-dd"
        return dateFromatter
    }()
    let tags = ["citySelectorLab": 1001,
                "separatorLine": 1002,
                "cityLab": 1003,
                "citySelector": 1004,
                "dateTitleLab": 1005,
                "dateLab": 1006,
                "agentSelectorLab": 1007,
                "nameTelLab": 1008,
                "genderLab": 1009,
                "agentSelector": 1011,
                "nameTelTextField": 1012,
                "genderBtn": 1013]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "预约"
        
        initView()
        
        hideKeyboard()
    }
    
    func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(AppointmentVC.touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotify()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppointmentVC.appointmentReply(_:)), name: NotifyDefine.AppointmentReply, object: nil)
    }
    
    func appointmentReply(notification: NSNotification) {
        let alert = UIAlertController.init(title: "成功", message: "预约已成功，请保持开机！祝您生活愉快！谢谢！", preferredStyle: .Alert)
        let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action) in
            self.performSelector(#selector(AppointmentVC.backAction), withObject: nil, afterDelay: 0.3)
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        table?.separatorStyle = .None
        view.addSubview(table!)
        
        let commitBtn = UIButton()
        commitBtn.setTitle("立即预约", forState: .Normal)
        commitBtn.backgroundColor = UIColor.init(red: 30/255.0, green: 40/255.0, blue: 60/255.0, alpha: 1)
        commitBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), forState: .Normal)
        commitBtn.layer.cornerRadius = 5
        commitBtn.layer.masksToBounds = true
        commitBtn.addTarget(self, action: #selector(AppointmentVC.appointment), forControlEvents: .TouchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(65)
        })
        
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(commitBtn.snp_top)
        })
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return agent ? 4 : 1
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 40
        } else {
            return 10
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            let view = UIView()
            view.backgroundColor = .clearColor()
            let label = UILabel()
            label.backgroundColor = .clearColor()
            label.text = section == 0 ? "预约信息" : "服务者技能"
            label.font = .systemFontOfSize(15)
            label.textColor = UIColor.grayColor()
            view.addSubview(label)
            label.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(view).offset(20)
                make.top.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            })
            return view
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        var line = false
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = citySelectorCell(tableView)
            } else {
                cell = dateSelectorCell(tableView, indexPath: indexPath)
            }
            line = indexPath.row < 2 ? true : false
        } else if indexPath.section == 1 {
            let tallys = SkillsCell()
            tallys.delegate = self
            tallys.style = .AddNew
            let skillInfo = SkillInfo()
            skillInfo.skill_name_ = "+"
            skillInfo.labelWidth = 10.0
            skills.append([skillInfo : false])
            tallys.setInfo(skills)
            return tallys
        } else if indexPath.section == 2 {
            cell = agentCell(tableView, indexPath: indexPath)
            line = indexPath.row < 3 ? true : false
        }
        
        if line {
            var separatorLine = cell?.contentView.viewWithTag(tags["separatorLine"]!)
            if separatorLine == nil {
                separatorLine = UIView()
                separatorLine?.backgroundColor = UIColor.init(red: 221/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1)
                cell?.contentView.addSubview(separatorLine!)
                separatorLine?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(15)
                    make.right.equalTo(cell!.contentView)
                    make.bottom.equalTo(cell!.contentView).offset(-0.5)
                    make.height.equalTo(1)
                })
            }
        }
        
        return cell == nil ? UITableViewCell() : cell!
    }
    
    func citySelectorCell(tableView: UITableView) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AppointmentCitysCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "AppointmentCitysCell")
            cell?.selectionStyle = .None
        }
        
        var citySelectorLab = cell?.contentView.viewWithTag(tags["citySelectorLab"]!) as? UILabel
        if citySelectorLab == nil {
            citySelectorLab = UILabel()
            citySelectorLab?.tag = tags["citySelectorLab"]!
            citySelectorLab?.text = "目标城市"
            citySelectorLab?.textColor = UIColor.blackColor()
            citySelectorLab?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(citySelectorLab!)
            citySelectorLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(15)
                make.top.equalTo(cell!.contentView).offset(15)
                make.bottom.equalTo(cell!.contentView).offset(-15)
                make.width.equalTo(60)
            })
        }
        
        var cityLab = cell?.contentView.viewWithTag(tags["cityLab"]!) as? UILabel
        if cityLab == nil {
            cityLab = UILabel()
            cityLab?.tag = tags["cityLab"]!
            cityLab?.backgroundColor = UIColor.init(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
            cityLab?.layer.cornerRadius = 5
            cityLab?.layer.masksToBounds = true
            cityLab?.font = UIFont.systemFontOfSize(15)
            cityLab?.textColor = UIColor.grayColor()
            cell?.contentView.addSubview(cityLab!)
            cityLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(citySelectorLab!.snp_right).offset(10)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
                make.right.equalTo(cell!.contentView).offset(-40)
            })
            cityLab?.text = cityInfo == nil ? "  请选择" : (cityInfo!.cityName)!
        }
        
        var citySelector = cell?.contentView.viewWithTag(tags["citySelector"]!) as? UIImageView
        if citySelector == nil {
            citySelector = UIImageView()
            citySelector?.tag = tags["citySelector"]!
            citySelector?.backgroundColor = UIColor.clearColor()
            citySelector?.image = UIImage.init(named: "city-selector")
            cityLab?.addSubview(citySelector!)
            citySelector?.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(cityLab!)
                make.top.equalTo(cityLab!)
                make.bottom.equalTo(cityLab!)
                make.width.equalTo(27)
            })
        }
        
        return cell!
    }
    
    func dateSelectorCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AppointmentDateCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "AppointmentDateCell")
            cell?.selectionStyle = .None
        }
        
        var dateTitleLab = cell?.contentView.viewWithTag(tags["dateTitleLab"]!) as? UILabel
        if dateTitleLab == nil {
            dateTitleLab = UILabel()
            dateTitleLab?.tag = tags["dateTitleLab"]!
            dateTitleLab?.text = "目标城市"
            dateTitleLab?.textColor = UIColor.blackColor()
            dateTitleLab?.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(dateTitleLab!)
            dateTitleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(15)
                make.top.equalTo(cell!.contentView).offset(15)
                make.bottom.equalTo(cell!.contentView).offset(-15)
                make.width.equalTo(60)
            })
        }
        dateTitleLab?.text = indexPath.row == 1 ? "开始日期" : "结束日期"
        
        var dateLab = cell?.contentView.viewWithTag(tags["dateLab"]!) as? UILabel
        if dateLab == nil {
            dateLab = UILabel()
            dateLab?.tag = tags["dateLab"]!
            dateLab?.backgroundColor = UIColor.clearColor()
            dateLab?.font = UIFont.systemFontOfSize(15)
            dateLab?.textColor = UIColor.blackColor()
            cell?.contentView.addSubview(dateLab!)
            dateLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(dateTitleLab!.snp_right).offset(10)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
                make.right.equalTo(cell!.contentView).offset(-40)
            })
            let normalDate = NSDate.init(timeIntervalSinceNow: 3600 * 24)
            startDate = normalDate
            endDate = normalDate
            dateLab?.text = dateFormatter.stringFromDate(normalDate)
        }
        
        return cell!
    }
    
    func agentCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("AgentCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .Default, reuseIdentifier: "AgentCell")
                cell?.selectionStyle = .None
            }
            
            var agentSelectorLab = cell?.contentView.viewWithTag(tags["agentSelectorLab"]!) as? UILabel
            if agentSelectorLab == nil {
                agentSelectorLab = UILabel()
                agentSelectorLab?.tag = tags["agentSelectorLab"]!
                agentSelectorLab?.backgroundColor = UIColor.clearColor()
                agentSelectorLab?.font = UIFont.systemFontOfSize(15)
                agentSelectorLab?.text = "代订"
                cell?.contentView.addSubview(agentSelectorLab!)
                agentSelectorLab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(15)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                    make.width.equalTo(60)
                })
            }
            
            var agentSelector = cell?.contentView.viewWithTag(tags["agentSelector"]!) as? UISwitch
            if agentSelector == nil {
                agentSelector = UISwitch()
                agentSelector?.tag = tags["agentSelector"]!
                agentSelector?.onTintColor = UIColor.init(decR: 183, decG: 39, decB: 43, a: 1)
                agentSelector?.addTarget(self, action: #selector(AppointmentVC.agentSwitch(_:)), forControlEvents: .ValueChanged)
                cell?.contentView.addSubview(agentSelector!)
                agentSelector?.snp_makeConstraints(closure: { (make) in
                    make.right.equalTo(cell!.contentView).offset(-15)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                })
            }
            agentSelector?.on = agent
            
        } else if indexPath.row == 1 || indexPath.row == 3 {
            cell = tableView.dequeueReusableCellWithIdentifier("NameTelCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .Default, reuseIdentifier: "NameTelCell")
                cell?.selectionStyle = .None
            }
            
            var lab = cell?.contentView.viewWithTag(tags["nameTelLab"]!) as? UILabel
            if lab == nil {
                lab = UILabel()
                lab?.tag = tags["nameTelLab"]!
                lab?.backgroundColor = UIColor.clearColor()
                lab?.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(lab!)
                lab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(15)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                    make.width.equalTo(60)
                })
            }
            lab?.text = indexPath.row == 1 ? "姓名" : "联系电话"
            
            var textField = cell?.contentView.viewWithTag(tags["nameTelTextField"]!) as? UITextField
            if textField == nil {
                textField = UITextField()
                textField?.tag = tags["nameTelTextField"]!
                textField?.delegate = self
                textField?.textColor = UIColor.blackColor()
                textField?.rightViewMode = .WhileEditing
                textField?.clearButtonMode = .WhileEditing
                textField?.backgroundColor = UIColor.clearColor()
                textField?.textAlignment = .Left
                cell?.contentView.addSubview(textField!)
                textField?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(lab!.snp_right).offset(10)
                    make.top.equalTo(lab!).offset(-5)
                    make.right.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(lab!).offset(5)
                })
            }
            textField?.attributedPlaceholder = NSAttributedString.init(string: indexPath.row == 1 ? "预约对象姓名" : "联系电话", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
            
        } else if indexPath.row == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("GenderCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .Default, reuseIdentifier: "GenderCell")
                cell?.selectionStyle = .None
            }
            
            var lab = cell?.contentView.viewWithTag(tags["genderLab"]!) as? UILabel
            if lab == nil {
                lab = UILabel()
                lab?.tag = tags["genderLab"]!
                lab?.backgroundColor = UIColor.clearColor()
                lab?.font = UIFont.systemFontOfSize(15)
                lab?.text = "性别"
                cell?.contentView.addSubview(lab!)
                lab?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(cell!.contentView).offset(15)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                    make.width.equalTo(60)
                })
            }
            
            for i in 0..<2 {
                var btn = cell?.contentView.viewWithTag(tags["genderBtn"]! * 10 + i) as? UIButton
                if btn == nil {
                    btn = UIButton()
                    btn?.tag = tags["genderBtn"]! * 10 + i
                    btn?.setImage(UIImage.init(named: "service-unselect"), forState: .Normal)
                    btn?.setImage(UIImage.init(named: "service-selected"), forState: .Selected)
                    btn?.setTitle(i == 0 ? "  男" : "  女", forState: .Normal)
                    btn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    btn?.addTarget(self, action: #selector(AppointmentVC.genderSelectAction(_:)), forControlEvents: .TouchUpInside)
                    cell?.contentView.addSubview(btn!)
                    btn?.snp_makeConstraints(closure: { (make) in
                        make.top.equalTo(lab!).offset(-5)
                        make.bottom.equalTo(lab!).offset(5)
                        make.width.equalTo(60)
                        if i == 0 {
                            make.left.equalTo(lab!.snp_right).offset(10)
                        } else {
                            make.right.equalTo(cell!.contentView).offset(-45)
                        }
                        
                    })
                }
                if selectedBtn != nil {
                    btn?.selected = i == 0 ? gender : !gender
                }

            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        curIndexPath = indexPath
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if citysAlertController == nil {
                    citysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
                    let sheet = CitysSelectorSheet()
                    let citys = NSDictionary.init(dictionary: serviceCitys)
                    sheet.citysList = citys.allValues as? Array<CityInfo>
                    sheet.delegate = self
                    citysAlertController!.view.addSubview(sheet)
                    sheet.snp_makeConstraints { (make) in
                        make.left.equalTo(citysAlertController!.view).offset(-10)
                        make.right.equalTo(citysAlertController!.view).offset(10)
                        make.bottom.equalTo(citysAlertController!.view).offset(10)
                        make.top.equalTo(citysAlertController!.view).offset(-10)
                    }
                }
                presentViewController(citysAlertController!, animated: true, completion: nil)
            } else if indexPath.row == 1 || indexPath.row == 2 {
                if dateAlertController == nil {
                    dateAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
                    let sheet = DateSelectorSheet()
                    sheet.delegate = self
                    dateAlertController!.view.addSubview(sheet)
                    sheet.snp_makeConstraints { (make) in
                        make.left.equalTo(dateAlertController!.view).offset(-10)
                        make.right.equalTo(dateAlertController!.view).offset(10)
                        make.bottom.equalTo(dateAlertController!.view).offset(10)
                        make.top.equalTo(dateAlertController!.view).offset(-10)
                    }
                    
                }
                
                presentViewController(dateAlertController!, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - UITextField
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.placeholder == "预约对象姓名" {
            name = textField.text
        } else {
            tel = textField.text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 15 {
            return false
        }
        
        return true
    }
    
    // MARK: - ServiceSheetDelegate
    func cancelAction(sender: UIButton?) {
        citysAlertController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sureAction(sender: UIButton?, targetCity: CityInfo?) {
        citysAlertController?.dismissViewControllerAnimated(true, completion: nil)
        if let cell = table?.cellForRowAtIndexPath(curIndexPath!) {
            if let cityLab = cell.contentView.viewWithTag(tags["cityLab"]!) as? UILabel {
                cityLab.text = "  \((targetCity?.cityName)!)"
                cityInfo = targetCity
            }
        }
    }
    
    // MARK: - DateSelectorDelagate    
    func cancelAction() {
        dateAlertController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func sureAction(tag: Int, date: NSDate) {
        dateAlertController?.dismissViewControllerAnimated(true, completion: nil)
        if let cell = table?.cellForRowAtIndexPath(curIndexPath!) {
            if let dateLab = cell.contentView.viewWithTag(tags["dateLab"]!) as? UILabel {
                if let dateTitleLab = cell.contentView.viewWithTag(tags["dateTitleLab"]!) as? UILabel {
                    let dateForMatter = NSDateFormatter()
                    dateForMatter.dateFormat = "yyyy-MM-dd"
                    dateLab.text = dateForMatter.stringFromDate(date)
                    if dateTitleLab.text == "开始日期" {
                        startDate = date
                    } else {
                        endDate = date
                    }
                }
            }
            
        }
    }
    
    func agentSwitch(agentSwitch: UISwitch) {
        agent = agentSwitch.on
        table?.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: .Fade)
    }
    
    func genderSelectAction(sender: UIButton) {
        sender.selected = true
        gender = sender.tag % 10 == 0 ? true : false
        if selectedBtn != nil && selectedBtn != sender {
            selectedBtn?.selected = !selectedBtn!.selected
        }
        selectedBtn = sender
    }
    
    // MARK: - TallysCellDelegate
    func addNewAction() {
        let skillTree = SkillTreeVC()
        skillTree.delegate = self
        skillTree.selectedSkills = skills
        navigationController?.pushViewController(skillTree, animated: true)
    }
    
    // MARK: - Appointment
    func appointment() {
        var alright = true
        var errMsg = ""
        if startDate == nil {
            alright = false
            errMsg = "请选择起始时间"
        } else if endDate == nil {
            alright = false
            errMsg = "请选择结束时间"
        } else if cityInfo == nil {
            alright = false
            errMsg = "请选择目标城市"
        } else if skills.count == 0 {
            alright = false
            errMsg = "请选择服务者技能"
        } else if agent == true {
            if name == nil {
                alright = false
                errMsg = "请输入联系人名字"
            } else if tel == nil {
                alright = false
                errMsg = "请输入联系人电话"
            }
        }
        
        if alright == false {
            let alert = UIAlertController.init(title: "资料不完善", message: errMsg, preferredStyle: .Alert)
            let action = UIAlertAction.init(title: "确定", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        var skillStr = ""
        for skillInfo in skills {
            for (skill, _) in skillInfo {
                skillStr += ("\(skill.skill_id_)")
                skillStr += ","
            }
            
        }
        let dict:[String: AnyObject] = ["uid_": DataManager.currentUser!.uid,
                                        "city_code_": cityInfo!.cityCode!,
                                        "start_time_": startDate!.timeIntervalSince1970,
                                        "end_time_": endDate!.timeIntervalSince1970,
                                        "skills_": skillStr,
                                        "is_other_": agent == false ? 0 : 1,
                                        "other_name_": agent == true ? name! : "",
                                        "other_gender_": agent == true ? (gender == true ? 1 : 0) : "",
                                        "other_phone_": agent == true ? tel! : ""]
        SocketManager.sendData(.AppointmentRequest, data: dict)
    
    }

    // MARK: - SkillTreeVCDelegate
    func endEdit(skills: Array<Dictionary<SkillInfo, Bool>>) {
        self.skills = skills
        table?.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: .Fade)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
