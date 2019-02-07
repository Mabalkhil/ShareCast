//
//  DownloadEpisodeCell.swift
//  Podcast
//
//  Created by assem hakami on 18/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class DownloadEpisodeCell: UITableViewCell {
    
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var episodeSize: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var episode: Episode!{
        didSet{
            episodeName.text = episode.title
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImage.sd_setImage(with: url)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDownloadEpisode(episode:Episode){
        episodeName.text = episode.title
        episodeImage.image = UIImage(named: episode.imageUrl!)
    }
}
