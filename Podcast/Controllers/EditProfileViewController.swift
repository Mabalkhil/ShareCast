//
//  EditProfileViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/26/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
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
    let dbs = DBService.shared
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    @IBAction func SaveProfileChanges(_ sender: Any) {

        guard let username = usernameText.text else { return }
        guard let firstName = firstNameText.text else { return }
        guard let lastName = lastNameText.text else { return }
        var updatedUserInfo = [String: Any]()
        if usernameText.text != "" {
            if username.isValidName{
                updatedUserInfo["username"] = "@\(username)"
            }else{
                let alert = UIAlertController(title: "Inalid username", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Try Again", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert,animated: true,completion: nil)
            }
        }
        if firstNameText.text != "" {
            updatedUserInfo["firstName"] = firstName
            }
        if lastNameText.text != "" {
            updatedUserInfo["lastName"] = lastName
            }
        self.dbs.updateUserInfo(updatedInfo: updatedUserInfo)
        self.dismiss(animated: true, completion: nil)
  
    }
    @IBAction func backToProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func logout(_ sender: Any) {
        do {
            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]
                switch userInfo.providerID {
                case "google.com" :
                    GIDSignIn.sharedInstance()?.signOut()
                default:
                    break
                }
            }
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
