//
//  CommentExtension.swift
//  Podcast
//
//  Created by Khaled H on 13/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

extension EpisodeViewController{
    //Hide View method
    @objc func hidePostView() {
        //to hide text
        self.postContentTV.text = String()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0.0
            self.writePost.alpha = 0.0
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
            PlayerDetailsViewController.shared.view.isHidden = false
        }, completion: nil)
    }
    
    
    //Adding new post to Firebase
    func addNewPost() {
        
        var ref:DocumentReference? = nil
        var postDetails = ["uid" : userID,
                           "author": username,
                           "author_img":userImage,
                           "content" : postContentTV.text,
                           "Date" : Date(),
                           "episode_link" : episode.fileUrl,
                           "episode_img_link" : episode.imageUrl,
                           "episode_name" : episode.title,
                           "episode_desc" : episode.describtion] as [String : Any]
        
        ref = self.fireStoreDatabaseRef.collection("Posts").addDocument(data: postDetails){
            error in
            
            if let error = error {
                print("Error adding document \(error)")
            }else{
                print("Document inserted successfully with ID: \(ref!.documentID)")
                self.databaseRef.child("Timeline").child(self.userID!).childByAutoId().setValue("\(ref!.documentID)")
            }
        }
        
        postDetails = ["uid" : userID,
                       "author": username,
                       "author_img":userImage,
                       "content" : postContentTV.text,
                       "Date" : Date(),
                       "episode_link" : episode.fileUrl,
                       "episode_img_link" : episode.imageUrl,
                       "episode_name" : episode.title,
                       "episode_desc" : episode.describtion,
                       "post_id" : ""] as [String : Any]
        ref = self.fireStoreDatabaseRef
            .collection("general_timelines")
            .document(self.userID!)
            .collection("timeline")
            .addDocument(data: postDetails){
                error in
                if let error = error {
                    print("Error adding document \(error)")
                }else{
                    print("Document inserted successfully with ID: \(ref!.documentID)")
                }
        }
        
        print(self.followersIDs)
        for userUID in self.followersIDs{
            print(userUID)
            ref = self.fireStoreDatabaseRef
                .collection("general_timelines")
                .document(userUID)
                .collection("timeline")
                .addDocument(data: postDetails){
                    error in
                    if let error = error {
                        print("Error adding document \(error)")
                    }else{
                        print("Document inserted successfully with ID: \(ref!.documentID)")
                    }
            }
        }
        
        ref = self.fireStoreDatabaseRef
            .collection("private_timelines")
            .document(self.userID!)
            .collection("timeline")
            .addDocument(data: postDetails){
                error in
                if let error = error {
                    print("Error adding document \(error)")
                }else{
                    print("Document inserted successfully with ID: \(ref!.documentID)")
                }
        }
    }
    
    //adding new comment to the episode
    @objc func addNewComment() {
        let comment = CommentObj(
        realName: person?.name ?? "",
        username: self.username!,
        img: userImage ?? "" ,
        com: commentContentTF.text!)
        
        commentContentTF.placeholder = "Comment here"
        commentContentTF.text = ""
        
        self.dbs.postComment(episode: self.episode, comment: comment) {commentID in
            
            DispatchQueue.main.async {
                comment.commentID = commentID
                print(commentID)
                self.comments.append(comment)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK:- Comment Table methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Comment", for: indexPath) as! CommentCell
        
        let comment = self.comments[indexPath.row]
        cell.comment = comment
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //This part checks the firebase
        guard (Auth.auth().currentUser?.uid) != nil else {
            alertUser("Not Register", "You have to register to get this feature")
            return
        }
        
        print("Starting deletion")
        let comment = self.comments[indexPath.row]
        
        if comment.userName != self.username {
            alertUser("Sorry", "You are not authorized to delete this comment!!")
            
        } else {
            print("In else statement")
            self.dbs.deleteComment(episode: self.episode, commentID: comment.commentID!) {
                
                DispatchQueue.main.async {
                    self.comments.remove(at: indexPath.row)
                    print("Cell removed from list !!!!")
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    
    func alertUser(_ title: String, _ msg: String){
        
       let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
