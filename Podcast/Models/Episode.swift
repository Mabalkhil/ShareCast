//
//  Episode.swift
//  Podcast
//
//  Created by MacBook on 09/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Codable {
    let title: String
    let pubDate: Date
    let describtion: String
    var imageUrl: String?
    let author: String
    let streamURL: String
    var timeStampLables: [String]?
    var timeStamps: [String]?
    var fileUrl: String?
    var time:Double?
    //let timeMark: List
    // timestampPosition is where the user stoped listenting
    var timestampPosition : Int
    
    var dictionary : [String:Any]{
        return [
            "title": title,
            "pubDate": pubDate,
            "describtion": describtion,
            "imageUrl": imageUrl ?? "",
            "author": author,
            "streamURL": streamURL,
            "timeStampLables": timeStampLables ?? "",
            "timeStamps": timeStamps ?? "",
            "fileUrl": fileUrl ?? "",
            "time": time ?? "",
            "timestampPosition": timestampPosition

        ]
        
    }
    
    
    
    
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
        self.time = feedItem.iTunes?.iTunesDuration
       // print(test, separator: ".\n")
        
    }
    init(){
        self.title = ""
        self.pubDate = Date()
        self.describtion = ""
        self.author =  ""
        self.imageUrl = ""
        //let feedDescription =  ""
        self.timeStampLables = ["",""]
        self.timeStamps = ["",""]
        self.streamURL = ""
        self.fileUrl = ""
        self.timestampPosition = 0
    }
    init?(dictionary : [String:Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.pubDate = dictionary["pubDate"] as? Date ?? Date()
        self.describtion = dictionary["describtion"] as? String ?? ""
        self.author = dictionary["author"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        //let feedDescription =  ""
        self.timeStampLables = dictionary["timeStampLables"] as? [String] ?? ["",""]
        self.timeStamps = dictionary["timeStamps"] as? [String] ?? ["",""]
        self.streamURL = dictionary["streamURL"] as? String ?? ""
        self.fileUrl = dictionary["fileUrl"] as? String ?? ""
        self.timestampPosition = dictionary["timestampPosition"] as? Int ?? 0
        
        
    }
   
    
    
    
}
