//
//  Podcast.swift
//  Podcast
//
//  Created by MacBook on 03/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation


struct Podcast: Decodable{
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    
    var dictionary : [String : Any] {
        return [
            "trackName" : trackName ?? "",
            "artistName" : artistName ?? "",
            "artworkUrl600" : artworkUrl600 ?? "",
            "trackCount" : trackCount ?? "",
            "feedUrl" : feedUrl ?? ""
        ]
    }
    
    
    init?(dictionary : [String:Any]) {
        self.trackName = dictionary["trackName"] as? String ?? ""
        self.artistName = dictionary["artistName"] as? String ?? ""
        self.artistName = dictionary["artistName"] as? String ?? ""
        self.artworkUrl600 = dictionary["artworkUrl600"] as? String ?? ""
        self.trackCount = dictionary["trackCount"] as? Int ?? 0
        self.feedUrl = dictionary["feedUrl"] as? String ?? ""
        
        
        
    }
    init (){
        
    }
    
}
