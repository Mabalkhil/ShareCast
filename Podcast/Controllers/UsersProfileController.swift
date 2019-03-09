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
    var firebaseSubReff = Database.database().reference().child("usersInfo")
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
        self.followButton.isEnabled = !(firebaseReff?.uid == nil)
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
        firebaseSubReff.child(uid).child("Following").updateChildValues([fid: 1])
        firebaseSubReff.child(fid).child("Followers").updateChildValues([uid: 1])
        self.followButton.setTitle("Unfollow", for: .normal)
        
    }
    func unfollow(uid: String, fid: String){
        guard  let uid = firebaseReff?.uid else {return}
        firebaseSubReff.child(uid).child("Following").updateChildValues([fid: 0])
        firebaseSubReff.child(fid).child("Followers").updateChildValues([uid: 0])
        followButton.setTitle("Follow", for: .normal)

        
    }
    //MARK:-
    func checkIfFollowed(){
        guard let uid = firebaseReff?.uid else {
            followButton.isEnabled = false
            return
        }
        self.firebaseSubReff.child(uid).child("Following").observeSingleEvent(of: .value) { (snapshot) in
            var followed = false
            for case let rest as DataSnapshot in snapshot.children {
                
                if self.person.uid == rest.key {
                    followed = ((rest.value as! Int) == 1)
                    break
                }
            }
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
