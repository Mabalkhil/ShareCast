//
//  PeopleCell.swift
//  Podcast
//
//  Created by Khaled H on 06/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    
    
    var person: Person! {
        didSet{
            name.text = person.name
            username.text = person.username
            
            profileImg.layer.borderWidth = 1
            profileImg.layer.masksToBounds = false
            profileImg.layer.cornerRadius = profileImg.frame.height/2
            profileImg.clipsToBounds = true
            profileImg.sd_setImage(with: person.imgURL, completed: nil)
        }
    }
    
}
