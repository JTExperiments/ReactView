// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var before : NSArray = ["1", "2", "3", "4", "5", "6"]

var after : NSArray = ["4", "7", "2", "8", "1", "6"]


class ChangeSet {

    private (set) var before : NSArray
    private (set) var after : NSArray
    private var deletedIndexSet : NSMutableIndexSet?
    private var insertIndexSet : NSMutableIndexSet?
    private var movingIndexSet : NSMutableIndexSet?
    private var remainingAfter : NSMutableArray?

    init(before:NSArray, after:NSArray) {
        self.before = before
        self.after = after
        self.prepare()
    }

    func prepare() {
        var deletedIndexSet = NSMutableIndexSet()
        var insertIndexSet = NSMutableIndexSet()
        var remainingAfter = NSMutableArray(array: after)
        var lastDeleted : NSInteger = -1
        for (i, item) in enumerate(before) {
            let index = after.indexOfObject(item)
            if (index == NSNotFound) {
                lastDeleted = index
                deletedIndexSet.addIndex(i)
            } else if (index < lastDeleted) {
                deletedIndexSet.addIndex(i)
            } else {
                remainingAfter.removeObject(item)
            }
        }

        for (i, item) in enumerate(remainingAfter) {
            let index = after.indexOfObject(item)
            if index != NSNotFound {
                insertIndexSet.addIndex(index)
            }
        }

        self.deletedIndexSet = deletedIndexSet
        self.insertIndexSet = insertIndexSet
        self.remainingAfter = remainingAfter
    }

    func apply(array: NSMutableArray) -> NSArray {
        if let deletedIndexSet = self.deletedIndexSet {
            array.removeObjectsAtIndexes(deletedIndexSet)
        }

        switch (self.remainingAfter, self.insertIndexSet) {
        case let (.Some(remaining), .Some(indexSet)):
            array.insertObjects(remaining, atIndexes: indexSet)
        default:
            break
        }

        return array.copy() as NSArray
    }
}

var final = NSMutableArray(array: before)
let changeset = ChangeSet(before: before, after: after)
changeset.apply(final)







