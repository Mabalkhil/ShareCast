//
//  MainTabController.swift
//  Podcast
//
//  Created by MacBook on 02/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//
// notes
import UIKit


class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor(red: 236/255, green: 98/277, blue: 95/255, alpha: 1.0)
        tabBar.barTintColor = UIColor(red: 47/255, green:47/255, blue:47/255, alpha: 1.0)
        setupViewControllers()
        
        
        
    }
    //MARK: Setup Function
    fileprivate func setupViewControllers() {
        
        
        let homeNavController =
            generateNavigationController(for: ViewController(), title: "Home" , image: #imageLiteral(resourceName: "Home-1"))
        let searchNavController =
            generateNavigationController(for: PodcastSearchController(), title: "Discover" , image: #imageLiteral(resourceName: "Discover"))
        let chanellesController =
            generateNavigationController(for: UIStoryboard(name: "Subscription", bundle: nil).instantiateViewController(withIdentifier: "Download1"), title: "Subscription", image: #imageLiteral(resourceName: "Chanelles"))
        let ProfileController =
            generateNavigationController(for: ViewController(), title: "Profile", image: #imageLiteral(resourceName: "Profile-1"))
        
        
        viewControllers = [
            homeNavController,searchNavController,chanellesController , ProfileController
        ]
    }
    //MARK:- Helper Function
    
    fileprivate func generateNavigationController
    (for rootViewController: UIViewController ,title: String, image: UIImage)-> UIViewController {
    let navController =
    UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.navigationBar.barTintColor = UIColor(red: 47/255, green:47/255, blue:47/255, alpha: 1.0)
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        // navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem.image = image
    return navController
    
    }

}
