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
    @IBOutlet weak var profileImage: UIImageView!
    
    
    
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        setupProfile()
        setupProfileImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        checkIfFollowed()
    }
    func setupProfile(){
        self.name.text = person.name
        self.username.text = person.username
        self.followButton.isEnabled = !(dbs.uid.isEmpty)
        
    }
    
    func setupProfileImage()  {
        
        dbs.fetchProfileImage(targetID: self.person.uid) { (image) in
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
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
