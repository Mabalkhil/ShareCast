//
//  CategoryCell.swift
//  Podcast
//
//  Created by Khaled H on 29/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var podcastImage: UIImageView!
    
    
    var podcast: Podcast! {
        didSet{
            
            guard let url = URL(string : podcast.artworkUrl600 ?? "") else {return}
            podcastImage.layer.borderWidth = 1
            podcastImage.layer.masksToBounds = false
            podcastImage.layer.cornerRadius = podcastImage.frame.height/3
            podcastImage.clipsToBounds = true
            
            podcastImage.sd_setImage(with: url, completed: nil)
        }
    }
}
