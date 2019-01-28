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

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    @IBAction func SaveProfileChanges(_ sender: Any) {
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
