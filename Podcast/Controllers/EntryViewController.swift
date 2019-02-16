//
//  EntryViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/17/18.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import  Firebase

class EntryViewController: UIViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser?.uid != nil {
            let MainViewController = MainTabBarController()
            self.dismiss(animated: true, completion: nil)
            self.present(MainViewController,animated: true,completion: nil)
        }
    }
    
    @IBAction func skipButton(_ sender: Any) {
        let MainViewController = MainTabBarController()
        self.dismiss(animated: true, completion: nil)
        self.present(MainViewController,animated: true,completion: nil)
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
