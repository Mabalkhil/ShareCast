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
        print("look here")
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
    
  
 
}
