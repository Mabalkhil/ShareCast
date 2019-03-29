//
//  BellController.swift
//  Podcast
//
//  Created by assem hakami on 21/07/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit


extension Date {
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
}

class BellController: UITableViewController {

    let dbs = DBService.shared
    var channelBell = [Podcast]()
    var episodes = [Episode]()
    
    
    @IBOutlet var BellView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserBell()
         self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        BellView.register(nib, forCellReuseIdentifier: "cellId")
        BellView.delegate = self
        BellView.dataSource = self
    }

    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BellCell", for: indexPath) as! BellCell
        cell.setAttributes(episode: self.episodes[indexPath.row])
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.episodes[indexPath.row].fileUrl != nil{
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        BellView.reloadData()
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bellToEpisode" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! EpisodeViewController
                // dont assign value directly because the destinition view visual component not created yet
                destination.episode = episodes[indexPath.row]
            }
        }
    }
    
    
    
    func fetchUserBell(){
        dbs.getBellChannels {
            podcasts in
            if podcasts.count != 0{
                for ch in podcasts{
                    self.fetchEpisode(podcast: ch)
                }
            }
            DispatchQueue.main.async {
                self.BellView.reloadData()
            }
        }
      
    }
    
    
    fileprivate func fetchEpisode(podcast: Podcast){
        guard let feedURL = podcast.feedUrl else {
            return
        }
        APIService.shared.fetchEpisodes(feedUrl: feedURL) { (e) in
            for ep in e {
                if ep.pubDate > Date().dayBefore{
                    self.episodes.append(ep)
                }
            }
            DispatchQueue.main.async {
                self.BellView.reloadData()
            }
        }
    }
    
    
}
