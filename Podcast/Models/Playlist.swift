//
//  Playlist.swift
//  Podcast
//
//  Created by assem hakami on 24/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import Foundation


class Playlist: Codable{
    
    var playlistName: String?
    var episodes: [Episode]
    
    init(name:String, epis_list:[Episode]) {
        playlistName = name
        episodes = epis_list
    }
    
    func addTask(ep: Episode){
        episodes.append(ep)
        //UserDefaults.standard.deletePlaylistEpisode(episode: ep)
        
    }
    
}

