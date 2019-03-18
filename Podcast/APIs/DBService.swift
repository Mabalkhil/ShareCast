//
//  DBService.swift
//  Podcast
//
//  Created by MacBook on 14/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//


import Firebase
import UIKit

class DBService {
   //Singleton Object
    static let shared = DBService()
    let db = Firestore.firestore()
    let reffStor = Storage.storage().reference(forURL: "gs://sharecast-c780f.appspot.com").child("profile_Image")
    var uid = Auth.auth().currentUser?.uid ?? ""
    
    
    //MARK:- Signup Queries
    func singup(person: Person, uid: String, completionHandler: @escaping (UIAlertController) -> ())  {
        self.uid = uid
        self.db
            .collection("usersInfo")
            .document(uid)
            .setData(person.dictionary){
                error in
                if let err = error {
                    let alert = UIAlertController(title: err.localizedDescription, message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    completionHandler(alert)
                    
                }
                else{
                    print("ADDED WITH FIRESTORE:\n \(person.dictionary)")
                }
            
        }
        
                //POST STUFF
        let postDetails = ["username" : person.username]
        var ref:DocumentReference? = nil
        ref = self.db
            .collection("all_usernames")
            .addDocument(data: postDetails){
                error in
                if let error = error {
                    print("FIRESTORE: Error adding document \(error)")
                }else{
                    print("FIRESTORE: Document inserted successfully with ID: \(ref!.documentID)")
                }
        }
    }
    
    func getPerson(uid: String , completionHandler: @escaping (Person) -> ()){
        
        self.db
            .collection("usersInfo")
            .document(uid)
            .getDocument {
                (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting  Person with id \(uid) : \(err)")
                } else {
                    if let personDic = snapshot?.data() {
                        let person = Person(dictionary: personDic)!
                        completionHandler(person)
                    }
                    else {
                        print("FIRESTORE: Error parsing  Person with id \(uid)")
                    }
                    
                }
                
        }
    }
    
    //MARK:- Follow/Unfollow
    func follow(fid: String) {
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Following")
            .document(fid)
        self.db
            .collection("usersInfo")
            .document(fid)
            .collection("Followers")
            .document(uid)

    }
    
    func unfollow(fid: String) {
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Following")
            .document(fid)
            .delete()
        self.db
            .collection("usersInfo")
            .document(fid)
            .collection("Followers")
            .document(uid)
            .delete()
        
    }
    func isFollowing(fid: String, completionHandler: @escaping (Bool) -> ()){
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Following")
            .document(fid).getDocument {
                (snapshot, error) in
                completionHandler(snapshot?.exists ?? false)
        }
    }
    func getFollowingIDs(completionHandler: @escaping ([String]) -> ()){
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Following")
            .getDocuments {
                (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting subscribed channels: \(err)")
                } else {
                    var followingIDs = [String]()
                    for following in snapshot!.documents {
                        followingIDs.append(following.documentID)
                    }
                    completionHandler(followingIDs)
                }
                
        }
    }
    
    func getFollowersIDs(completionHandler: @escaping ([String]) -> ()){
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Followers")
            .getDocuments {
                (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting subscribed channels: \(err)")
                } else {
                    var followersIDs = [String]()
                    for follower in snapshot!.documents {
                        followersIDs.append(follower.documentID)
                    }
                    completionHandler(followersIDs)
                }
                
        }
    }

    
    
    

    
    //MARK:- Subscriptions Queries
    func subscribeToChannel(podcast: Podcast) {
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Subscriptions")
            .document((podcast.feedUrl?.toBase64())!)
            .setData((podcast.dictionary))
    }
    
    func unsubscribeToChannel(podcast: Podcast) {
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Subscriptions")
            .document((podcast.feedUrl?.toBase64())!)
            .delete()
    }
    func checkSubscribestion(podcast: Podcast, completionHandler: @escaping (Bool) -> ()){
        self.db
        .collection("usersInfo")
        .document(uid)
        .collection("Subscriptions")
        .document((podcast.feedUrl?.toBase64())!).getDocument {
            (snapshot, error) in
            completionHandler(snapshot?.exists ?? false)
        }
    }
    func getSubscriptions(completionHandler: @escaping ([Podcast]) -> ()){
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Subscriptions")
            .getDocuments {
                (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting subscribed channels: \(err)")
                } else {
                    var podcasts = [Podcast]()
                    for podcastDic in snapshot!.documents {
                        guard let podcast = Podcast(dictionary: podcastDic.data()) else {continue}
                        podcasts.append(podcast)
                    }
                    completionHandler(podcasts)
                }
                
        }
    }
    
    //MARK:- Profile Queries
    
    func updateUserInfo(updatedInfo: [String: Any]){
        self.db
            .collection("usersInfo")
            .document(uid)
            .updateData(updatedInfo)
    }
    
    func fetchProfileImage(completionHandler: @escaping (UIImage) -> ()){
        self.db
            .collection("usersInfo")
            .document(uid).getDocument { (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting profile image url: \(err)")
                } else if let profileImageUrl = snapshot?.data()?["profileImageURL"] {
                    let url = URL(string: profileImageUrl as! String)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if let err = error {
                            print(err)
                        }
                        let image = UIImage(data: data!)
                        completionHandler(image!)
                    }).resume()
                    

                }
                else{
                    print("No url found")
                    return
                }
        }
    }
    
    func loadProfilePosts(completionHandler: @escaping ([Post]) -> ()) {
        
        self.db.collection("private_timelines")
            .document(uid)
            .collection("timeline")
            .order(by: "Date", descending: true)
            .getDocuments(){
                QuerySnapshot, error in
                if let error = error {
                    print("\(error.localizedDescription)")
                }else{
                    
                    var posts = (QuerySnapshot?.documents
                        .flatMap({
                            Post(userName: $0.data()["author"] as! String,
                                 content: $0.data()["content"] as! String,
                                 img: $0.data()["author_img"] as! String,
                                 ep_name: $0.data()["episode_name"] as! String,
                                 ep_img: $0.data()["episode_img_link"] as! String,
                                 ep_desc: $0.data()["episode_desc"] as! String,
                                 postID: $0.documentID as! String)}))!
                    completionHandler(posts)
                }
        }
    }
    
    func updateProfilePosts(completionHandler: @escaping ([Post]) -> ()) {
        self.db.collection("private_timelines")
            .document(uid)
            .collection("timeline")
            .addSnapshotListener {
                QuerySnapshot, Error in
                if let error = Error {
                    print("\(error.localizedDescription)")
                }else{
                    guard let snapshot = QuerySnapshot else {return }
                    var posts = [Post]()
                    var counter = 0
                    snapshot.documentChanges.forEach({
                        (DocumentChange) in
                        counter += 1
                        if DocumentChange.type == .added {
                                posts.insert(Post(
                                userName: DocumentChange.document.data()["author"] as! String,
                                content: DocumentChange.document.data()["content"] as! String,
                                img: (DocumentChange.document.data()["author_img"] as? String)!,
                                ep_name: DocumentChange.document.data()["episode_name"] as! String,
                                ep_img: DocumentChange.document.data()["episode_img_link"] as! String,
                                ep_desc: DocumentChange.document.data()["episode_desc"] as! String,
                                postID: DocumentChange.document.documentID as! String), at: 0)
                            if(snapshot.documentChanges.count == counter){
                                completionHandler(posts)
                            }
                        }
                    })
                }
        }
    }
    
    func deletePost(postId: String) {
        self.db.collection("general_timelines")
            .document(uid)
            .collection("timeline").document(postId)
            .delete() {
                err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("FIRESTORE: Post successfully removed from general_timelines!: \(postId)")
                }
        }
        self.db.collection("private_timelines")
            .document(uid)
            .collection("timeline").document(postId)
            .delete() {
                err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("FIRESTORE: Post successfully removed from private_timelines!: \(postId)")
                }
        }
    }
    func setProfileImage(uploadData: Data){
        reffStor.child("\(uid).png").putData(uploadData, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err)
                return
            }
            self.reffStor.child("\(self.uid).png").downloadURL(completion: { (url, error) in
                if let err = error {
                    print(err)
                }else{
                    self.db
                        .collection("usersInfo")
                        .document(self.uid)
                        .updateData([
                            "profileImageURL":url?.absoluteString
                            ])
                }
            })
        }
    }
    
    //MARK:- Episode Queires
    
    func postComment(episode: Episode, comment: CommentObj, completionHandler: @escaping (String) -> ()){
        var ref: DocumentReference? = nil
        ref = self.db
            .collection("Episodes")
            .document(episode.streamURL.toBase64())
            .collection("Comments")
            .addDocument(data: comment.dictionary){
                err in
                if let err = err {
                    print("FIRESTORE: Error in posting comment, \(err)")
                }
                else{
                    completionHandler(ref!.documentID)
                }
        }
    }
    
    func getComments(episode: Episode, completionHandler: @escaping ([CommentObj]) -> ()){
        self.db
            .collection("Episodes")
            .document(episode.streamURL.toBase64())
            .collection("Comments")
            .getDocuments {
                (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting Comments: \(err)")
                } else {
                    var comments = [CommentObj]()
                    for commentDic in snapshot!.documents {
                        guard let comment = CommentObj(dictionary: commentDic.data()) else {continue}
                        comment.commentID = commentDic.documentID
                        comments.append(comment)
                    }
                    completionHandler(comments)
                }
                
        }

    }
    
    
    func deleteComment(episode: Episode, commentID: String, completionHandler: @escaping () -> ()) {
        print("Deleting from firestore")
        self.db
            .collection("Episodes")
            .document(episode.streamURL.toBase64())
            .collection("Comments")
            .document(commentID)
            .delete { Error in
                
                if let Error = Error {
                    print("Error removing document: \(Error)")
                } else {
                    print("FIRESTORE: Comment successfully removed from Episode!: \(commentID)")
                    completionHandler()
                }
        }
    }
    
    
}

