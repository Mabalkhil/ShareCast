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
    var episodes: [Episode] = []
    var check = true
    var episode: Episode? = nil
    
    
    
    @IBOutlet var createPlaylistTable: UITableView!
    @IBOutlet weak var playlistTextField: UITextField!
    

    
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
        temp = Playlist(playlistName:playlistTextField.text!,numberOfEpisodes:"0",episodes:episodes)
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
        
        cell.playlists = self.playlists[indexPath.row]
        if check == false {
            cell.playlists.episodes?.append(self.episode!)
        }
            
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var segue: String!
        if check == true {
            segue = "segue1"
            //print("????????????????????????????????")
             self.performSegue(withIdentifier: segue, sender: self)
        } else  {
            //print(self.episode)
            self.playlists[indexPath.row].episodes?.append(self.episode!)
            print(self.playlists[indexPath.row].episodes![0])
            //UserDefaults.standard.episodeArray(episode: self.episode!)
            print(self.playlists[indexPath.row].playlistName)
            //print(self.playlists[indexPath.row].episodes!)
            print("----------------------------------------")
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue1" {
            if let indexPath = createPlaylistTable.indexPathForSelectedRow {
                let destination = segue.destination as! addEpisodeToPlaylist
                destination.playlistNameLabel?.text = playlists[indexPath.row].playlistName
                //destination.playlist = playlists[indexPath.row]
                //destination.episodes = playlists[indexPath.row].episodes!
            }
        }
    }
    
    
}
