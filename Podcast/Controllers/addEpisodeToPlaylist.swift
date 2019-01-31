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
    var episodes: [Episode] = []
    
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
    
    
   
    
}
