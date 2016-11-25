//
//  AddressSelVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/9.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol AddressSelVCDelegate : NSObjectProtocol {
    
    func addressSelected(_ address: String?)
}

class AddressSelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate:AddressSelVCDelegate?
    
    var table:UITableView?
    var previousSelectedCell:UITableViewCell?
    
    var address:String?
    
    var keys:[AnyObject]?
    var cities:NSMutableDictionary?
    
    let tags = ["titleLab": 1001,
                "indexBtn": 100200,
                "description": 1003,
                "separateLine": 1004,
                "headBG": 1005,
                "headView": 1006,
                "selectedIcon": 1007]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "常住地址选择"
        
        let path = Bundle.main.path(forResource: "city", ofType: "plist")
        cities = NSMutableDictionary.init(contentsOfFile: path!)
        
        keys = cities?.allKeys.sorted(by: { (obj1: AnyObject, obj2: AnyObject) -> Bool in
            let str1 = obj1 as? String
            let str2 = obj2 as? String
            return str1?.compare(str2!).rawValue < 0
        } as! (Any, Any) -> Bool) as [AnyObject]?
        cities?.setValue(["其它"], forKey: "其它")
        keys?.append("其它" as AnyObject)
        
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationItem.rightBarButtonItem == nil {
            let sureBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
            sureBtn.setTitle("确定", for: UIControlState())
            sureBtn.setTitleColor(UIColor.white, for: UIControlState())
            sureBtn.backgroundColor = UIColor.clear
            sureBtn.addTarget(self, action: #selector(AddressSelVC.sureAction(_:)), for: .touchUpInside)
            
            let sureItem = UIBarButtonItem.init(customView: sureBtn)
            navigationItem.rightBarButtonItem = sureItem
            
        }
    }
    
    func sureAction(_ sender: UIButton) {
        if let titleLab = previousSelectedCell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel {
            delegate?.addressSelected(titleLab.text)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func initView() {
        table = UITableView(frame: CGRect.zero, style: .plain)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table?.separatorStyle = .none
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        view.addSubview(table!)
        table?.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
        for i in 0..<keys!.count {
            let indexBtn = UIButton()
            indexBtn.tag = tags["indexBtn"]! + i
            indexBtn.backgroundColor = UIColor.clear
            indexBtn.setTitle(i != keys!.count - 1 ? keys![i] as? String : "#", for: UIControlState())
            indexBtn.setTitleColor(UIColor.gray, for: UIControlState())
            indexBtn.addTarget(self, action: #selector(AddressSelVC.indexAction(_:)), for: .touchUpInside)
            view.addSubview(indexBtn)
            indexBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(view).offset(2)
                let space = (view.bounds.size.height - 14 * CGFloat(keys!.count) - 60 - 90) / CGFloat(keys!.count)
                make.top.equalTo(view).offset(45 + (space + 14) * CGFloat(i))
                make.height.equalTo(14)
            })
        }
        
    }
    
    func indexAction(_ sender: UIButton) {
        let index = sender.tag - tags["indexBtn"]!
        XCGLogger.debug("\(self.keys![index] as? String)")
        table?.scrollToRow(at: IndexPath.init(row: 0, section: index), at: .middle, animated: true)
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((cities?.value(forKey: (keys![section]) as! String) as AnyObject).count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return keys!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys![section] as? String
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .none
            cell?.backgroundColor = UIColor.white
            cell?.contentView.backgroundColor = UIColor.white
            cell?.selectionStyle = .none
        }
        
        var titleLab = cell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel
        if titleLab == nil {
            titleLab = UILabel()
            titleLab?.tag = tags["titleLab"]!
            titleLab?.backgroundColor = UIColor.white
            titleLab?.textColor = UIColor.black
            titleLab?.font = UIFont.systemFont(ofSize: S15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp.makeConstraints({ (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.centerY.equalTo(cell!.contentView)
                make.right.equalTo(-25)
            })
        }
        let key = (keys![indexPath.section]) as! String
        titleLab?.text = (cities?.value(forKey: key) as? NSArray)![indexPath.row] as? String
        
        var selectedIcon = cell?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIButton
        if selectedIcon == nil {
            selectedIcon = UIButton()
            selectedIcon?.tag = tags["selectedIcon"]!
            selectedIcon?.backgroundColor = UIColor.clear
            selectedIcon?.setBackgroundImage(UIImage.init(named: "pay-unselect"), for: UIControlState())
            selectedIcon?.setBackgroundImage(UIImage.init(named: "pay-selected"), for: .selected)
            cell?.contentView.addSubview(selectedIcon!)
            selectedIcon?.snp.makeConstraints({ (make) in
                make.right.equalTo(titleLab!)
                make.centerY.equalTo(titleLab!)
                make.width.equalTo(20)
                make.height.equalTo(20)
            })
        }
        
        var separateLine = cell?.contentView.viewWithTag(tags["separateLine"]!)
        if separateLine == nil {
            separateLine = UIView()
            separateLine?.tag = tags["separateLine"]!
            separateLine?.backgroundColor = UIColor.init(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
            cell?.contentView.addSubview(separateLine!)
            separateLine?.snp.makeConstraints({ (make) in
                make.left.equalTo(titleLab!)
                make.right.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView).offset(0.5)
                make.height.equalTo(1)
            })
        }
        separateLine?.isHidden = (indexPath.row == ((cities?.value(forKey: (keys![indexPath.section]) as! String)! as AnyObject).count)!  - 1) ? true : false
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIcon = previousSelectedCell?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIButton {
            selectedIcon.isSelected = false
        }
        if let selectedIcon = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIButton {
            selectedIcon.isSelected = true
            previousSelectedCell = tableView.cellForRow(at: indexPath)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

