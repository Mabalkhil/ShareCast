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
        var podcast = Podcast()
        podcast.artistName = iTunes?.iTunesAuthor
        podcast.artworkUrl600 = iTunes?.iTunesImage?.attributes?.href
        podcast.feedUrl = iTunes?.iTunesNewFeedURL
        podcast.trackCount = items?.count
        podcast.trackName = title
        
        return podcast
    }
    
    func toEpisodes(url: URL) -> [Episode]{
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]()
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            if episode.imageUrl == nil {
                
                episode.imageUrl = imageUrl
            }
            episode.channelURL = url.absoluteString ?? ""
            episodes.append(episode)
        })
        
        return episodes
    }
    
    
}
