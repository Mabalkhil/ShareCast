//
//  ProfileViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/23/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var ProfileImage: UIImageView!

    // variables
    var profileInfo : ProfileView!
    let reffStor = Storage.storage().reference(forURL: "gs://sharecast-c780f.appspot.com").child("profile_Image")
    let reffDtatabase = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    let chache = NSCache<NSString,UIImage>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if uid != nil {
        setUpProfilePic()
        }
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.borderColor = UIColor.white.cgColor
        ProfileImage.layer.masksToBounds = false
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true
        ProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfile)))
        ProfileImage.isUserInteractionEnabled = true
        
    }
    
    func setUpProfilePic(){
        let chacheKey = reffStor.child("\(self.uid!).png").fullPath as NSString
        if let cachedImage = chache.object(forKey: chacheKey) {
            self.ProfileImage.image = cachedImage
        }else{
        reffDtatabase.child("usersInfo").child(uid!).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let profileUrl = dictionary["profileImageURL"] as? String
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
        ProfileImage.image = seletedImage
        guard let uploadData = seletedImage.jpeg(.lowest) else {
            return
        }
        // cahching the image
        let chacheKey = reffStor.child("\(self.uid!).png").fullPath as NSString
        print(chacheKey)
        print(seletedImage)
        chache.setObject(seletedImage, forKey: chacheKey)
        
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
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}
