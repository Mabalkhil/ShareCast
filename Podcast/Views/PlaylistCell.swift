//
//  PlaylistCell.swift
//  Podcast
//
//  Created by assem hakami on 25/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell{

    
    @IBOutlet weak var episodeImage: UIImageView!
    
    @IBOutlet weak var episodeNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    var episode: Episode!{
        
        didSet{
          
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImage.sd_setImage(with: url)
            episodeNameLabel.text = episode.title
            
        }
    }
    
    
    
}
