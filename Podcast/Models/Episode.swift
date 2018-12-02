//
//  Episode.swift
//  Podcast
//
//  Created by MacBook on 09/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let describtion: String
    var imageUrl: String?
    let author: String
    let streamURL: String
    let timeStampLables: [String]
    let timeStamps: [String]
    //let timeMark: List
    
    init(feedItem: RSSFeedItem){
        self.streamURL = feedItem.enclosure?.attributes?.url ?? ""
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.describtion = feedItem.iTunes?.iTunesSubtitle ?? ""
            feedItem.description ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
       // print("This is the feed")
       // let item = "I made this wonderful pic last #chRistmas... #instagram #nofilter #snow #fun" //feedItem.description
        let feedDescription = feedItem.description as! String
        self.timeStampLables = feedDescription.timeStampsLabled()
        self.timeStamps = feedDescription.timeStamps()
        print(timeStamps )
        print(timeStampLables )
        print("-------------------")
       // print(test, separator: ".\n")
        
        
    }
}
