//
//  ProfileView.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/25/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileView: UIView {
   
   let reff = Database.database().reference()

    
    @IBOutlet weak var usernameLabel: UILabel!{
        didSet{
             let uid = Auth.auth().currentUser?.uid
            reff.child("users").child(uid!).observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    self.usernameLabel.text = dictionary["username"] as? String
                }
            }
        }
    }
}
