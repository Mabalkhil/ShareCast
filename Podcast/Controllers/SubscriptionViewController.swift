////
////  SubscriptionViewController.swift
////  Podcast
////
////  Created by MacBook on 07/02/2019.
////  Copyright © 2019 MacBook. All rights reserved.
////
//
//import UIKit
//
//class SubscriptionViewController : UITableViewController{
//    let cellId = "cellId"
//    var podcasts = [Podcast]()
//    var podcastsTableView =  UITableView()
//
//    override func viewDidLoad() {
//        setupTable()
//    }
//
//    fileprivate func setupTable(){
//
//    }
//
//
//    // Setup :- UITableViewC
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return podcasts.count
//    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "podcast", for: indexPath) as! PodcastCell
//
//        cell.podcast = podcasts[indexPath.row]
////        cell.categoryTitle.text = categories[indexPath.row].title
////        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
//
//        return cell
//    }
//}
//
//
//

//
//  BookmarkController.swift
//  Podcast
//
//  Created by Mazen.A on 1/30/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class SubscriptionViewController: UITableViewController {
    
    @IBOutlet var subscriptions: UITableView!
    
    var subscriptionsList = [Podcast]() //FETCHSUB //UserDefaults.standard.bookmarkedEpisodes()
    var myIndex = 0
    
    
    override func viewDidLoad() {
        
        subscriptions.delegate = self
        subscriptions.dataSource = self
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptionsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell", for: indexPath) as! PodcastCell
        
        cell.podcast = subscriptionsList[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.subscriptionsList[indexPath.row].fileUrl != nil{
            
            performSegue(withIdentifier: "player", sender: self)
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscriptionsList = [Podcast]() //FETCHSUB UserDefaults.standard.bookmarkedEpisodes()
        subscriptions.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let podcast = self.subscriptionsList[indexPath.row]
        subscriptionsList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        //FETCHSUB here should be the unsubscribe part
//        UserDefaults.standard.deleteBookmarkedEpisode(episode: episode)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "player" {
//            if let indexPath = subscriptions.indexPathForSelectedRow {
//                let destination = segue.destination as! PlayerDetailsViewController
//                // dont assign value directly because the destinition view visual component not created yet
//                destination.episode = subscriptionsList[indexPath.row]
//                print(destination.episode.title)
//
//            }
//        }
    }
}
