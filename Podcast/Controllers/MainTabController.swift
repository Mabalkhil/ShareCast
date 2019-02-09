//
//  MainTabController.swift
//  Podcast
//
//  Created by MacBook on 02/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//
// notes
import UIKit
import Firebase


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
            generateNavigationController(for: UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "discover"), title: "Discover" , image: #imageLiteral(resourceName: "Discover"))
        
        let chanellesController =
            generateNavigationController(for: UIStoryboard(name: "Subscription", bundle: nil).instantiateViewController(withIdentifier: "Download1"), title: "Subscription", image: #imageLiteral(resourceName: "Chanelles"))
        
        
        
        

        
        
        var ProfileController : UIViewController?
        if(Auth.auth().currentUser?.uid != nil){
            let ProfileStoryRef = UIStoryboard(name: "Profile", bundle: Bundle.main)
            guard let ProfileViewController = ProfileStoryRef.instantiateInitialViewController() as?
                ProfileViewController else {
                    return
            }
             ProfileController =
                generateNavigationController(for: ProfileViewController, title: "Profile", image: #imageLiteral(resourceName: "Profile-1"))
        }
        else{
            let MainStoryRef = UIStoryboard(name: "Main", bundle: Bundle.main)
            let EntryViewController = MainStoryRef.instantiateViewController(withIdentifier: "ProfileSigninView")
             ProfileController =
                generateNavigationController(for: EntryViewController, title: "Profile", image: #imageLiteral(resourceName: "Profile-1"))
        }
        
        
        
        viewControllers = [
            homeNavController,searchNavController,chanellesController , ProfileController
            ] as! [UIViewController]
    
        
    
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
