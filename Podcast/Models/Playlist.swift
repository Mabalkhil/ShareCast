//
//  Playlist.swift
//  Podcast
//
//  Created by assem hakami on 24/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import Foundation

struct Playlist: Codable{
    var playlistName: String?
    var numberOfEpisodes: String?
    var episodes: [Episode]?

}

