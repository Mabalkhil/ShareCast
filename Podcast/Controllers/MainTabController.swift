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
    var MaximumSize:NSLayoutConstraint! = nil
    var MinimumSize:NSLayoutConstraint! = nil
    let playerDetailsview = PlayerDetailsViewController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(red: 236/255, green: 98/277, blue: 95/255, alpha: 1.0)
        tabBar.barTintColor = UIColor(red: 47/255, green:47/255, blue:47/255, alpha: 1.0)
        setupViewControllers()
        setUpPlayerDetailsview()
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
        navController.tabBarItem.image = image
        return navController
    }
    
    @objc func minimizePlayerDetails(){
        MaximumSize.isActive = false
        MinimumSize.isActive = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
        })
        self.playerDetailsview.smallPlayer.isHidden = false
        self.playerDetailsview.bigPlayer.isHidden = true
    }
    
    // this method will take the episode from anywhere
    @objc func maximizePlayerDetails(){
        MaximumSize.isActive = true
        MaximumSize.constant = 0
        MinimumSize.isActive = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
        })
        
        self.playerDetailsview.smallPlayer.isHidden = true
        self.playerDetailsview.bigPlayer.isHidden = false
        
    }
    
    fileprivate func setUpPlayerDetailsview(){
        view.insertSubview(playerDetailsview.view!, belowSubview: tabBar)
        playerDetailsview.view?.translatesAutoresizingMaskIntoConstraints = false
        MaximumSize = playerDetailsview.view?.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        MaximumSize.isActive = true
        MinimumSize = playerDetailsview.view?.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -65)
        playerDetailsview.view?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsview.view?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playerDetailsview.view?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.playerDetailsview.bigPlayer.isHidden = true
    }
}
