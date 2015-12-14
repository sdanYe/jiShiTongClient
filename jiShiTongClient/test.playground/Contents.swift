//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
print(str)

str = "linsuiyuan@icloud.com"

var regularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
var predicate = NSPredicate(format: "SELF MATCHES %@", regularExpression)

if predicate.evaluateWithObject(str) {
    print("right")
} else {
    print("wrong")
}

str = "ytwerewerwerwq4_."
regularExpression = "[A-Za-z0-9_.]{6,20}+"
predicate = NSPredicate(format: "SELF MATCHES %@", regularExpression)

if predicate.evaluateWithObject(str) {
    print("right")
} else {
    print("wrong")
}





