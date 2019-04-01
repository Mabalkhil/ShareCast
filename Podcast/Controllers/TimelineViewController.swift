//
//  TimelineViewController.swift
//  Podcast
//
//  Created by Mazen.A on 2/25/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var timeline: UITableView!
    var posts = [Post]()
    var db = Firestore.firestore()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        timeline.delegate = self
        timeline.dataSource = self
        
        loadData()
        checkForUpdate()
        
        timeline.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: "refreshHandler", for: UIControl.Event.valueChanged)
    }

    
     func loadData() {
        let userID = Auth.auth().currentUser?.uid
        db.collection("general_timelines")
            .document(userID!)
            .collection("timeline").order(by: "Date", descending: true)
            .getDocuments(){
                QuerySnapshot, error in
                if let error = error {
                    print("\(error.localizedDescription)")
                }else{
                    self.posts = (QuerySnapshot?.documents
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
                    DispatchQueue.main.async {
                        self.timeline.reloadData()
                    }
                }
        }
    }
    
    
    
    
    
    
    @objc func checkForUpdate() {
        let userID = Auth.auth().currentUser?.uid
        db.collection("general_timelines")
            .document(userID!)
            .collection("timeline")
            .addSnapshotListener { QuerySnapshot, Error in
                if let error = Error {
                    print("\(error.localizedDescription)")
                }else{
                    guard let snapshot = QuerySnapshot else {return }
                    
                    snapshot.documentChanges.forEach({ (DocumentChange) in
                        if DocumentChange.type == .added {
                            print(DocumentChange.document.data()["episode_desc"])
                            self.posts.insert(Post(
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
                            DispatchQueue.main.async {
                                self.timeline.reloadData()
                            }
                        }
                    })
                }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timeline.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! TimelineTVC
        cell.setAttributes(post: posts[indexPath.row])
        return cell
    }
    
    @objc func refreshHandler() {
        loadData()
        checkForUpdate()
        self.refreshControl.endRefreshing()
    }
    
    
    // when a segue triggred  and before the visual transition occure
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEpisodeDetails" {
            if let indexPath = timeline.indexPathForSelectedRow {
                let destination = segue.destination as! EpisodeViewController
                var episode = Episode()
                episode.describtion = posts[indexPath.row].episode_desc ?? ""
                episode.title = posts[indexPath.row].episode_name ?? ""
                episode.pubDate = posts[indexPath.row].episode_Date
                episode.streamURL = posts[indexPath.row].episode_streamURL
                episode.fileUrl = posts[indexPath.row].episode_FileUrl
                episode.imageUrl = posts[indexPath.row].episode_img_url
                episode.author = posts[indexPath.row].episode_author
                episode.timeStampLables = posts[indexPath.row].episode_timeStampLables
                episode.time =  posts[indexPath.row].episode_time
                episode.timeStamps = posts[indexPath.row].episode_timeStamps
                
                destination.episode = episode
                print(self.posts[indexPath.row].episode_author)
                
            }
        }
    }
    
    
    

}
