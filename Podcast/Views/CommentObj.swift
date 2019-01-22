//
//  CommentObj.swift
//  Podcast
//
//  Created by Mazen.A on 1/17/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class CommentObj: NSObject {
    
    var userRealName:String?
    var userName:String?
    var userImage:String?
    var commentDesc:String?
    
    init(realName:String, username:String, img:String, com:String) {
        self.userRealName = realName
        self.userName = username
        self.userImage = img
        self.commentDesc = com
    }

}
