//
//  RSSFeed.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import FeedKit

extension RSSFeed {
    
    func toEpisodes() -> [Episode]{
        
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]()
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            if episode.imageUrl == nil {
                
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        
    return episodes
    }
    func toPodcast() -> Podcast {
        var podcast : Podcast!
        podcast.artworkUrl600 = iTunes?.iTunesImage?.attributes?.href
        podcast.artistName = 
        
        
        return podcast
    }
}
