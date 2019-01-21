//
//  EpisodesController.swift
//  PodcastApp
//
//  Created by asim hakami on 16/03/1440 AH.
//  Copyright © 1440 assem hakami. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    var tableViewTest: UITableView!
    

    var podcast: Podcast?{
        didSet{
            navigationItem.title = podcast?.trackName
            fetchEpisode()
            
        }
    }
    
    
    
    
    fileprivate func fetchEpisode(){
        guard let feedURL = podcast?.feedUrl else { return }
        print("The is the RSS")
        print(feedURL)
        
        APIService.shared.fetchEpisodes(feedUrl: feedURL) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
    fileprivate let cellId = "cellId"
    
    var episodes = [Episode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1.0)
        setupTableView()
    }
    
    //MARK:- setup table
    
    fileprivate func setupTableView(){
        // tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
//        tableViewTest = UINib(nibName: "ChannelView", bundle: nil) as! UITableView
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        //tableView.tableFooterView = UIView() // remove table lines
    }
    
    
    //MARK:- UITableView
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        
        let window = UIApplication.shared.keyWindow
        
        let playerDetailsView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
        playerDetailsView.episode = episode
    
        playerDetailsView.frame = self.view.frame
        window?.addSubview(playerDetailsView)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    
}
