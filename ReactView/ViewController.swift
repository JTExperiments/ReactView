//
//  ViewController.swift
//  ReactView
//
//  Created by James Tang on 8/11/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    private var collectionPresenter : CollectionPresenter?
    private var products : [NSDictionary]?
    private var showStockedOnly : Bool = false
    private var filterKeyword : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let json : AnyObject? = JSONLoader(name: "products").json
        self.products = (json as? NSDictionary)?["products"] as? [NSDictionary]

        self.collectionView.registerNib(UINib(nibName: "Cell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionPresenter = CollectionPresenter(collectionView: self.collectionView)
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.itemSize.width = self.view.frame.size.width
//        flowLayout?.estimatedItemSize = CGSize(width: self.view.frame.size.width, height: flowLayout!.itemSize.height)


        self.display()
    }

    func display() {


        if let products = self.products {

            let sections = products.map {
                Product(dictionary: $0)
                }.filter {
                    return self.showStockedOnly ? $0.stocked : true
                }.filter {

                    switch ($0.name, self.filterKeyword) {
                    case let (.Some(name), .Some(keyword)):

                        let name : NSString = name
                        let notFound = name.rangeOfString(keyword, options: .CaseInsensitiveSearch).location == NSNotFound
                        return !notFound

                    default:
                        return true
                    }
                }.map {
                    product -> ItemPresenter in
                    let presenter = ProductPresenter(identifier: "cell", product: product)
                    presenter.nib = UINib(nibName: "Cell", bundle: nil)
                    return presenter
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

            self.collectionPresenter?.sections = sections
        }
        
        self.collectionPresenter?.display()
    }

    @IBAction func switchValueDidChange(sender: UISwitch) {
        self.showStockedOnly = sender.on
        self.display()
    }

    // MARK: UISearchBarDelegate

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterKeyword = searchText.utf16Count > 0 ? searchText : nil
        self.display()
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

class ProductPresenter : ItemNibPresenter {

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

