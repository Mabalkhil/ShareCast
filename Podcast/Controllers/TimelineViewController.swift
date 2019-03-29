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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        timeline.delegate = self
        timeline.dataSource = self
        
        loadData()
        checkForUpdate()
        // Do any additional setup after loading the view.
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
                             postID: $0.documentID as! String)}))!
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
                            self.posts.insert(Post(
                                userName: DocumentChange.document.data()["author"] as! String,
                                content: DocumentChange.document.data()["content"] as! String,
                                img: (DocumentChange.document.data()["author_img"] as? String)!,
                                ep_name: DocumentChange.document.data()["episode_name"] as! String,
                                ep_img: DocumentChange.document.data()["episode_img_link"] as! String,
                                ep_desc: DocumentChange.document.data()["episode_desc"] as! String,
                                postID: DocumentChange.document.documentID as! String), at: 0)
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
    
   

}
