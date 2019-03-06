//
//  PodcastCell.swift
//  Podcast
//
//  Created by MacBook on 08/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import SDWebImage
class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet{
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            guard let url = URL(string : podcast.artworkUrl600 ?? "") else {return}
            podcastImageView.layer.borderWidth = 1
            podcastImageView.layer.masksToBounds = false
            podcastImageView.layer.cornerRadius = podcastImageView.frame.height/2
            podcastImageView.clipsToBounds = true
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
