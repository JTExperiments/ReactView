//
//  CollectionViewPresenter.swift
//  ReactView
//
//  Created by James Tang on 8/11/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit

class CollectionPresenter : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    private var collectionView : UICollectionView!
    var _sections : [SectionPresenter]?
    var sections : [SectionPresenter]?

    convenience init(collectionView: UICollectionView) {
        self.init()
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func display() {
        if let oldSections = self._sections {
            if let newSections = self.sections {
                
                // Don't support animating section changes yet
                if newSections.count == oldSections.count {

                    self.collectionView.performBatchUpdates({
                        () -> Void in

                        for (i, section) in enumerate(newSections) {
                            
                            // Build maps of all items
                            var newItemMap = [String: ItemPresenter]()
                            var oldItemMap = [String: ItemPresenter]()
                            
                            for (j, newItem) in enumerate(newSections[i].items) {
                                newItem.indexPath = NSIndexPath(forItem: j, inSection: i)
                                oldItemMap[newItem.key] = newItem
                            }
                            for (j, oldItem) in enumerate(oldSections[i].items) {
                                oldItem.indexPath = NSIndexPath(forItem: j, inSection: i)
                                oldItemMap[oldItem.key] = oldItem
                            }
                            

                            // Animate changes
                            
                            for oldItem in oldSections[i].items {
                                // Find corresponding new item
                                let newItem = newItemMap[oldItem.key]
                                if newItem == nil {
                                    self.collectionView.deleteItemsAtIndexPaths([oldItem.indexPath])
                                }
                            }
                            
                            for newItem in newSections[i].items {
                                
                                // Find corresponding old item
                                if let oldItem = oldItemMap[newItem.key] {
                                    
                                    // Animate movement
                                    if oldItem.indexPath != newItem.indexPath {
                                        self.collectionView.moveItemAtIndexPath(oldItem.indexPath, toIndexPath: newItem.indexPath)
                                    }
                                }
                                else {
                                    
                                    // Must be new insertion
                                    self.collectionView.insertItemsAtIndexPaths([newItem.indexPath])
                                }
                            }
                        }
                        
                        self._sections = self.sections
                        
                    // end of batchUpdates
                    }, completion: nil)
                    
                    
                    return
                }
            }
        }
        self._sections = self.sections
        collectionView.reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self._sections?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._sections?[section].items.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if let item = self._sections?[section].items[row] {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(item.identifier, forIndexPath: indexPath) as UICollectionViewCell
            item.configureCollectionViewCell(cell)
            item.display()
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let section = self._sections?[indexPath.section] as SectionPresenter!
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: section.identifier!, forIndexPath: indexPath) as UICollectionReusableView
        section.configureReusableView(view)
        section.display()
        return view
    }

}

class SectionPresenter {

    var items = [ItemPresenter]()
    private (set) var identifier : String!
    var title : String?
    var key: String {
        return self.title ?? ""
    }

    @IBOutlet weak var titleLabel : UILabel?

    init(identifier: String, title: String?) {
        self.identifier = identifier
        self.title = title
    }

    func configureReusableView(view:UICollectionReusableView) {
        self.titleLabel = view.viewWithTag(1) as UILabel?
    }

    func display() {
        self.titleLabel?.text = title
    }
}

class ItemPresenter {

    private (set) var identifier : String!
    private (set) var section : String?
    var indexPath : NSIndexPath!
    var key: String

    init(identifier: String, section: String?, key: String) {
        self.identifier = identifier
        self.section    = section
        self.key        = key
    }

    // Override by subclass
    func configureCollectionViewCell(cell: UICollectionViewCell) {}
    func display() {}
}

