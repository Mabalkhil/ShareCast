//
//  DownloadsController.swift
//  Podcast
//
//  Created by assem hakami on 16/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class MentionsController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[2]
            tabItem.badgeValue = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
