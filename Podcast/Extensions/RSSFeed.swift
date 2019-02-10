//
//  RSSFeed.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//
import FeedKit

extension RSSFeed {
    
    
    func toChannle () -> Podcast {
        var podcast = Podcast(trackName: title, artistName: iTunes?.iTunesAuthor, artworkUrl600: iTunes?.iTunesImage?.attributes?.href, trackCount: items?.count ?? 0, feedUrl: iTunes?.iTunesNewFeedURL)

        return podcast
    }
    
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
    
    
}
