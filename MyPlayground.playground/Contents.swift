//: Playground - noun: a place where people can play

import UIKit

var dict = ["c": "1",
            "a": "2",
            "b": "3"]

dict.keys.reverse()

var keys = dict.keys.reverse().sort({ (s1, s2) -> Bool in
    return s1.compare(s2).rawValue < 0 ? true : false
    
})

var contentString = ""
for key in keys {
    let value  = dict[key]
    if value != "" && value != "sign" && value != "key" {
        contentString.appendContentsOf("\(key)=\(value!)&")
    }
}

contentString


