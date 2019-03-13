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
    var date:Date?
    
    init(userName:String, content:String, img:String, ep_name:String, ep_img:String, ep_desc:String, dateID:Date, postID:String) {
        self.username = userName
        self.postContent = content
        self.userImage = img
        self.episode_name = ep_name
        self.episode_img_url = ep_img
        self.episode_desc = ep_desc
        self.date = dateID
        self.post_id = postID
    }
}

