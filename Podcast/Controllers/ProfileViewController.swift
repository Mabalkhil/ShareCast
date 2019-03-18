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
    let reffDtatabase = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var posts = [Post]()
    var db = Firestore.firestore()
    let chache = NSCache<NSString,UIImage>()
    
    
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
        reffDtatabase.child("usersInfo").child(uid!).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let profileUrl = dictionary["profileImageURL"] as? String
                if profileUrl != nil{
                        let url = URL(string: profileUrl!)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if let err = error {
                                print(err)
                            }
                            DispatchQueue.main.async {
                            self.ProfileImage.image = UIImage(data: data!)
                        }
                        }).resume()
                }
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
        let userID = Auth.auth().currentUser?.uid
        db.collection("private_timelines")
            .document(userID!)
            .collection("timeline").order(by: "Date", descending: true)
            .getDocuments(){
                QuerySnapshot, error in
                if let error = error {
                    print("\(error.localizedDescription)")
                }else{
                    //whereField("uid", isEqualTo: userID)
                    self.posts = (QuerySnapshot?.documents
                        .flatMap({
                            Post(userName: $0.data()["author"] as! String,
                                 content: $0.data()["content"] as! String,
                                 img: $0.data()["author_img"] as! String,
                                 ep_name: $0.data()["episode_name"] as! String,
                                 ep_img: $0.data()["episode_img_link"] as! String,
                                 ep_desc: $0.data()["episode_desc"] as! String,
                                 dateID: $0.data()["Date"] as! Date,
                                 postID: $0.documentID as! String)}))!
                    DispatchQueue.main.async {
                        self.privateTimeline.reloadData()
                    }
                }
        }
    }
    
    func checkForUpdate() {
        let userID = Auth.auth().currentUser?.uid
        db.collection("private_timelines")
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
                                dateID: DocumentChange.document.data()["Date"] as! Date,
                                postID: DocumentChange.document.documentID as! String), at: 0)
                            DispatchQueue.main.async {
                                self.privateTimeline.reloadData()
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
        let cell = privateTimeline.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! TimelineTVC
        cell.setAttributes(post: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let post_id = self.posts[indexPath.row].post_id
        let epName = self.posts[indexPath.row].episode_name
        let dateID = self.posts[indexPath.row].date
        
        let userID = Auth.auth().currentUser?.uid
        print("--------------------")
        print(epName!)
        db.collection("general_timelines")
            .document(userID!)
            .collection("timeline").whereField("episode_name", isEqualTo: epName!).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete()
                        print("Document successfully removed!")
                    }
                }
        }

        db.collection("private_timelines")
            .document(userID!)
            .collection("timeline").document(post_id!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    
                    self.privateTimeline.reloadData()
                }
        }
        privateTimeline.reloadData()
        viewDidLoad()
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
        let chacheKey = reffStor.child("\(self.uid!).png").fullPath as NSString
        print(chacheKey)
        print(compressedImage)
        chache.setObject(compressedImage!, forKey: chacheKey)
        
        reffStor.child("\(self.uid!).png").putData(uploadData, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err)
                return
            }
            self.reffStor.child("\(self.uid!).png").downloadURL(completion: { (url, error) in
                if let err = error {
                    print(err)
                }else{
                    self.reffDtatabase.child("usersInfo").child(self.uid!).updateChildValues(["profileImgaeURL":url?.absoluteString])
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
}
