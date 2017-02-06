//
//  YD_ContactManager.swift
//  TestAdress
//
//  Created by J-bb on 16/12/28.
//  Copyright © 2016年 J-bb. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import RealmSwift
class YD_ContactManager: NSObject {
    static let TimeRecordKey = "uploadTime"
    static let uid = "uid"
    static let contacts_list = "contacts_list"
    static let username = "name"
    static let phone_num = "phone_num"
    static var requestCount = 0//记录请求个数
    static var compeleteCount = 0//记录请求完成次数
    
    static func getPersonAuth() {
        let adressRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        if ABAddressBookGetAuthorizationStatus() == .NotDetermined { //还未请求通讯录权限
            ABAddressBookRequestAccessWithCompletion(adressRef, { (granted, error) in
                getContact(adressRef)
            })
        } else if ABAddressBookGetAuthorizationStatus() == .Denied || ABAddressBookGetAuthorizationStatus() == .Restricted { //拒绝访问通讯录
            
        } else if ABAddressBookGetAuthorizationStatus() == .Authorized { //允许访问通讯录
            getContact(adressRef)
        }
        
        
    }
    
    static func getContact(adressBook:ABAddressBookRef) {
        
        
        /// 创建GCD信号量 初始值设置为1
        let semaphore = dispatch_semaphore_create(1)
        let queue = dispatch_get_global_queue(0, 0)
        
        dispatch_async(queue) {
            
            let sysContacts = ABAddressBookCopyArrayOfAllPeople(adressBook).takeRetainedValue() as Array
            
            let uploadContactArray = List<ContactModel>()
            
            
            
            let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^1[3|4|5|7|8][0-9]\\d{8}$")


            for contact in sysContacts {
                let name = getNameWithRecord(contact)
                //获取某个联系人所有的手机号集合
                let phones = ABRecordCopyValue(contact, kABPersonPhoneProperty).takeRetainedValue();
                
                /**
                 *  有可能通讯录数量过多，所以这里分包上传 当数量超过200 上传一次
                 *
                 *  @param phones
                 *
                 *  @return
                 */
                
                    for index in 0..<ABMultiValueGetCount(phones) {
                        let phoneString = getPhoneNumberWithIndex(index, phones: phones)
                        if predicate.evaluateWithObject(phoneString) == false {
                            continue
                        }
                        let contact = ContactModel()
                        contact.name = name
                        contact.phone_num = phoneString
                        uploadContactArray.append(contact)
                        if uploadContactArray.count > 200 {
                            uploadContact(uploadContactArray,semaphore: semaphore)
                            uploadContactArray.removeAll()
                            /**
                             *  信号量值-1 卡死这个线程
                             */
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                        }
                    }
                }
            
            
            
            if uploadContactArray.count != 0 {
                uploadContact(uploadContactArray, semaphore: semaphore)
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
            
        }
        
    }
    
    
    static func getPhoneNumberWithIndex(index:Int, phones:ABMultiValue!)-> String {
        
        var  phoneString = ABMultiValueCopyValueAtIndex(phones, index).takeRetainedValue() as! String
    
        
        //过滤其他无用字符
        let setToRemove = NSCharacterSet(charactersInString: "0123456789").invertedSet
        
        let array = phoneString.componentsSeparatedByCharactersInSet(setToRemove)
        
        phoneString = array.joinWithSeparator("")
        
        if phoneString.hasPrefix("86") {
            let index = phoneString.startIndex.advancedBy(2)
            phoneString = phoneString.substringFromIndex(index)
        }
        return phoneString
    }
    
    static func getNameWithRecord(record: ABRecord!) -> String {
        let listName = getValueString(record, kABPersonLastNameProperty)
        let firstName = getValueString(record, kABPersonFirstNameProperty)
        var name = ""
        if listName != nil {
            name = listName!
        }
        if firstName != nil {
            name = name + firstName!
        }
        return name
    }
    
    static func getValueString(record: ABRecord!, _ property: ABPropertyID) -> String? {
        return  ABRecordCopyValue(record, property)?.takeRetainedValue() as? String
    }
    

    static func checkIfUploadContact() -> Bool{
        
        if ABAddressBookGetAuthorizationStatus() == .Denied || ABAddressBookGetAuthorizationStatus() == .Restricted {
            return false
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let timeString = userDefaults.valueForKey(TimeRecordKey) as? Double
        var timeCount = 0.0
        if timeString != nil {
            timeCount = timeString!
        }
        let currentTimeInterval = NSDate().timeIntervalSince1970
        let timeDistance = currentTimeInterval - timeCount
        //60 * 60 * 24 * 30 = 2592000 一个月上传一次
        getPersonAuth()
        if timeDistance > 2592000 {
            return true
        }
        return false
    }
    
    static func insertUploadTimeRecord() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentTime = NSDate().timeIntervalSince1970
        userDefaults.setDouble(currentTime, forKey: TimeRecordKey)
    }

    
    static func uploadContact(array:List<ContactModel>, semaphore:dispatch_semaphore_t) {
        let uploadContactModel = UploadContactModel()
        requestCount += 1
        uploadContactModel.uid = CurrentUser.uid_
        uploadContactModel.contacts_list = array
        APIHelper.userAPI().uploadContact(uploadContactModel, complete: { (response) in
            //上传完成后 信号量 +1 继续执行
            dispatch_semaphore_signal(semaphore)
            compeleteCount += 1
            if compeleteCount == requestCount {
                insertUploadTimeRecord()
            }
            }) { (error) in
                
        }
    }
}

