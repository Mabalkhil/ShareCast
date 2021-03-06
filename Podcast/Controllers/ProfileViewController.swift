//
//  ProfileViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/23/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var privateTimeline: UITableView!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var postsLabel: UIButton!
    @IBOutlet weak var followingLabel: UIButton!
    @IBOutlet weak var followersLabel: UIButton!
    

    // variables
    var profileInfo : ProfileView!
    var followersIDs = [String]()
    var followingIDs = [String]()
    let reffStor = Storage.storage().reference(forURL: "gs://sharecast-c780f.appspot.com").child("profile_Image")
    let uid = Auth.auth().currentUser?.uid ?? ""
    var posts = [Post]()
    let chache = NSCache<NSString,UIImage>()
    let dbs = DBService.shared
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if uid != nil {
        setUpProfilePic()
        }
        
        privateTimeline.delegate = self
        privateTimeline.dataSource = self
        checkForUpdate()
        loadData()
        
        privateTimeline.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: "refreshHandler", for: UIControl.Event.valueChanged)
    }
    
    func setUpProfilePic(){
        let chacheKey = reffStor.child("\(self.uid).png").fullPath as NSString
        if let cachedImage = chache.object(forKey: chacheKey) {
            self.ProfileImage.image = cachedImage
        }else{
            
            dbs.fetchProfileImage(targetID: self.uid) { (image) in
                DispatchQueue.main.async {
                self.ProfileImage.image = image
                }
            }
            
        }
        
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.borderColor = UIColor.white.cgColor
        ProfileImage.layer.masksToBounds = false
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true
        ProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfile)))
        ProfileImage.isUserInteractionEnabled = true
    }
    
    func loadData() {
        dbs.loadProfilePosts(targetID: uid) {
            (posts) in
            self.posts = posts
            self.postsLabel.setTitle("\(self.posts.count)", for: UIControl.State.normal)
            DispatchQueue.main.async {
                self.privateTimeline.reloadData()
            }
        }
        
        dbs.getFollowersIDs(userID: uid) { (result) in
            self.followersIDs = result
            self.followersLabel.setTitle("\(self.followersIDs.count)", for: UIControl.State.normal)
        }
        
        dbs.getFollowingIDs(userID: uid) { (result) in
            self.followingIDs = result
            self.followingLabel.setTitle("\(self.followingIDs.count)", for: UIControl.State.normal)
        }
    }
    
    func checkForUpdate() {
        dbs.updateProfilePosts { (posts) in
            self.posts.append(contentsOf: posts)
            DispatchQueue.main.async {
                self.privateTimeline.reloadData()
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = privateTimeline.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! TimelineTVC
        cell.setAttributes(post: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let postId = self.posts[indexPath.row].post_id
        self.dbs.deletePost(postId: postId!)
        posts.remove(at: indexPath.row)
        privateTimeline.deleteRows(at: [indexPath], with: .automatic)
        //viewDidLoad()
        privateTimeline.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func handleSelectProfile() {
        let picker = UIImagePickerController()
            picker.delegate = self
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        var selectedImageFromPicker: UIImage?
        if let editingImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editingImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             selectedImageFromPicker = originalImage
        }
        guard let seletedImage = selectedImageFromPicker else {
            return
        }
        
        let compressedImage = resizeImage(image: seletedImage, newWidth: 250)
        ProfileImage.image = compressedImage
        guard let uploadData = compressedImage!.jpeg(.lowest) else {
            return
        }
        // cahching the image
        let chacheKey = reffStor.child("\(self.uid).png").fullPath as NSString
        //print(chacheKey)
        //print(compressedImage)
        chache.setObject(compressedImage!, forKey: chacheKey)
        dbs.setProfileImage(uploadData: uploadData)

        reffStor.child("\(self.uid).png").putData(uploadData, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err)
                return
            }
            self.reffStor.child("\(self.uid).png").downloadURL(completion: { (url, error) in
                if let err = error {
                    print(err)
                }else{ // fireStire code should be here 
//self.reffDtatabase.child("usersInfo").child(self.uid!).updateChildValues(["profileImgaeURL":url?.absoluteString])
                }
            })
        }
    picker.dismiss(animated: true, completion: nil)

    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let newHeight = newWidth
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func refreshHandler() {
        loadData()
        //checkForUpdate()
        self.refreshControl.endRefreshing()
    }
    
    // when a segue triggred  and before the visual transition occure
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEpisodeDetails" {
            if let indexPath = privateTimeline.indexPathForSelectedRow {
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
                episode.channelURL = posts[indexPath.row].channel_url
                
                destination.episode = episode
                print(self.posts[indexPath.row].episode_author)
                
            }
        }
    }
    
    
    
    
    
    
    
}
