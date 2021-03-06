//
//  DiscoverTableCell.swift
//  Podcast
//
//  Created by Khaled H on 31/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class DiscoverTableCell: UITableViewCell {
    
    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet private weak var categoryCollection: UICollectionView!
    
    var categoryCollectionOffset: CGFloat {
        get {
            return categoryCollection.contentOffset.x
        }
        
        set {
            categoryCollection.contentOffset.x = newValue
        }
    }


    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        categoryCollection.delegate = dataSourceDelegate
        categoryCollection.dataSource = dataSourceDelegate
        categoryCollection.tag = row
        categoryCollection.reloadData()
    }
    
    
    
    
    

}
