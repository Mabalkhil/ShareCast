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
    @IBOutlet weak var durationLabel: UILabel!
    
    var episode: Episode!{
        
        didSet{
            
            titleLabel.text = episode.title
            descriptionLabel.text = episode.describtion
            
            let seconds = episode.time
            var rem_seconds = 0.0
            var minutes = 0.0
            var hours = 0.0
            //print(millis!)
            if (seconds != nil){
                rem_seconds = (seconds!).truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60)
                minutes = (seconds!/(60)).truncatingRemainder(dividingBy: 60)
                hours = (seconds!/(60*60)).truncatingRemainder(dividingBy: 24)
            }
            durationLabel.text = String(format:"%02d:%02d:%02d",Int(hours), Int(minutes), Int(rem_seconds))

            
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
