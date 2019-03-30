//
//  Post.swift
//  Podcast
//
//  Created by Mazen.A on 2/25/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class Post: NSObject {
    var username:String?
    var postContent:String?
    var userImage:String?
    var episode_name:String?
    var episode_img_url:String?
    var episode_desc:String?
    var post_id:String?
    let episode_Date: Date
    var episode_FileUrl: String?
    var episode_timeStamps: [String]?
    let episode_author: String
    let episode_streamURL: String
    
    var episode_timeStampLables: [String]?
    var episode_time:Double?
    
    init(userName:String, content:String, img:String, ep_name:String, ep_img:String, ep_desc:String,
        episode_Date:  Date ,
        episode_FileUrl:String, episode_timeStamps: [String], episode_timeStampLables: [String],
        episode_streamURL: String,  episode_author: String,  episode_time:Double ,postID:String ) {
        self.username = userName
        self.postContent = content
        self.userImage = img
        self.episode_name = ep_name
        self.episode_img_url = ep_img
        self.episode_desc = ep_desc
        self.post_id = postID
        self.episode_author = episode_author
        self.episode_time = episode_time
        self.episode_FileUrl = episode_FileUrl
        self.episode_streamURL = episode_streamURL
        self.episode_timeStamps = episode_timeStamps
        self.episode_timeStampLables = episode_timeStampLables
        self.episode_Date =  episode_Date
        
    }
}

