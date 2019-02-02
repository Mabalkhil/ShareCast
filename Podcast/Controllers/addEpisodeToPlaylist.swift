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
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
       
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("a")
        if segue.identifier == "playlistEpisode" {
            print("b")
            if let indexPath = addEpisodeToPlaylistTable.indexPathForSelectedRow {
                print("c")
                let destination = segue.destination as! PlayerDetailsViewController
                // dont assign value directly because the destinition view visual component not created yet
                destination.episode = episodes[indexPath.row]
                print(destination.episode.title)
            }
        }
    }
    
    
   
    
}
