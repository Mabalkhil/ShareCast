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
   
    let dbs = DBService.shared
    let userid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var editProfile:UIButton!
    
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
            self.dbs.getPerson(uid: uid, completionHandler: { (Person) in
                self.name.text = "\(Person.firstName) \(Person.lastName)"
                self.username.text = "@\(Person.username)"
            })
        }
    }
    
    
    override func didMoveToWindow() {
        
        if checkUpdatedProfile == true {
            self.dbs.getPerson(uid: self.userid!, completionHandler: { (Person) in
                self.name.text = "\(Person.firstName) \(Person.lastName)"
                self.username.text = "@\(Person.username)"
            })
            checkUpdatedProfile = false
        }
    }
    
    
}
