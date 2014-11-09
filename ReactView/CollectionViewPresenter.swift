//
//  CollectionViewPresenter.swift
//  ReactView
//
//  Created by James Tang on 8/11/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit
import React

class CollectionPresenter : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var collectionView : UICollectionView!
    var oldSections : [SectionPresenter]?
    var sections : [SectionPresenter]?
        {
        willSet {
            oldSections = sections
        }
        didSet {
            let oldValue = oldSections

            switch (oldValue, sections) {
            case let (.Some(before), .Some(after)):


                collectionView.performBatchUpdates({

                    for (i, section) in enumerate(after) {


                        let beforeTitle = (before[i].items as NSArray).valueForKeyPath("product.name") as NSArray
                        let afterTitle = (section.items as NSArray).valueForKeyPath("product.name") as NSArray

                        let changeset = ChangeSet(before: beforeTitle, after: afterTitle)
                        println("CollectionViewPresenter \(changeset)")
                        changeset.apply(self.collectionView, section: i)
                    }
                    
                    }, completion: { (completed) -> Void in
                })


            default: break
            }

        }
    }

    convenience init(collectionView: UICollectionView) {
        self.init()
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func display() {
        if oldSections == nil {
            collectionView.reloadData()
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.sections?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections?[section].items.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if let item = self.sections?[section].items[row] {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(item.identifier, forIndexPath: indexPath) as UICollectionViewCell
            item.configureCollectionViewCell(cell)
            item.display()
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let section = self.sections?[indexPath.section] as SectionPresenter!
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: section.identifier!, forIndexPath: indexPath) as UICollectionReusableView
        section.configureReusableView(view)
        section.display()
        return view
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let section = indexPath.section
        let row = indexPath.row
        if let item = self.sections?[section].items[row] {
            return item.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        }
        return collectionViewLayout.itemSize
    }

}

class SectionPresenter {

    var items = [ItemPresenter]()
    private (set) var identifier : String!
    var title : String?

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

class ItemPresenter : NSObject {

    private (set) var identifier : String!
    private (set) var section : String?

    init(identifier: String, section: String?) {
        self.identifier = identifier
        self.section    = section
    }

    // Override by subclass
    func configureCollectionViewCell(cell: UICollectionViewCell) {}
    func display() {}
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewLayout.itemSize
    }
}

class ItemNibPresenter : ItemPresenter {

    var nib : UINib?
    var sizeHandler : ((estimatedSize:CGSize) -> CGSize)?
    private var prototypeCell : UICollectionViewCell?

    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let originalSize = super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)

        if prototypeCell == nil {
            prototypeCell = nib?.instantiateWithOwner(nil, options: nil).first as? UICollectionViewCell
        }

        if let cell = prototypeCell {
            self.configureCollectionViewCell(cell)
            self.display()
            var size = cell.systemLayoutSizeFittingSize(CGSize(width: originalSize.width, height: UILayoutFittingExpandedSize.height))
//            size.width = originalSize.width
            return size
        }

        return originalSize
    }
}
