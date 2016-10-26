//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


let dict = ["error": -1015]

if dict["error"] != nil {
    print("1015")
}

if dict["abc"] != nil {
    print("asd")
} else {
    print("as5")
}

print(dict["asd"])


enum Test : Int {
    case T1 = 2
}

if Test.T1 == Test(rawValue: 2) {
    print("asd")
}
