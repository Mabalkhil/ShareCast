//
//  User.swift
//  Podcast
//
//  Created by Khaled H on 05/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

struct Person {
    var uid : String
    var email : String
    var profileImageURL : String
    var firstName : String
    var lastName : String
    var username : String
    
    var dictionary : [String:Any]{
        return [
            "email": email,
            "profileImageURL": profileImageURL,
            "firstName":firstName,
            "lastName":lastName,
            "username":"@\(username)"
        ]
        
    }
    var name : String {
        return firstName+" "+lastName
    }
    var imgURL : URL {
        return URL(string: profileImageURL) ?? URL(string: "https://firebasestorage.googleapis.com/v0/b/sharecast-c780f.appspot.com/o/profile_Image%2FDefault.png?alt=media&token=37fdc72b-ffbe-430a-85c8-07dde877e71d")!
        
    }
    
    
    init?(dictionary : [String:Any]) {
        self.uid = ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.username = (dictionary["username"] as? String)?.dropFirst() ?? ""
        
        
    }
    
    init?(uid: String, dictionary : [String:Any]){
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.username = (dictionary["username"] as? String)?.dropFirst() ?? ""
        
    }
    
}
