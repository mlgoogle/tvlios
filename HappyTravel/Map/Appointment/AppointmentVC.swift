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
    var curIndexPath:IndexPath?
    var selectedBtn:UIButton?
    
    var cityInfo:CityInfo?
    var startDate:Date?
    var endDate:Date?
    var gender = false
    var name:String?
    var tel:String?

    var skills:Array<Dictionary<SkillInfo, Bool>> = []
    lazy var dateFormatter:DateFormatter = {
        var dateFromatter = DateFormatter()
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotify()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(AppointmentVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppointmentVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppointmentVC.appointmentReply(_:)), name: NSNotification.Name(rawValue: NotifyDefine.AppointmentReply), object: nil)
    }
    
    func appointmentReply(_ notification: Notification) {
        let alert = UIAlertController.init(title: "成功", message: "预约已成功，请保持开机！祝您生活愉快！谢谢！", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
            self.perform(#selector(AppointmentVC.backAction), with: nil, afterDelay: 0.3)
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func keyboardWillShow(_ notification: Notification?) {
        let frame = (notification!.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let inset = UIEdgeInsetsMake(0, 0, (frame?.size.height)!, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets =  inset
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .grouped)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table?.separatorStyle = .none
        view.addSubview(table!)
        
        let commitBtn = UIButton()
        commitBtn.setTitle("立即预约", for: UIControlState())
        commitBtn.backgroundColor = UIColor.init(red: 30/255.0, green: 40/255.0, blue: 60/255.0, alpha: 1)
        commitBtn.setTitleColor(UIColor.white, for: UIControlState())
        commitBtn.setBackgroundImage(UIImage.init(named: "bottom-selector-bg"), for: UIControlState())
        commitBtn.layer.cornerRadius = 5
        commitBtn.layer.masksToBounds = true
        commitBtn.addTarget(self, action: #selector(AppointmentVC.appointment), for: .touchUpInside)
        view.addSubview(commitBtn)
        commitBtn.snp_makeConstraints({ (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(65)
        })
        
        table?.snp_makeConstraints({ (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(commitBtn.snp_top)
        })
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return agent ? 4 : 1
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 40
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            let view = UIView()
            view.backgroundColor = .clear
            let label = UILabel()
            label.backgroundColor = .clear
            label.text = section == 0 ? "预约信息" : "服务者技能"
            label.font = .systemFont(ofSize: AtapteWidthValue(S15))
            label.textColor = UIColor.gray
            view.addSubview(label)
            label.snp_makeConstraints({ (make) in
                make.left.equalTo(view).offset(20)
                make.top.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            })
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            tallys.style = .addNew
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
                separatorLine?.snp_makeConstraints({ (make) in
                    make.left.equalTo(cell!.contentView).offset(15)
                    make.right.equalTo(cell!.contentView)
                    make.bottom.equalTo(cell!.contentView).offset(-0.5)
                    make.height.equalTo(1)
                })
            }
        }
        
        return cell == nil ? UITableViewCell() : cell!
    }
    
    func citySelectorCell(_ tableView: UITableView) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCitysCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "AppointmentCitysCell")
            cell?.selectionStyle = .none
        }
        
        var citySelectorLab = cell?.contentView.viewWithTag(tags["citySelectorLab"]!) as? UILabel
        if citySelectorLab == nil {
            citySelectorLab = UILabel()
            citySelectorLab?.tag = tags["citySelectorLab"]!
            citySelectorLab?.text = "目标城市"
            citySelectorLab?.textColor = UIColor.black
            citySelectorLab?.font = UIFont.systemFont(ofSize: AtapteWidthValue(S15))
            cell?.contentView.addSubview(citySelectorLab!)
            citySelectorLab?.snp_makeConstraints({ (make) in
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
            cityLab?.font = UIFont.systemFont(ofSize: S15)
            cityLab?.textColor = UIColor.gray
            cell?.contentView.addSubview(cityLab!)
            cityLab?.snp_makeConstraints({ (make) in
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
            citySelector?.backgroundColor = UIColor.clear
            citySelector?.image = UIImage.init(named: "city-selector")
            cityLab?.addSubview(citySelector!)
            citySelector?.snp_makeConstraints({ (make) in
                make.right.equalTo(cityLab!)
                make.top.equalTo(cityLab!)
                make.bottom.equalTo(cityLab!)
                make.width.equalTo(27)
            })
        }
        
        return cell!
    }
    
    func dateSelectorCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentDateCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "AppointmentDateCell")
            cell?.selectionStyle = .none
        }
        
        var dateTitleLab = cell?.contentView.viewWithTag(tags["dateTitleLab"]!) as? UILabel
        if dateTitleLab == nil {
            dateTitleLab = UILabel()
            dateTitleLab?.tag = tags["dateTitleLab"]!
            dateTitleLab?.text = "目标城市"
            dateTitleLab?.textColor = UIColor.black
            dateTitleLab?.font = UIFont.systemFont(ofSize: S15)
            cell?.contentView.addSubview(dateTitleLab!)
            dateTitleLab?.snp_makeConstraints({ (make) in
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
            dateLab?.backgroundColor = UIColor.clear
            dateLab?.font = UIFont.systemFont(ofSize: S15)
            dateLab?.textColor = UIColor.black
            cell?.contentView.addSubview(dateLab!)
            dateLab?.snp_makeConstraints({ (make) in
                make.left.equalTo(dateTitleLab!.snp_right).offset(10)
                make.top.equalTo(cell!.contentView).offset(10)
                make.bottom.equalTo(cell!.contentView).offset(-10)
                make.right.equalTo(cell!.contentView).offset(-40)
            })
            let normalDate = Date.init(timeIntervalSinceNow: 3600 * 24)
            startDate = normalDate
            endDate = normalDate
            dateLab?.text = dateFormatter.string(from: normalDate)
        }
        
        return cell!
    }
    
    func agentCell(_ tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "AgentCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "AgentCell")
                cell?.selectionStyle = .none
            }
            
            var agentSelectorLab = cell?.contentView.viewWithTag(tags["agentSelectorLab"]!) as? UILabel
            if agentSelectorLab == nil {
                agentSelectorLab = UILabel()
                agentSelectorLab?.tag = tags["agentSelectorLab"]!
                agentSelectorLab?.backgroundColor = UIColor.clear
                agentSelectorLab?.font = UIFont.systemFont(ofSize: S15)
                agentSelectorLab?.text = "代订"
                cell?.contentView.addSubview(agentSelectorLab!)
                agentSelectorLab?.snp_makeConstraints({ (make) in
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
                agentSelector?.addTarget(self, action: #selector(AppointmentVC.agentSwitch(_:)), for: .valueChanged)
                cell?.contentView.addSubview(agentSelector!)
                agentSelector?.snp_makeConstraints({ (make) in
                    make.right.equalTo(cell!.contentView).offset(-15)
                    make.top.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(cell!.contentView).offset(-15)
                })
            }
            agentSelector?.isOn = agent
            
        } else if indexPath.row == 1 || indexPath.row == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "NameTelCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "NameTelCell")
                cell?.selectionStyle = .none
            }
            
            var lab = cell?.contentView.viewWithTag(tags["nameTelLab"]!) as? UILabel
            if lab == nil {
                lab = UILabel()
                lab?.tag = tags["nameTelLab"]!
                lab?.backgroundColor = UIColor.clear
                lab?.font = UIFont.systemFont(ofSize: S15)
                cell?.contentView.addSubview(lab!)
                lab?.snp_makeConstraints({ (make) in
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
                textField?.textColor = UIColor.black
                textField?.rightViewMode = .whileEditing
                textField?.clearButtonMode = .whileEditing
                textField?.backgroundColor = UIColor.clear
                textField?.textAlignment = .left
                cell?.contentView.addSubview(textField!)
                textField?.snp_makeConstraints({ (make) in
                    make.left.equalTo(lab!.snp_right).offset(10)
                    make.top.equalTo(lab!).offset(-5)
                    make.right.equalTo(cell!.contentView).offset(15)
                    make.bottom.equalTo(lab!).offset(5)
                })
            }
            textField?.attributedPlaceholder = NSAttributedString.init(string: indexPath.row == 1 ? "预约对象姓名" : "联系电话", attributes: [NSForegroundColorAttributeName: UIColor.gray])
            
        } else if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "GenderCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "GenderCell")
                cell?.selectionStyle = .none
            }
            
            var lab = cell?.contentView.viewWithTag(tags["genderLab"]!) as? UILabel
            if lab == nil {
                lab = UILabel()
                lab?.tag = tags["genderLab"]!
                lab?.backgroundColor = UIColor.clear
                lab?.font = UIFont.systemFont(ofSize: S15)
                lab?.text = "性别"
                cell?.contentView.addSubview(lab!)
                lab?.snp_makeConstraints({ (make) in
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
                    btn?.setImage(UIImage.init(named: "service-unselect"), for: UIControlState())
                    btn?.setImage(UIImage.init(named: "service-selected"), for: .selected)
                    btn?.setTitle(i == 0 ? "  男" : "  女", for: UIControlState())
                    btn?.setTitleColor(UIColor.black, for: UIControlState())
                    btn?.addTarget(self, action: #selector(AppointmentVC.genderSelectAction(_:)), for: .touchUpInside)
                    cell?.contentView.addSubview(btn!)
                    btn?.snp_makeConstraints({ (make) in
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
                    btn?.isSelected = i == 0 ? gender : !gender
                }

            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curIndexPath = indexPath
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if citysAlertController == nil {
                    citysAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
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
                present(citysAlertController!, animated: true, completion: nil)
            } else if indexPath.row == 1 || indexPath.row == 2 {
                if dateAlertController == nil {
                    dateAlertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
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
                
                present(dateAlertController!, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - UITextField
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.placeholder == "预约对象姓名" {
            name = textField.text
        } else {
            tel = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location > 15 {
            return false
        }
        
        return true
    }
    
    // MARK: - ServiceSheetDelegate
    func cancelAction(_ sender: UIButton?) {
        citysAlertController?.dismiss(animated: true, completion: nil)
    }
    
    func sureAction(_ sender: UIButton?, targetCity: CityInfo?) {
        citysAlertController?.dismiss(animated: true, completion: nil)
        if let cell = table?.cellForRow(at: curIndexPath!) {
            if let cityLab = cell.contentView.viewWithTag(tags["cityLab"]!) as? UILabel {
                cityLab.text = "  \((targetCity?.cityName)!)"
                cityInfo = targetCity
            }
        }
    }
    
    // MARK: - DateSelectorDelagate    
    func cancelAction() {
        dateAlertController?.dismiss(animated: true, completion: nil)
    }

    func sureAction(_ tag: Int, date: Date) {
        dateAlertController?.dismiss(animated: true, completion: nil)
        if let cell = table?.cellForRow(at: curIndexPath!) {
            if let dateLab = cell.contentView.viewWithTag(tags["dateLab"]!) as? UILabel {
                if let dateTitleLab = cell.contentView.viewWithTag(tags["dateTitleLab"]!) as? UILabel {
                    let dateForMatter = DateFormatter()
                    dateForMatter.dateFormat = "yyyy-MM-dd"
                    dateLab.text = dateForMatter.string(from: date)
                    if dateTitleLab.text == "开始日期" {
                        startDate = date
                    } else {
                        endDate = date
                    }
                }
            }
            
        }
    }
    
    func agentSwitch(_ agentSwitch: UISwitch) {
        agent = agentSwitch.isOn
        table?.reloadSections(IndexSet.init(integer: 2), with: .fade)
    }
    
    func genderSelectAction(_ sender: UIButton) {
        sender.isSelected = true
        gender = sender.tag % 10 == 0 ? true : false
        if selectedBtn != nil && selectedBtn != sender {
            selectedBtn?.isSelected = !selectedBtn!.isSelected
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
            let alert = UIAlertController.init(title: "资料不完善", message: errMsg, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "确定", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        var skillStr = ""
        for skillInfo in skills {
            for (skill, _) in skillInfo {
                skillStr += ("\(skill.skill_id_)")
                skillStr += ","
            }
            
        }
        let dict:[String: AnyObject] = ["uid_": DataManager.currentUser!.uid as AnyObject,
                                        "city_code_": cityInfo!.cityCode as AnyObject,
                                        "start_time_": startDate!.timeIntervalSince1970 as AnyObject,
                                        "end_time_": endDate!.timeIntervalSince1970 as AnyObject,
                                        "skills_": skillStr as AnyObject,
                                        "is_other_": agent == false ? 0 : 1 as AnyObject,
                                        "other_name_": agent == true ? name! : "",
                                        "other_gender_": agent == true ? (gender == true ? 1 : 0) : "",
                                        "other_phone_": agent == true ? tel! : ""]
        SocketManager.sendData(.appointmentRequest, data: dict as AnyObject?)
    
    }

    // MARK: - SkillTreeVCDelegate
    func endEdit(_ skills: Array<Dictionary<SkillInfo, Bool>>) {
        self.skills = skills
        table?.reloadSections(IndexSet.init(integer: 1), with: .fade)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
