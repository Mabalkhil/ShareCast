//
//  BookmarkCell.swift
//  Podcast
//
//  Created by Mazen.A on 1/30/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class BookmarkCell: UITableViewCell {
    
    @IBOutlet weak var EpisodeImage: UIImageView!
    @IBOutlet weak var EpisodeName: UILabel!
    @IBOutlet weak var EpisodeDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAttributes(episode: Episode){
        self.EpisodeImage.layer.cornerRadius = 20
        self.EpisodeImage.clipsToBounds = true
        EpisodeName.text = episode.title
        EpisodeDescription.text = episode.describtion
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        EpisodeImage.sd_setImage(with: url)
    }

}
