//
//  playlistCellAddingCVC.swift
//  Podcast
//
//  Created by Mazen.A on 2/15/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class playlistCellAddingCVC: UICollectionViewCell {
    @IBOutlet weak var playlistName: UILabel!
    
    func setAttributes(playlist: Playlist){
        playlistName.text = playlist.playlistName
    }
    
}
