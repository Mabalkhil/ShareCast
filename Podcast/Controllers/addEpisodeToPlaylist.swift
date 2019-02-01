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
    var episodes:[Episode]!
    

    @IBOutlet weak var playlistNameLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEpisodeToPlaylistTable.delegate = self
        addEpisodeToPlaylistTable.dataSource = self
       
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addEpisodeToPlaylistTable.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath) as! PlaylistCell
        
        cell.episode = self.episodes[indexPath.row]
        
        return cell
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
