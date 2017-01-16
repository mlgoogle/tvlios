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
    static var requestCount = 0
    static var compeleteCount = 0
    
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
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let sysContacts = ABAddressBookCopyArrayOfAllPeople(adressBook).takeRetainedValue() as Array
            
            let uploadContactArray = List<ContactModel>()
            
            
            
            for contact in sysContacts {
                let name = getNameWithRecord(contact)
                //获取某个联系人所有的手机号集合
                let phones = ABRecordCopyValue(contact, kABPersonPhoneProperty).takeRetainedValue();
                for index in 0..<ABMultiValueGetCount(phones) {
                    let phoneString = getPhoneNumberWithIndex(index, phones: phones)
                    let contact = ContactModel()
                    contact.name = name
                    contact.phone_num = phoneString
                    uploadContactArray.append(contact)
                    if uploadContactArray.count > 200 {
                        uploadContact(uploadContactArray)
                        uploadContactArray.removeAll()
                    }
                }
                if uploadContactArray.count != 0 {
                    uploadContact(uploadContactArray)
                }
                
            }
            
        }
        
    }
    
    
    static func getPhoneNumberWithIndex(index:Int, phones:ABMultiValue!)-> String {
        var  phoneString = ABMultiValueCopyValueAtIndex(phones, index).takeRetainedValue() as! String
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
        if timeDistance > 2592000 {
            getPersonAuth()
            return true
        }
        return false
    }
    
    static func insertUploadTimeRecord() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentTime = NSDate().timeIntervalSince1970
        userDefaults.setDouble(currentTime, forKey: TimeRecordKey)
    }

    
    static func uploadContact(array:List<ContactModel>) {
        let uploadContactModel = UploadContactModel()
        requestCount += 1
        uploadContactModel.uid = CurrentUser.uid_
        uploadContactModel.contacts_list = array
        APIHelper.userAPI().uploadContact(uploadContactModel, complete: { (response) in
            compeleteCount += 1
            if compeleteCount == requestCount {
                insertUploadTimeRecord()
            }
            }) { (error) in
                
        }
    }
}

