//
//  Episode.swift
//  Podcast
//
//  Created by MacBook on 09/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Codable{
    let title: String
    let pubDate: Date
    let describtion: String
    var imageUrl: String?
    let author: String
    let streamURL: String
    var timeStampLables: [String]?
    let timeStamps: [String]?
    var fileUrl: String?
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
        let feedDescription = (feedItem.description as! String?) ?? ""
        self.timeStampLables = feedDescription.timeStampsLabled()
        self.timeStamps = feedDescription.timeStamps()
        self.fileUrl = ""
       // print(test, separator: ".\n")
        
    }
    init(){
        self.title = ""
        self.pubDate = Date()
        self.describtion = ""
        self.author =  ""
        self.imageUrl = ""
        // print("This is the feed")
        // let item = "I made this wonderful pic last #chRistmas... #instagram #nofilter #snow #fun" //feedItem.description
        let feedDescription =  ""
        self.timeStampLables = ["",""]
        self.timeStamps = ["",""]
        self.streamURL = ""
        self.fileUrl = ""
    }
   
    
    
    
}
