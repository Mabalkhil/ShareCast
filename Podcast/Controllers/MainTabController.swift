//
//  MainTabController.swift
//  Podcast
//
//  Created by MacBook on 02/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .red
        setupViewControllers()
        

    }
    //MARK: Setup Function
    fileprivate func setupViewControllers() {
        let favoritesNavController =
            generateNavigationController(for: ViewController(), title: "Favorites" , image: #imageLiteral(resourceName: "favorites"))
        let searchNavController =
            generateNavigationController(for: PodcastSearchController(), title: "Search" , image: #imageLiteral(resourceName: "search"))
        let downloadsController =
            generateNavigationController(for: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        
        
        viewControllers = [
            searchNavController
//            ,
//            favoritesNavController,
//            downloadsController
        ]
    }
    //MARK:- Helper Function
    
    fileprivate func generateNavigationController
    (for rootViewController: UIViewController ,title: String, image: UIImage)-> UIViewController {
    let navController =
    UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem.image = image
    return navController
    
    }

}
