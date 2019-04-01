//
//  addEpisodeToPlaylist.swift
//  Podcast
//
//  Created by assem hakami on 25/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class addEpisodeToPlaylist: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var addEpisodeToPlaylistTable: UITableView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet weak var optionsButton: UIButton!
    
    var episodes: [Episode] = []
    var playlistName: String = ""
    
    @IBOutlet weak var playlistNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        addEpisodeToPlaylistTable.delegate = self
        addEpisodeToPlaylistTable.dataSource = self
        playlistNameLabel.text = playlistName        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //episodes = UserDefaults.standard.playlistEpisodes(name: playlistName)
        addEpisodeToPlaylistTable.reloadData()
        
        // if list is empty show the empty view
        if (episodes.count == 0){
            addEpisodeToPlaylistTable.backgroundView = emptyView
            optionsButton.isHidden = true
        }
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //var episodes = UserDefaults.standard.playlistEpisodes(name: self.playlistName)
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addEpisodeToPlaylistTable.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath) as! PlaylistCell
        //var episodes = UserDefaults.standard.playlistEpisodes(name: self.playlistName)
        cell.episode = episodes[indexPath.row]
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.episodes[indexPath.row].fileUrl != nil{
            clickToPlay()
        }
    }
        
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deletePlaylistEpisode(episode: episode, name: playlistName)
       
    }
    
    
    private func clickToPlay() {
        let indexPath = addEpisodeToPlaylistTable.indexPathForSelectedRow
        PlayerDetailsViewController.shared.setEpisode(episode: self.episodes[(indexPath?.row ?? nil)!])
    }
    
   
    
}
