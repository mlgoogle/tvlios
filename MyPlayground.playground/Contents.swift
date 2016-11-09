//: Playground - noun: a place where people can play

import UIKit


class Head: NSObject {
    
    var len:Int16 = 0
    
    var zipEncryptType:Int8 = 0
    
    var type:Int8 = 0
    
    var signature:Int16 = 0
    
    var opcode:Int16 = 0
    
    var bodyLen:Int16 = 0
    
    var timestamp:UInt32 = 0
    
    var sessionID:Int64 = 0
    
    var reserved:Int32 = 0
    
}


var cnt:UInt32 = 0

var properList = class_copyPropertyList(Head.classForCoder(), &cnt)

var ivars = class_copyIvarList(Head.classForCoder(), &cnt)

for i in 0..<cnt {
    var ivar = ivars[Int(i)]
    var name = String.fromCString(ivar_getName(ivar))
    var type = String.fromCString(ivar_getTypeEncoding(ivar))
    
    print(name!, type)
    
}

for i in 0..<cnt {
    var item = properList[Int(i)]
    var name = String.fromCString(property_getName(item))
    var attr = String.fromCString(property_getAttributes(item))
    var value = property_copyAttributeValue(item, property_getAttributes(item))
    var cnt2:UInt32 = 0
    var prList = property_copyAttributeList(item, &cnt2)
//    print(name!, " : " , attr!)
    
    for j in 0..<cnt2 {
        var a = prList[Int(j)]
//        print(String.fromCString(a.name)!, String.fromCString(a.value)!)
    }

}









