//
//  ProfileViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/23/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        // Do any additional setup after loading the view.
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
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let EntryViewController = storyboard.instantiateViewController(withIdentifier: "Entry")
            UIApplication.shared.keyWindow?.rootViewController = EntryViewController
        self.dismiss(animated: true, completion: nil)
        
     
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
