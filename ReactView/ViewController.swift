//
//  ViewController.swift
//  ReactView
//
//  Created by James Tang on 8/11/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var collectionPresenter : CollectionPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        let json : AnyObject? = JSONLoader(name: "products").json
        let products = (json as? NSDictionary)?["products"] as? [NSDictionary]

        let collectionPresenter = CollectionPresenter(collectionView: self.collectionView)

        if let products = products {

            let sections = products.map {
                dictionary -> ItemPresenter in

//                return ProductDictionaryPresenter(identifier: "cell", dictionary: dictionary)

                return ProductPresenter(identifier: "cell", product: Product(dictionary: dictionary))

            }.reduce([SectionPresenter]()) {

                var sections = $0
                var item = $1

                var targetSection = sections.last
                if targetSection == nil || targetSection?.title != item.section {
                    let title = item.section
                    targetSection = SectionPresenter(identifier: "categoryHeader", title: title)
                    sections.append(targetSection!)
                }

                targetSection?.items.append(item)
                return sections
            }

            collectionPresenter.sections = sections
        }

        self.collectionPresenter = collectionPresenter
        collectionPresenter.display()
    }

}

struct Product {
    var category : String?
    var name : String?
    var price : String?
    var stocked : Bool

    init(dictionary : NSDictionary) {
        self.category = dictionary["category"] as? String
        self.name = dictionary["name"] as? String
        self.price = dictionary["price"] as? String
        self.stocked = (dictionary["stocked"] as? NSNumber)?.boolValue ?? false
    }
}

class ProductDictionaryPresenter : ItemPresenter {

    private var dictionary : NSDictionary?

    @IBOutlet weak var nameLabel : UILabel?
    @IBOutlet weak var priceLabel : UILabel?

    init(identifier: String, dictionary: NSDictionary?) {
        super.init(identifier: identifier, section: dictionary?["category"] as? String)
        self.dictionary = dictionary
    }

    override func configureCollectionViewCell(cell: UICollectionViewCell) {
        self.nameLabel = cell.viewWithTag(1) as? UILabel
        self.priceLabel = cell.viewWithTag(2) as? UILabel
    }

    override func display() {
        self.nameLabel?.text = dictionary?["name"] as? String
        self.nameLabel?.textColor = (dictionary?["stocked"] as? NSNumber)?.boolValue ?? false ? UIColor.blackColor() : UIColor.redColor()
        self.priceLabel?.text = dictionary?["price"] as? String
    }
}


class ProductPresenter : ItemPresenter {

    var product : Product!

    @IBOutlet weak var nameLabel : UILabel?
    @IBOutlet weak var priceLabel : UILabel?

    init(identifier: String, product: Product) {
        super.init(identifier: identifier, section: product.category)
        self.product = product
    }

    override func configureCollectionViewCell(cell: UICollectionViewCell) {
        self.nameLabel = cell.viewWithTag(1) as? UILabel
        self.priceLabel = cell.viewWithTag(2) as? UILabel
    }

    override func display() {
        self.nameLabel?.text = product.name
        self.nameLabel?.textColor = product.stocked ? UIColor.blackColor() : UIColor.redColor()
        self.priceLabel?.text = product.price
    }
}

