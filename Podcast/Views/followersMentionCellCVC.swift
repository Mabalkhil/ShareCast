//
//  followersMentionCellCVC.swift
//  Podcast
//
//  Created by Mazen.A on 3/22/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class followersMentionCellCVC: UICollectionViewCell {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    
    func setAttributes(person: Person){
        username.text = person.firstName + " " + person.lastName
        userImg!.sd_setImage(with: URL(string: person.profileImageURL))
    }
}
