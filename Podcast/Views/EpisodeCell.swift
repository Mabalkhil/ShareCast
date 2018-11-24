//
//  EpisodeCell.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    
    var episode: Episode!{
        
        didSet{
            
            titleLabel.text = episode.title
            describtionLabel.text = episode.describtion
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImageView.sd_setImage(with: url)
            
        }
    }
    

    @IBOutlet weak var episodeImageView: UIImageView!
    
    
    @IBOutlet weak var pubDateLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.numberOfLines = 2
        }
    }
    
    
    @IBOutlet weak var describtionLabel: UILabel!{
        
        didSet{
            describtionLabel.numberOfLines = 2
        }
    }
    
    
    
}
