//
//  AddressSelVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/9/9.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import XCGLogger

protocol AddressSelVCDelegate : NSObjectProtocol {
    
    func addressSelected(address: String?)
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "常住地址选择"
        
        let path = NSBundle.mainBundle().pathForResource("city", ofType: "plist")
        cities = NSMutableDictionary.init(contentsOfFile: path!)
        
        keys = cities?.allKeys.sort({ (obj1: AnyObject, obj2: AnyObject) -> Bool in
            let str1 = obj1 as? String
            let str2 = obj2 as? String
            return str1?.compare(str2!).rawValue < 0
        })
        cities?.setValue(["其它"], forKey: "其它")
        keys?.append("其它")
        
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationItem.rightBarButtonItem == nil {
            let sureBtn = UIButton.init(frame: CGRectMake(0, 0, 40, 30))
            sureBtn.setTitle("确定", forState: .Normal)
            sureBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            sureBtn.backgroundColor = UIColor.clearColor()
            sureBtn.addTarget(self, action: #selector(sureAction(_:)), forControlEvents: .TouchUpInside)
            
            let sureItem = UIBarButtonItem.init(customView: sureBtn)
            navigationItem.rightBarButtonItem = sureItem
            
        }
    }
    
    func sureAction(sender: UIButton) {
        if let titleLab = previousSelectedCell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel {
            delegate?.addressSelected(titleLab.text)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    func initView() {
        table = UITableView(frame: CGRectZero, style: .Plain)
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 60
        table?.rowHeight = UITableViewAutomaticDimension
        table?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        table?.separatorStyle = .None
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
        for i in 0..<keys!.count {
            let indexBtn = UIButton()
            indexBtn.tag = tags["indexBtn"]! + i
            indexBtn.backgroundColor = UIColor.clearColor()
            indexBtn.setTitle(i != keys!.count - 1 ? keys![i] as? String : "#", forState: .Normal)
            indexBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
            indexBtn.addTarget(self, action: #selector(AddressSelVC.indexAction(_:)), forControlEvents: .TouchUpInside)
            view.addSubview(indexBtn)
            indexBtn.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(view).offset(2)
                let space = (view.bounds.size.height - 14 * CGFloat(keys!.count) - 60 - 90) / CGFloat(keys!.count)
                make.top.equalTo(view).offset(45 + (space + 14) * CGFloat(i))
                make.height.equalTo(14)
            })
        }
        
    }
    
    func indexAction(sender: UIButton) {
        let index = sender.tag - tags["indexBtn"]!
        XCGLogger.debug("\(self.keys![index] as? String)")
        table?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: index), atScrollPosition: .Middle, animated: true)
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (cities?.valueForKey((keys![section]) as! String)?.count)!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys!.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys![section] as? String
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddressCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .None
            cell?.backgroundColor = UIColor.whiteColor()
            cell?.contentView.backgroundColor = UIColor.whiteColor()
            cell?.selectionStyle = .None
        }
        
        var titleLab = cell?.contentView.viewWithTag(tags["titleLab"]!) as? UILabel
        if titleLab == nil {
            titleLab = UILabel()
            titleLab?.tag = tags["titleLab"]!
            titleLab?.backgroundColor = UIColor.whiteColor()
            titleLab?.textColor = UIColor.blackColor()
            titleLab?.font = UIFont.systemFontOfSize(S15)
            cell?.contentView.addSubview(titleLab!)
            titleLab?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(cell!.contentView).offset(20)
                make.centerY.equalTo(cell!.contentView)
                make.right.equalTo(-25)
            })
        }
        let key = (keys![indexPath.section]) as! String
        titleLab?.text = (cities?.valueForKey(key) as? NSArray)![indexPath.row] as? String
        
        var selectedIcon = cell?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIButton
        if selectedIcon == nil {
            selectedIcon = UIButton()
            selectedIcon?.tag = tags["selectedIcon"]!
            selectedIcon?.backgroundColor = UIColor.clearColor()
            selectedIcon?.setBackgroundImage(UIImage.init(named: "pay-unselect"), forState: .Normal)
            selectedIcon?.setBackgroundImage(UIImage.init(named: "pay-selected"), forState: .Selected)
            cell?.contentView.addSubview(selectedIcon!)
            selectedIcon?.snp_makeConstraints(closure: { (make) in
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
            separateLine?.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(titleLab!)
                make.right.equalTo(titleLab!)
                make.bottom.equalTo(cell!.contentView).offset(0.5)
                make.height.equalTo(1)
            })
        }
        separateLine?.hidden = (indexPath.row == (cities?.valueForKey((keys![indexPath.section]) as! String)!.count)!  - 1) ? true : false
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedIcon = previousSelectedCell?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIButton {
            selectedIcon.selected = false
        }
        if let selectedIcon = tableView.cellForRowAtIndexPath(indexPath)?.contentView.viewWithTag(tags["selectedIcon"]!) as? UIButton {
            selectedIcon.selected = true
            previousSelectedCell = tableView.cellForRowAtIndexPath(indexPath)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

