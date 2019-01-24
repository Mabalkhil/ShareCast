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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setDownloadEpisode(comment:CommentObj){
        
        episodeName.text = comment.userRealName
        
        episodeImage.image = UIImage(named: comment.userImage!)
        
    }
    
}
