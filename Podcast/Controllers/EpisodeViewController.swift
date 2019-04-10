//
//  ViewController.swift
//  ShareCast
//
//  Created by Mazen.A on 1/10/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class EpisodeViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {

    
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var tableViewComments: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var playlistsCV: UICollectionView!
    @IBOutlet var followerCV: UICollectionView!


    
    //Repost/Comment View
    let dispatch = DispatchGroup()
    let dbs = DBService.shared
    let uid = Auth.auth().currentUser?.uid ?? ""
    @IBOutlet var writePost: UIView!
    @IBOutlet weak var postContentTV: UITextView!
    
    @IBOutlet weak var playButton: UIButton!
    
    var postType: String = ""
    
    var comments = [CommentObj]()
    let cellId = "cellId"
    var followersIDs : [String] = []
    var followers : [Person] = []
    var episode = Episode()
    let blackView = UIView()
    var playlists = UserDefaults.standard.playlistsArray()
    
    var fireStoreDatabaseRef = Firestore.firestore()
    var fireBaseDatabaseRef = Database.database().reference()
    var databaseRef = DatabaseReference.init()
    var userID:String?
    var username:String?
    var userImage:String?
    var person : Person?
    var counter = 0
    var key = ""
    var exist = false
    var fileURL = ""

    //MARK:- Buttons Actions
    // this function will change the episode and start the player - YAY!
    @IBAction private func clickToPlay(_ sender: UIButton) {
        PlayerDetailsViewController.shared.setEpisode(episode: self.episode)
    }
    
    @IBOutlet weak var addToPlaylistButton: UIButton!{
        didSet{
            addToPlaylistButton.addTarget(self, action: #selector(addToPlaylist), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var bookmarkButton: UIButton!{
        didSet{
            bookmarkButton.addTarget(self, action: #selector(bookmarkAddingHandler), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var downloadButton: UIButton!{
        didSet{
            downloadButton.addTarget(self, action: #selector(downloadHandler), for: .touchUpInside)
        }
    }
    
    //repost button
    @IBOutlet weak var rePostButton: UIButton!{
        didSet{
            rePostButton.addTarget(self, action: #selector(repostHandler), for: .touchUpInside)
        }
    }
    
    //Comment button
    @IBOutlet weak var commentButton: UIButton!{
        didSet{
            commentButton.addTarget(self, action: #selector(repostHandler), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var mentionToUser: UIButton!{
        didSet{
            mentionToUser.addTarget(self, action: #selector(recommendToUser), for: .touchUpInside)
        }
    }
    
    
    
    //Repost-Comment view buttons
    @IBOutlet weak var createPostButton: UIButton!{
        didSet{
            createPostButton.addTarget(self, action: #selector(createNewPost), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var postCancelButton: UIButton!{
        didSet{
            postCancelButton.addTarget(self, action: #selector(cancelNewPost), for: .touchUpInside)
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        if (Auth.auth().currentUser?.uid) != nil {
            setUpDatabases()
        }
        
        setAttributes()
        setUpComments()
        
        self.playButton.layer.cornerRadius = playButton.layer.frame.size.width/2
        self.view.addSubview(self.playButton)
        
        playlistsCV.delegate = self
        playlistsCV.dataSource = self
        
        followerCV.delegate = self
        followerCV.dataSource = self
        
        postContentTV.delegate = self
        let index = playlists.count
        playlists.insert(Playlist(name: "Cancel", epis_list: []), at: index)
        
         fileURL = episode.fileUrl ?? ""
        if Auth.auth().currentUser?.uid != nil {
        
            checkLikedEpisode()

        }
        
        // Do any additional setup after loading the view, typically from a nib.
        let bookedEpisodes = UserDefaults.standard.bookmarkedEpisodes()
        if bookedEpisodes.index(where : {$0.title == self.episode.title && $0.author == self.episode.author}) != nil {
            bookmarkButton.setImage(UIImage(named: "bookmark_highlight"), for: .normal)
        }
    }
    

    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setAttributes(){
        descriptionLabel.text = episode.describtion
        titleLabel.text = episode.title
        guard let url = URL(string: episode.imageUrl ?? "") else {return}
        episodeImage.sd_setImage(with: url)
    }
    
    //This method checks if the user liked this episode before
    func checkLikedEpisode(){
        self.dbs.checkForLikes(episode: self.episode){ (liked, count)  in
            
            DispatchQueue.main.async {
                if liked{
                    self.likeButton.setTitle("unlike", for: .normal)
                    self.likeButton.setImage(UIImage(named: "like_filled"), for: .normal)
                }
                
                self.counter = count
                self.likeCounter.text = "\(self.counter)"
            }
            
        }
        
    }
    
    //MARK:- DOWNLOAD
    @objc func downloadHandler(){
        UserDefaults.standard.downloadEpisode(episode: episode.self)
        APIService.shared.downloadEpisode(episode: episode.self)
        //downloadButton.setImage(#imageLiteral(resourceName: "download_Done"), for: .normal)
        if let tabItems = tabBarController?.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
            let tabItem = tabItems[2]
            tabItem.badgeValue = "1"
        }
    }
    
    @objc func handelDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0.0
            self.playlistsCV.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 200)
            self.followerCV.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 200)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
            PlayerDetailsViewController.shared.view.isHidden = false
        }, completion: nil)
    }
    
    @objc func addToPlaylist(){
        
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0
        
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelDismiss)))
        
        self.view.addSubview(blackView)
        self.view.addSubview(playlistsCV)
        
        let cvHeight = CGFloat(50 * playlists.count) + (self.tabBarController?.tabBar.frame.height)!
        let y = self.view.frame.height - cvHeight
        playlistsCV.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: cvHeight)
        blackView.frame = self.view.bounds
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0.5
            self.playlistsCV.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: cvHeight)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
            PlayerDetailsViewController.shared.view.isHidden = true
        }, completion: nil)
    }
    
    
    @objc func recommendToUser(){
        
        guard (Auth.auth().currentUser?.uid) != nil else {
            self.copyLinkToClipboard()
            self.view.showToast(toastMessage: "Link Copied Seccessfully", duration: 1.1)
            return
        }
        
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0
        
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelDismiss)))
        
        
        self.view.addSubview(blackView)
        self.view.addSubview(followerCV)
        
        if followers.isEmpty{
            followers = dbs.followers
            //followersIDs = followers.userID
        }
        let cvHeight = CGFloat(50 * followers.count) + (self.tabBarController?.tabBar.frame.height)! + 30
        let y = self.view.frame.height - cvHeight
        followerCV.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: cvHeight)
        blackView.frame = self.view.bounds
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0.5
            self.followerCV.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: cvHeight)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
            PlayerDetailsViewController.shared.view.isHidden = true
        }, completion: nil)
        
    }
    
    //MARK:- BOOKMARK
    @objc func bookmarkAddingHandler(){
    
        // Checking if the button has highlighted image or not to run the correct operation
        if bookmarkButton.currentImage.hashValue == UIImage(named: "bookmark").hashValue{
            UserDefaults.standard.addBookmark(episode: episode)
            bookmarkButton.setImage(UIImage(named: "bookmark_highlight"), for: .normal)
        }else{
            UserDefaults.standard.deleteBookmarkedEpisode(episode: episode)
            bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
    
    //MARK:- LIKE
    @IBAction func likePressed(_ sender: Any) {
        // check if the user register
        guard (Auth.auth().currentUser?.uid) != nil else {
            self.alertUser("Not Register", "You have to register to get this feature")
            return
        }
        
        if likeButton.titleLabel?.text == "like" {
            
            self.counter += 1
            self.dbs.likeEpisode(episode: self.episode)
            likeButton.setTitle("unlike", for: .normal )
            likeButton.setImage(UIImage(named: "like_filled"), for: .normal)
            
        }else{
            
            self.counter -= 1
            self.dbs.unlikeEpisode(episode: self.episode)
            likeButton.setTitle("like", for: .normal )
            likeButton.setImage(UIImage(named: "like"), for: .normal)
            
        }
         self.likeCounter.text = "\(self.counter)"
    }
    
    
    func checkEpisodeUrl() {
        fireBaseDatabaseRef.child("Episodes").observeSingleEvent(of: .value) { (snapshot) in
            for case let epi as DataSnapshot in snapshot.children {
                let channelObj = epi.value as! [String:Any]
                guard let url = (channelObj["eURL"] as! String?) else {
                    return
                }
                if(self.fileURL == url){
                self.counter = channelObj["counter"] as! Int
                self.key = epi.key
                self.exist = true
                        break
                }
            }
            if self.exist == false {
                self.key =  self.fireBaseDatabaseRef.child("Episodes").childByAutoId().key ?? ""
                self.fireBaseDatabaseRef.child("Episodes").child(self.key).updateChildValues(["eURL": self.fileURL,"counter":0])
            }
            self.likeCounter.text = "\(self.counter)"
        }
    }
    
    //MARK:- Post handeler
    @objc func createNewPost(){
        
        if postType == "repost" {
            self.addNewPost()
            
        } else {
            self.addNewComment()
        }
        
        self.hidePostView()
    }
    
    @objc func cancelNewPost(){
        self.hidePostView()
    }
    
    
    //handling post view
    @objc func repostHandler(sender: UIButton){
        
        guard (Auth.auth().currentUser?.uid) != nil else {
            alertUser("Not Register", "You have to register to get this feature")
            return
        }
        
        postType = sender.currentTitle!
        
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0
        writePost.alpha = 0
        
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidePostView)))
        
        self.view.addSubview(blackView)
        self.view.addSubview(writePost)
        
        let width = self.view.frame.width / 1.25
        let height = width * 9 / 16
        let y = (self.view.frame.height - height)/2
        let x = (self.view.frame.width - width)/2
        writePost.frame = CGRect(x: x, y: y, width: width, height: height)
        blackView.frame = self.view.bounds
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0.5
            self.writePost.alpha = 1
            self.writePost.frame = CGRect(x: x, y: y, width: width, height: height)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
            PlayerDetailsViewController.shared.view.isHidden = true
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.playlistsCV{
            return playlists.count
        }else {
            return followers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.playlistsCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playlist", for: indexPath) as! playlistCellAddingCVC
            cell.setAttributes(playlist: playlists[indexPath.row])
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "follower", for: indexPath) as! followersMentionCellCVC
            cell.setAttributes(person: followers[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.playlistsCV {
            if playlists[indexPath.row].playlistName != "Cancel"{
                playlists[indexPath.row].addTask(ep: self.episode)
                UserDefaults.standard.playlistEpisode(episode: self.episode, name: playlists[indexPath.row].playlistName!)
            }
        }else {
            var ref:DocumentReference? = nil
            let user = followers[indexPath.row].uid

            var mentionDetails = ["uid" : userID,
                                  "author": username,
                                  "author_img":userImage,
                                  "content" : postContentTV.text,
                                  "Date" : Date(),
                                  "episode_link" : episode.fileUrl,
                                  "episode_img_link" : episode.imageUrl,
                                  "episode_name" : episode.title,
                                  "episode_desc" : episode.describtion,
                                  "episode_Date" : episode.pubDate,
                                  "episode_FileUrl" : episode.fileUrl,
                                  "episode_timeStamps" : episode.timeStamps,
                                  "episode_timeStampLables" : episode.timeStampLables,
                                  "episode_streamURL" : episode.streamURL,
                                  "episode_author" : episode.author,
                                  "episode_time" : episode.time
                ] as [String : Any]
            
            ref = self.fireStoreDatabaseRef
                .collection("mentions")
                .document(user)
                .collection("my_mentions")
                .addDocument(data: mentionDetails){
                    error in
                    if let error = error {
                        print("Error adding document \(error)")
                    }else{
                        print("Document inserted successfully with ID: \(ref!.documentID)")
                    }
            }
        }
        handelDismiss()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //MARK:- Comments
    func setUpComments(){
        dbs.getComments(episode: self.episode) { (comments) in
            DispatchQueue.main.async {
                self.comments = comments
                self.tableView.reloadData()
            }
        }
    }
    
    func setUpDatabases(){
        self.userID = Auth.auth().currentUser?.uid
        if self.userID != nil {
            self.dbs.getPerson(uid: userID!) {(person) in
                self.person = person
                self.username = person.username
                self.userImage = person.profileImageURL
            }

        dbs.getFollowers2 { (result) in
            self.followers = result
            
            DispatchQueue.main.async {
                self.blackView.setNeedsLayout()
                self.blackView.layoutIfNeeded()
            }
        }
            
            dbs.getFollowersIDs(userID: uid) { (followersIDs) in
                self.followersIDs = followersIDs
            }
    }

}
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        postContentTV.text = ""
    }


}
