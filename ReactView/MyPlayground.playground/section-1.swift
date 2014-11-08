// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var strings = ["1", "2", "3", "4", "5", "6"]

var numbers = strings.map { (string : String) -> Int in
    return string.toInt()!
}

var seq = [[Int]]()
var a = numbers.reduce(seq) {
    seq, num -> [[Int]] in

    var array = seq
//    if num % 2 == 0 {
        array[num % 2].append(num)
//    }
    return array
}

a
