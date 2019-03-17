//
//  CommentObj.swift
//  Podcast
//
//  Created by Mazen.A on 1/17/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class CommentObj: NSObject {
    
    var userRealName: String?
    var userName: String?
    var userImage: String?
    var commentDesc: String?
    var commentID: String?
    
    var dictionary : [String:Any]{
        return [
            "userRealName": userRealName ?? "",
            "userName": userName ?? "",
            "userImage":userImage ?? "",
            "commentDesc":commentDesc ?? ""
        ]
        
    }
    
    var imgURL : URL {
        return URL(string: userImage!) ?? URL(string: "https://yt3.ggpht.com/a-/AAuE7mCaS97ZoRx-C_7L7IszNnHivrl6IOqYDdelFA=s176-mo-c-c0xffffffff-rj-k-no")!
        
    }
    
     init?(dictionary : [String:Any]) {
        self.userRealName = dictionary["userRealName"] as? String ?? ""
        self.userName = dictionary["userName"] as? String ?? ""
        self.userImage = dictionary["userImage"] as? String ?? ""
        self.commentDesc = dictionary["userName"] as? String ?? ""
    }
    
    init(realName:String, username:String, img:String, com:String) {
        self.userRealName = realName
        self.userName = username
        self.userImage = img
        self.commentDesc = com
    }

}
