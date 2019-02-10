//
//  EditProfileViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/26/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UITableViewController {
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            let origImage = UIImage(named: "save");
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            saveButton.setImage(tintedImage, for: .normal)
            saveButton.tintColor = UIColor.white
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet{
            let origImage = UIImage(named: "close");
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cancelButton.setImage(tintedImage, for: .normal)
            cancelButton.tintColor = UIColor.white
        }
    }
    
    let databaseReff = Database.database().reference().child("usersInfo")
    let uid = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent;
    }

    // MARK: - Table view data source

    @IBAction func SaveProfileChanges(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let username = usernameText.text else { return }
        guard let firstName = firstNameText.text else { return }
        guard let lastName = lastNameText.text else { return }
        
        if usernameText.text != "" {
            if username.isValidName{
                 databaseReff.child(uid).updateChildValues(["username" : "@\(username)"])
            }else{
                let alert = UIAlertController(title: "Inalid username", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Try Again", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert,animated: true,completion: nil)
            }
        }
        if firstNameText.text != "" {
            databaseReff.child(uid).updateChildValues(["firstName" : firstName]) }
        if lastNameText.text != "" {
            databaseReff.child(uid).updateChildValues(["lastName" : lastName]) }
        
        self.dismiss(animated: true, completion: nil)
  
    }
    @IBAction func backToProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch  {
            let alertView = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertView.addAction(alertAction)
            present(alertView,animated: true,completion: nil)
            
            return
        }
        // move to the main view
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let EntryViewController = storyboard.instantiateViewController(withIdentifier: "Entry") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = EntryViewController
        self.dismiss(animated: true, completion: nil)
        
        
    }
}
