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
    let hello = 123

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser?.uid != nil {
            self.dismiss(animated: true, completion: nil)
            let EntryViewControllerrr = MainTabBarController()
            self.present(EntryViewControllerrr,animated: true,completion: nil)
         // self.navigationController?.pushViewController(EntryViewControllerrr, animated: true)
         
        }
    
    
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
