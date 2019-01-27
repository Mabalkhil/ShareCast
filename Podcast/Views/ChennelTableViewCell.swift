//
//  ChennelTableViewCell.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/17/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class ChennelTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel! {
        didSet{
            durationLabel.text = "00:00:00"
        }
    }
    
    var episode: Episode!{
        
        didSet{
            
            titleLabel.text = episode.title
            descriptionLabel.text = episode.describtion
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd MMM, yyyy"
//            durationLabel.text = dateFormatter.string(from: episode.pubDate)
            
            
//           let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
//            episodeImageView.sd_setImage(with: url)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
