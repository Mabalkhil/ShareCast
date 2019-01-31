//
//  CreatePlaylistController.swift
//  Podcast
//
//  Created by assem hakami on 24/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class CreatePlaylistController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    var playlists = UserDefaults.standard.playlistsArray()
    
    
    @IBOutlet var createPlaylistTable: UITableView!
    @IBOutlet weak var playlistTextField: UITextField!
    
 
  
    
    // playlistName
   // numberOfEpisodes
    
    
    
    override func viewDidLoad() {
    
          super.viewDidLoad()
        createPlaylistTable.delegate = self
        createPlaylistTable.dataSource = self
    }
    
    
    
    @IBOutlet weak var createPlaylistButton: RoundedWhiteButton!{
        
        didSet{
           createPlaylistButton.addTarget(self, action: #selector(addPlaylist), for: .touchUpInside)
        }
    }
    
    
    
    @objc func addPlaylist(){
        
       var temp: Playlist
         temp = Playlist(playlistName:playlistTextField.text!,numberOfEpisodes:"0")
        playlists.append(temp)
        UserDefaults.standard.playlistArray(playlist: temp)
        
        let indexPath = IndexPath(row: playlists.count-1, section: 0)
   
        createPlaylistTable.beginUpdates()
        createPlaylistTable.insertRows(at: [indexPath], with: .automatic)
        createPlaylistTable.endUpdates()
        
        playlistTextField.text = ""
        view.endEditing(true)
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = createPlaylistTable.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistsCell
        
        cell.playlist = self.playlists[indexPath.row]
        return cell
       
    }
    
    
    
}
