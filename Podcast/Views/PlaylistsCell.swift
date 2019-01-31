//
//  PlaylistsCell.swift
//  Podcast
//
//  Created by assem hakami on 24/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//


import UIKit


class PlaylistsCell: UITableViewCell{
    
    @IBOutlet weak var playsitName: UILabel!
    
    @IBOutlet weak var numberOfEpisode: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    var playlist: Playlist!{
        
        didSet{
            
            playsitName.text = playlist.playlistName
            numberOfEpisode.text = playlist.numberOfEpisodes
            
        }
    }
    
    
    
}
