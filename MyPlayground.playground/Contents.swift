//: Playground - noun: a place where people can play

import UIKit

func timeStr(minus: Int) -> String {
    let hour = minus / 60
    let leftMinus = minus % 60
    let c = String(format: "%02d:%02d", hour, leftMinus)
    let hourStr = hour > 9 ? "\(hour)":"0\(hour)"
    let minusStr = leftMinus > 9 ? "\(leftMinus)":"0\(leftMinus)"
    return "\(hourStr):\(minusStr)"
}

let a = timeStr(60*9+23)

print(a)

