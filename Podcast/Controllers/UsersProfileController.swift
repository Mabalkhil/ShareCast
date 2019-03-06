//
//  UsersProfileController.swift
//  Podcast
//
//  Created by Khaled H on 06/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class UsersProfileController: UIViewController {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var posts: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    
    var person: Person!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.name.text = person.name
        self.username.text = person.username
        
    }
    

    

}
