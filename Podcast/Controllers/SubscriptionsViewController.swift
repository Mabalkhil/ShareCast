//
//  SubscriptionsViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 2/16/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

extension Date {
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -30, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
}


class SubscriptionsViewController: UITableViewController {
    let dbs = DBService.shared
    var channelSub = [Podcast]()
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserSubs()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cellId")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.separatorStyle = .singleLine
        print("-------------------------")
        fetchEpisode(podcast: channelSub[0])
        
        for ep in episodes {
            print(ep.title)
        }
        
        
        //        print("-------------------------------")
        //                print(Date().dayBefore)
        //                for ep in episodes {
        //                    if ep.pubDate > Date().dayBefore{
        //
        //                        print(ep.title)
        //                        print(ep.pubDate)
        //                        print("-----------")
        //                    }
        //                }
    }
    
    
    
    fileprivate func fetchEpisode(podcast: Podcast){
        guard let feedURL = podcast.feedUrl else {
            return
        }
        print("looooooooooook heeeeerrrr\(feedURL)")
        APIService.shared.fetchEpisodes(feedUrl: feedURL) { (e) in
            
                            for ep in e {
                                if ep.pubDate > Date().dayBefore{
                                   self.episodes.append(ep)
                                }
                            }
           
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showChannel", sender: nil)
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChannel" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! ChannelController
                // dont assign value directly because the destinition view visual component not created yet
                destination.podcast = self.channelSub[indexPath.row]
                
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channelSub.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! PodcastCell
        let channel = channelSub[indexPath.row]
        cell.podcast = channel
        return cell
    }
    
    func fetchUserSubs(){
        dbs.getSubscriptions {
            podcasts in
            self.channelSub = podcasts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

