//
//  Service.swift
//  Podcast
//
//  Created by MacBook on 14/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//


import Firebase
import UIKit
import GoogleSignIn
class DBService {
   //Singleton Object
    static let shared = DBService()
    let db = Firestore.firestore()
    let reffStor = Storage.storage().reference(forURL: "gs://sharecast-c780f.appspot.com").child("profile_Image")
    var uid = Auth.auth().currentUser?.uid ?? ""
    var followers = [Person]()
    var followers_ids = [String]()

    
    
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
//        func(user : User, uid: String, completionHandler: @escaping (UIAlertController) -> ())do {
//            var person : Person
//        
//            var dictionary : [String:Any]{
//                return [
//                    "email": user.,
//                    "profileImageURL": "profileImageURL",
//                    "firstName":"firstName",
//                    "lastName":"lastName",
//                    "username":"@\()"
//                ]
//            }
//            person = Person(dictionary: dictionary)
//        
//            self.singup(person: person, uid: uid, completionHandler: { (alert) in
//                completionHandler(alert)
//            })
//        
//        }
        
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
                        let person = Person(uid: uid, dictionary: personDic)!
                        completionHandler(person)
                    }
                    else {
                        print("FIRESTORE: Error parsing  Person with id \(uid)")
                    }
                    
                }
        }
    }
    
    func getPersons(uids : [String], completionHandler: @escaping ([Person]) -> ()){
        var count = 0
        var persons = [Person]()
        for uid in uids {
            
            self.getPerson(uid: uid) { (person) in
                persons.append(person)
            }
            count = count + 1
            if count == uids.count {
                completionHandler(persons)
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
            .setData([:])
        
        self.db
            .collection("usersInfo")
            .document(fid)
            .collection("Followers")
            .document(uid)
            .setData([:])

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

    
    func getFollowers(completionHandler: @escaping ([Person]) -> ()){
        self.getFollowersIDs { (uids) in
            self.getPersons(uids: uids, completionHandler: { (followers) in
                completionHandler(followers)
            })
        }
    }
    
    func getFollowing(completionHandler: @escaping ([Person]) -> ()){
        self.getFollowingIDs { (uids) in
            self.getPersons(uids: uids, completionHandler: { (followers) in
                completionHandler(followers)
            })
        }
    }

    

    
    func getFollowers2(completionHandler: @escaping ([Person]) -> ()){
        self.followers.removeAll()
        var followers = [Person]()
        var followersIDs = [String]()
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Followers")
            .getDocuments {
                (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting subscribed channels: \(err)")
                } else {
                    for follower in snapshot!.documents {
                        followersIDs.append(follower.documentID)
                    }
                    DispatchQueue.global(qos: .background).async {
                        for oneUser in followersIDs{
                            self.getPerson(uid: oneUser, completionHandler: { (Person) in
                                followers.append(Person)
                              
                                    self.followers.append(Person)
                                
                            })
                        }
                    }
                    completionHandler(followers)
                }
        }
    }
    
    
    //MARK:- Bell Queries
    
    func bellAChannel(podcast: Podcast) {
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Bell")
            .document((podcast.feedUrl?.toBase64())!)
            .setData((podcast.dictionary))
    }
    
    func unBellAChannel(podcast: Podcast) {
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Bell")
            .document((podcast.feedUrl?.toBase64())!)
            .delete()
    }
    
    func checkBell(podcast: Podcast, completionHandler: @escaping (Bool) -> ()){
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Bell")
            .document((podcast.feedUrl?.toBase64())!).getDocument {
                (snapshot, error) in
                completionHandler(snapshot?.exists ?? false)
        }
    }
    
    func getBellChannels(completionHandler: @escaping ([Podcast]) -> ()){
        self.db
            .collection("usersInfo")
            .document(uid)
            .collection("Bell")
            .getDocuments {
                (snapshot, err) in
                if let err = err {
                    print("FIRESTORE: Error getting bell channels: \(err)")
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
    
    func getMentionedEpisodes(completionHandler: @escaping ([Post]) -> ()){

        self.db
            .collection("mentions")
            .document(uid)
            .collection("my_mentions")
            .getDocuments{
                (QuerySnapshot, error) in
                if let error = error {
                    print("\(error.localizedDescription)")
                }else{
                    var posts = (QuerySnapshot?.documents
                        .flatMap({
                            Post(userName: $0.data()["author"] as! String,
                                 content: "",
                                 img: $0.data()["author_img"] as! String,
                                 ep_name: $0.data()["episode_name"] as! String,
                                 ep_img: $0.data()["episode_img_link"] as! String,
                                 ep_desc: $0.data()["episode_desc"] as! String,
                                 episode_Date: $0.data()["episode_Date"] as! Date,
                                 episode_FileUrl: $0.data()["episode_FileUrl"] as! String,
                                 episode_timeStamps: $0.data()["episode_timeStamps"] as! [String],
                                 episode_timeStampLables: $0.data()["episode_timeStampLables"] as! [String],
                                 episode_streamURL: $0.data()["episode_streamURL"] as! String,
                                 episode_author: $0.data()["episode_author"] as! String,
                                 episode_time: $0.data()["episode_time"] as! Double,
                                 postID: $0.documentID as! String)}))!
                    completionHandler(posts)
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
    
    func fetchProfileImage(targetID: String,completionHandler: @escaping (UIImage) -> ()){
        self.db
            .collection("usersInfo")
            .document(targetID).getDocument { (snapshot, err) in
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
                                 episode_Date: $0.data()["episode_Date"] as! Date,
                                 episode_FileUrl: $0.data()["episode_FileUrl"] as! String,
                                 episode_timeStamps: $0.data()["episode_timeStamps"] as! [String],
                                 episode_timeStampLables: $0.data()["episode_timeStampLables"] as! [String],
                                 episode_streamURL: $0.data()["episode_streamURL"] as! String,
                                 episode_author: $0.data()["episode_author"] as! String,
                                 episode_time: $0.data()["episode_time"] as! Double,
                                 postID: $0.data()["post_id"] as! String)}))!
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
                                episode_Date: DocumentChange.document.data()["episode_Date"] as! Date,
                                episode_FileUrl: DocumentChange.document.data()["episode_FileUrl"] as! String,
                                episode_timeStamps: DocumentChange.document.data()["episode_timeStamps"] as! [String],
                                episode_timeStampLables: DocumentChange.document.data()["episode_timeStampLables"] as! [String],
                                episode_streamURL: DocumentChange.document.data()["episode_streamURL"] as! String,
                                episode_author: DocumentChange.document.data()["episode_author"] as! String,
                                episode_time: DocumentChange.document.data()["episode_time"] as! Double,
                                postID: DocumentChange.document.data()["post_id"] as! String), at: 0)
                            if(snapshot.documentChanges.count == counter){
                                completionHandler(posts)
                            }
                        }
                    })
                }
        }
    }
    
    func deleteMention(postId: String) {
        self.db.collection("mentions")
            .document(uid)
            .collection("my_mentions").document(postId)
            .delete() {
                err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("FIRESTORE: mention successfully removed post ID = \(postId)")
                }
        }
    }
    
    func deletePost(postId: String) {
        var postID:String?
        
        
        
        self.db.collection("general_timelines")
            .document(uid)
            .collection("timeline").whereField("post_id", isEqualTo: postId).getDocuments{
                QuerySnapshot,err  in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    for singlePost in (QuerySnapshot?.documents)!{
                        postID = singlePost.documentID
                        self.db.collection("general_timelines")
                            .document(self.uid)
                            .collection("timeline").document(postID!).delete() {
                                err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("FIRESTORE: Post successfully removed from \(self.uid) general_timelines")
                                }
                        }
                    }
                }
        }
        
        self.getFollowersIDs{ (result) in
            self.followers_ids = result
            DispatchQueue.main.async {
                
                for follower in self.followers_ids{
                    self.db.collection("general_timelines")
                        .document(follower)
                        .collection("timeline").whereField("post_id", isEqualTo: postId).getDocuments{
                            QuerySnapshot,err  in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                for singlePost in (QuerySnapshot?.documents)!{
                                    print(singlePost)
                                    postID = singlePost.documentID
                                    self.db.collection("general_timelines")
                                        .document(follower)
                                        .collection("timeline").document(postID!).delete() {
                                            err in
                                            if let err = err {
                                                print("Error removing document: \(err)")
                                            } else {
                                                print("FIRESTORE: Post successfully removed from \(follower) general_timelines")
                                            }
                                    }
                                }
                            }
                    }
                }
                
                
            }
        }
      
        
        
        self.db.collection("private_timelines")
            .document(self.uid)
            .collection("timeline").whereField("post_id", isEqualTo: postId).getDocuments{
                QuerySnapshot,err  in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    for singlePost in (QuerySnapshot?.documents)!{
                        print(singlePost)
                        postID = singlePost.documentID
                        self.db.collection("private_timelines")
                            .document(self.uid)
                            .collection("timeline").document(postID!).delete() {
                                err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("FIRESTORE: Post successfully removed from \(self.uid) private_timelines!:")
                                }
                        }
                    }
                }
        }
        
        
        
        self.db.collection("Posts").document(postId)
            .delete() {
                err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("FIRESTORE: mention successfully removed post ID = \(postId)")
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
    //Comment Queries
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
    
    
    //Likes Queries
    func likeEpisode(episode: Episode){
        
        self.db
            .collection("Episodes")
            .document(episode.streamURL.toBase64())
            .collection("Likes")
            .document(uid)
            .setData([:])
        
    }
    
    
    func unlikeEpisode(episode: Episode){
        
        self.db
            .collection("Episodes")
            .document(episode.streamURL.toBase64())
            .collection("Likes")
            .document(uid)
            .delete { (Error) in
                
                if let Error = Error{
                    print("Error removing document: \(Error)")
                } else {
                    print("FIRESTORE: Like successfully removed from Episode!")
                }
                
        }
    }
    
    func checkForLikes(episode: Episode, completionHandler: @escaping (Bool, Int) -> ()){

        var liked = false
        var list: [String] = []

        self.db
            .collection("Episodes")
            .document(episode.streamURL.toBase64())
            .collection("Likes").getDocuments { (QuerySnapshot, Error) in
                
                if let Error = Error{
                    print("Error Checking Episode Coolection")
                    
                } else {
                
                    for doc in (QuerySnapshot?.documents)! {
                        list.append(doc.documentID)
                    }
                }
                
                completionHandler(list.contains(self.uid), list.count)
        }

    }

    
}


