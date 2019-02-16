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
    @IBOutlet weak var outterView: UIView!
    @IBOutlet weak var downloadProgress: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDownloadEpisode(episode:Episode){
        self.episodeImage.layer.cornerRadius = 20
        self.episodeImage.clipsToBounds = true
        episodeName.text = episode.title
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        episodeImage.sd_setImage(with: url)
    }
}
