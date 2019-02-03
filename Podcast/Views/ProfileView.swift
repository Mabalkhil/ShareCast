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

    
    @IBOutlet weak var editProfile:UIButton! {
        didSet {
            let origImage = UIImage(named: "settings");
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            editProfile.setImage(tintedImage, for: .normal)
            editProfile.tintColor = UIColor.white
        }
    }
    @IBOutlet weak var username: UILabel!{
        didSet{
            self.username.text = "No Username"
        }
    }
    @IBOutlet weak var name: UILabel!{
        didSet{
            guard let uid = Auth.auth().currentUser?.uid else {
                self.name.text = "anonymous"
                return
            }
            reff.child("usersInfo").child(uid).observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                        let firstName = dictionary["firstName"] as! String
                        let lastName =  dictionary["lastName"] as! String
                        let username = dictionary["username"] as! String
                        self.name.text = "\(firstName) \(lastName)"
                        self.username.text = username
                }
            }
        }
    }
}
