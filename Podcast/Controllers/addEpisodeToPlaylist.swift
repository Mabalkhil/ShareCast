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
   // var playlist:Playlist? = nil
     //var episodes = UserDefaults.standard.playlistEpisode()
    var episodes: [Episode] = []
    var playlistName: String = ""
    
    @IBOutlet weak var playlistNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        addEpisodeToPlaylistTable.delegate = self
        addEpisodeToPlaylistTable.dataSource = self
        playlistNameLabel.text = playlistName        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //episodes = UserDefaults.standard.playlistEpisodes(name: playlistName)
        addEpisodeToPlaylistTable.reloadData()
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
