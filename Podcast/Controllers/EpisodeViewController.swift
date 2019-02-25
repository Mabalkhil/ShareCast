//
//  ViewController.swift
//  ShareCast
//
//  Created by Mazen.A on 1/10/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class EpisodeViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableViewComments: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var playlistsCV: UICollectionView!
    
    
    var comments = [CommentObj]()
    var episode = Episode()
    let blackView = UIView()
    var playlists = UserDefaults.standard.playlistsArray()
    
    var fireStoreDatabaseRef = Firestore.firestore()
    var databaseRef = DatabaseReference.init()
    var userID:String?
    var username:String?
    var userImage:String?
    
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
    
    override func viewDidLoad() {
        setAttributes()
        super.viewDidLoad()
        
        playlistsCV.delegate = self
        playlistsCV.dataSource = self
        let index = playlists.count
        playlists.insert(Playlist(name: "Cancel", epis_list: []), at: index)
        
        setUpDatabases()
        
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
    
    @objc func downloadHandler(){
        UserDefaults.standard.downloadEpisode(episode: episode.self)
        APIService.shared.downloadEpisode(episode: episode.self)
        //downloadButton.setImage(#imageLiteral(resourceName: "download_Done"), for: .normal)
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
    
    @objc func repostHandler(){
        let postDetails = ["uid" : userID,
                           "author": username,
                           "author_img":userImage,
                           "content" : "Right now it's nothing :)",
                           "Date" : Date(),
                           "episode_link" : episode.fileUrl,
                           "episode_img_link" : episode.imageUrl,
                           "episode_name" : episode.title,
                           "episode_desc" : episode.describtion] as [String : Any]
        
        var ref:DocumentReference? = nil
                ref = self.fireStoreDatabaseRef.collection("Posts").addDocument(data: postDetails){
                    error in
        
                    if let error = error {
                        print("Error adding document \(error)")
                    }else{
                        print("Document inserted successfully with ID: \(ref!.documentID)")
                        self.databaseRef.child("Timeline").child(self.userID!).childByAutoId().setValue("\(ref!.documentID)")
                    }
                }
        
        ref = self.fireStoreDatabaseRef
            .collection("all_timelines")
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
        
        self.dismiss(animated: true, completion: nil)
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
    }
}

