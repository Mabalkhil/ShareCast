//
//  ChannelController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/16/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class ChannelController:  UIViewController , UITableViewDelegate , UITableViewDataSource{
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: ChannelHeaderView!
    
    
    ////// Episode Stuff
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
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEpisode()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    
         //Configure the table view
        tableView.delegate = self
        tableView.dataSource = self

        // Configure header view
        guard let url = URL(string : podcast?.artworkUrl600 ?? "") else {return}
        headerView.chennelImage.sd_setImage(with: url, completed: nil)
        headerView.nameLabel.text = podcast?.trackName
        headerView.typeLabel.text = podcast?.artistName
      
        
     //   headerView.headerImageView.image = UIImage(named: restaurant.image)
 
        
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return episodes.count
      
    }
        // Filling the TableViewCell
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChennelTableViewCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
      
       
        return cell
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // when a segue triggred  and before the visual transition occure
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEpisodeDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! EpisodeViewController
                // dont assign value directly because the destinition view visual component not created yet
                destination.episode = episodes[indexPath.row]
                print(destination.episode.title)
                
            }
        }
    }
    
}
