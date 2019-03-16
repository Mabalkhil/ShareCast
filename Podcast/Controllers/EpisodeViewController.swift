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
    @IBOutlet var writePost: UIView!
    @IBOutlet weak var postContentTV: UITextView!
    
    var comments = [CommentObj]()
    var followersIDs : [String] = []
    var episode = Episode()
    let blackView = UIView()
    var playlists = UserDefaults.standard.playlistsArray()
    
    var fireStoreDatabaseRef = Firestore.firestore()
    var fireBaseDatabaseRef = Database.database().reference()
    var databaseRef = DatabaseReference.init()
    var userID:String?
    var username:String?
    var userImage:String?
    var counter = 0
    var key = ""
    var exist = false
    var fileURL = ""
    
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
    
    @IBOutlet weak var rePostButton: UIButton!{
        didSet{
            rePostButton.addTarget(self, action: #selector(repostHandler), for: .touchUpInside)
        }
    }
    
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
        setAttributes()
        super.viewDidLoad()
       
        playlistsCV.delegate = self
        playlistsCV.dataSource = self
        postContentTV.delegate = self
        let index = playlists.count
        playlists.insert(Playlist(name: "Cancel", epis_list: []), at: index)
        
         fileURL = episode.fileUrl ?? ""
        if Auth.auth().currentUser?.uid != nil {
            setUpDatabases()
            checkLikedEpisode()
            checkEpisodeUrl()
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
    
    func checkLikedEpisode(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        fireBaseDatabaseRef.child("usersInfo").child(uid).child("Likes").observeSingleEvent(of: .value) { (snapshot) in
            for case let episodeUrl as DataSnapshot in snapshot.children {
                let url = episodeUrl.value as! String
                if(url == self.episode.fileUrl){
                    self.likeButton.setTitle("unlike", for: .normal )
                    self.likeButton.setImage(UIImage(named: "like_filled"), for: .normal)
                    break
                }
            }
        }
    }
    
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
    @IBAction func likePressed(_ sender: Any) {
        // check if the user register
        guard let uid = Auth.auth().currentUser?.uid else {
            let alert = UIAlertController(title: "Not Register", message: "You have to register to get this feature", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            present(alert,animated: true,completion: nil)
            return
        }
        
        if likeButton.titleLabel?.text == "like" {
            self.counter += 1
            fireBaseDatabaseRef.child("Episodes").child(self.key).child("counter").setValue(self.counter)
            fireBaseDatabaseRef.child("usersInfo").child(uid).child("Likes").child(self.key).setValue(self.fileURL)
            likeButton.setTitle("unlike", for: .normal )
            likeButton.setImage(UIImage(named: "like_filled"), for: .normal)
        }else{
            self.counter -= 1
            fireBaseDatabaseRef.child("Episodes").child(self.key).child("counter").setValue(self.counter)
            fireBaseDatabaseRef.child("usersInfo").child(uid).child("Likes").child(self.key).removeValue()
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
    
    @objc func createNewPost(){

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
        

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0.0
            self.writePost.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 200)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
            PlayerDetailsViewController.shared.view.isHidden = false
        }, completion: nil)
    }
    
    @objc func cancelNewPost(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0.0
            self.writePost.alpha = 0.0
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
            PlayerDetailsViewController.shared.view.isHidden = false
        }, completion: nil)
    }
    
    @objc func repostHandler(){
        
        guard (Auth.auth().currentUser?.uid) != nil else {
            let alert = UIAlertController(title: "Not Register", message: "You have to register to get this feature", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            present(alert,animated: true,completion: nil)
            return
        }
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0
        writePost.alpha = 0
        
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelDismiss)))
        
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
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playlistsCV.dequeueReusableCell(withReuseIdentifier: "playlist", for: indexPath) as! playlistCellAddingCVC
        cell.setAttributes(playlist: playlists[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if playlists[indexPath.row].playlistName != "Cancel"{
            playlists[indexPath.row].addTask(ep: self.episode)
            UserDefaults.standard.playlistEpisode(episode: self.episode, name: playlists[indexPath.row].playlistName!)
        }
        handelDismiss()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func setUpDatabases(){
        self.databaseRef = Database.database().reference()
        self.userID = Auth.auth().currentUser?.uid
        
        self.databaseRef.child("usersInfo").child(userID!).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                self.username = dictionary["username"] as? String
                self.userImage = dictionary["profileImgaeURL"] as? String
            }
        }
        
        
        databaseRef.child("usersInfo").child(userID!).child("Followers").observeSingleEvent(of: .value) { (snapshot) in
            for case let rest as DataSnapshot in snapshot.children {
                if((rest.value as! Int) == 1){
                    self.followersIDs.append(rest.key)
                    print(self.followersIDs)
                }
            }
            
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        postContentTV.text = ""
    }
}

