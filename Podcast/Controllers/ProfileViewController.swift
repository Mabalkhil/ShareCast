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

    // variables
    var profileInfo : ProfileView!
    let reffStor = Storage.storage().reference(forURL: "gs://sharecast-c780f.appspot.com").child("profile_Image")
    let uid = Auth.auth().currentUser?.uid
    var posts = [Post]()
    let chache = NSCache<NSString,UIImage>()
    let dbs = DBService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if uid != nil {
        setUpProfilePic()
        }
        
        privateTimeline.delegate = self
        privateTimeline.dataSource = self
        loadData()
        checkForUpdate()
    }
    
    func setUpProfilePic(){
        let chacheKey = reffStor.child("\(self.uid!).png").fullPath as NSString
        if let cachedImage = chache.object(forKey: chacheKey) {
            self.ProfileImage.image = cachedImage
        }else{
            
            dbs.fetchProfileImage { (image) in
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
        dbs.loadProfilePosts {
            (posts) in
            self.posts = posts
            DispatchQueue.main.async {
                self.privateTimeline.reloadData()
            }
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
        privateTimeline.reloadData()
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
        let chacheKey = reffStor.child("\(self.uid!).png").fullPath as NSString
        print(chacheKey)
        print(compressedImage)
        chache.setObject(compressedImage!, forKey: chacheKey)
        dbs.setProfileImage(uploadData: uploadData)
        
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
}
