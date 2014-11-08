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
    var sections : [SectionPresenter]?

    convenience init(collectionView: UICollectionView) {
        self.init()
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func display() {
        collectionView.reloadData()
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

class ItemPresenter {

    private (set) var identifier : String!
    private (set) var section : String?

    init(identifier: String, section: String?) {
        self.identifier = identifier
        self.section    = section
    }

    // Override by subclass
    func configureCollectionViewCell(cell: UICollectionViewCell) {}
    func display() {}
}

