//
//  User.swift
//  Podcast
//
//  Created by MacBook on 24/02/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import Foundation
import FirebaseFirestore


protocol DocumentSerializable {
    init?(dictionary : [String:Any])
}

struct User {
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
        init?(dictionary : [String:Any]) {
            self.email = dictionary["email"] as? String ?? ""
            self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
            self.firstName = dictionary["firstName"] as? String ?? ""
            self.lastName = dictionary["lastName"] as? String ?? ""
            self.username = (dictionary["username"] as? String)?.dropFirst() ?? ""
    
    
        }

    
}
