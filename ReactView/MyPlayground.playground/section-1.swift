// Playground - noun: a place where people can play

import UIKit
import React


var before : NSArray = ["1", "2", "3", "4"]
var after : NSArray = ["1", "5", "4", "2", "7"]


var final = NSMutableArray(array: before)
let changeset = ChangeSet(before: before, after: after)
changeset.apply(final)
changeset.description()
changeset.remainingAfter
