//
//  UsersProfileController.swift
//  Podcast
//
//  Created by Khaled H on 06/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

class UsersProfileController: UIViewController {
    
    //MARK:- V
    var person: Person!
    var firebaseReff = Auth.auth().currentUser
    var dbs = DBService.shared
    var alert: UIAlertController!
    var alertAction: UIAlertAction!
    //MARK:- @IBOutlet
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var posts: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    
    
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()
    }
    override func viewWillAppear(_ animated: Bool) {
        checkIfFollowed()
    }
    func setupProfile(){
        self.name.text = person.name
        self.username.text = person.username
        self.followButton.isEnabled = !(dbs.uid.isEmpty)
    }
    
    //MARK:- Toggle Follow
    
    @IBAction func toggleFollow(_ sender: UIButton) {
        
        let fid : String = person.uid
        if fid.isEmpty{
            print("ERROR: Could not follow user with no uid")
            return
        }
        guard  let uid = firebaseReff?.uid else {return}
        
        
        if followButton.titleLabel?.text == "Follow" {
            follow(uid: uid, fid: fid)
        }
        else {
            unfollow(uid: uid, fid: fid)
        }
    }
    func follow(uid: String, fid: String){
        self.dbs.follow(fid: fid)
        self.followButton.setTitle("Unfollow", for: .normal)
        
    }
    func unfollow(uid: String, fid: String){
        self.dbs.unfollow(fid: fid)
        followButton.setTitle("Follow", for: .normal)

        
    }
    //MARK:-
    func checkIfFollowed(){
        if dbs.uid.isEmpty{
            followButton.isEnabled = false
        }
        else{
            dbs.isFollowing(fid: person.uid) { (followed) in
                if followed {
                    print("User \(self.person.username) is followed")
                    self.followButton.setTitle("Unfollow", for: .normal)
                } else {
                    print("User \(self.person.username) is not followed")
                    self.followButton.setTitle("Follow", for: .normal)
                }
            }

        }
    }

}
