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
    @IBOutlet weak var numberOfepisodeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    var playlists: Playlist!{
        
        didSet{
            
            playsitName.text = playlists.playlistName
        }
    }
    
    
    
}
