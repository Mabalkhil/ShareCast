//
//  EntryViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/17/18.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

    
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func skipToMainView(_ sender: Any) {
        let main = MainTabBarController()
        self.present(main, animated: true, completion: nil)
       
    }
}
