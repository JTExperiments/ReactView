//
//  ChangeSet.swift
//  ReactView
//
//  Created by James Tang on 9/11/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit

public class ChangeSet : NSObject {

    private (set) var before : NSArray
    private (set) var after : NSArray
    private var deletedIndexSet : NSMutableIndexSet?
    private var insertIndexSet : NSMutableIndexSet?
    private var remainingAfter : NSMutableArray?

    public init(before:NSArray, after:NSArray) {
        self.before = before
        self.after = after
        super.init()
        self.prepare()
    }

    func prepare() {
        var deletedIndexSet = NSMutableIndexSet()
        var insertIndexSet = NSMutableIndexSet()
        var remainingAfter = NSMutableArray(array: after)
        var lastDeleted : Int = 0
        for (i, item) in enumerate(before) {
            let index : Int = after.indexOfObject(item, inRange: NSMakeRange(lastDeleted, after.count - lastDeleted))
            if (index == NSNotFound) {
                deletedIndexSet.addIndex(i)
            } else {
                lastDeleted = index
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

    public func apply(array: NSMutableArray) -> NSArray {
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

    public func apply(collectionView: UICollectionView, section:NSInteger) {

        if let indexSet = self.deletedIndexSet {

            var indexPaths = [NSIndexPath]()

            indexSet.enumerateIndexesUsingBlock { index, stop in
                indexPaths.append(NSIndexPath(forItem: index, inSection: section))
            }

            if indexPaths.count > 0 {
                collectionView.deleteItemsAtIndexPaths(indexPaths)
            }
        }

        if let indexSet = self.insertIndexSet {
            var indexPaths = [NSIndexPath]()
            indexSet.enumerateIndexesUsingBlock { index, stop in
                indexPaths.append(NSIndexPath(forItem: index, inSection: section))
            }
            if indexPaths.count > 0 {
                collectionView.insertItemsAtIndexPaths(indexPaths)
            }
        }

    }

    public func description() -> NSString {
        var removing = [AnyObject]()
        var removingIndex = [Int]()
        var inserting = [AnyObject]()
        var insertingIndex = [Int]()

        self.deletedIndexSet!.enumerateIndexesUsingBlock { (index, stop) -> Void in
            removing.append(self.before[index])
            removingIndex.append(index)
        }

        self.insertIndexSet!.enumerateIndexesUsingBlock { (index, stop) -> Void in
            inserting.append(self.after[index])
            insertingIndex.append(index)
        }

        return "ChangeSet: {\n\tRemoving\(removingIndex):\(removing)\n\tInserting\(insertingIndex):\(inserting)\n}"
    }

}
