//
//  CreatePlaylistController.swift
//  Podcast
//
//  Created by assem hakami on 24/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//  Created by Mazen.A on 1/30/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit


    var playlists = UserDefaults.standard.playlistsArray()
class CreatePlaylistController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent;
    }
    
    @IBOutlet weak var createPlaylistButton: RoundedWhiteButton!{
        
        didSet{
           createPlaylistButton.addTarget(self, action: #selector(addPlaylist), for: .touchUpInside)
        }
    }
    
    @objc func addPlaylist(){
        
       var temp: Playlist
        temp = Playlist(playlistName:playlistTextField.text!,numberOfEpisodes:"0",episodes:episodes)
        
        if playlists.isEmpty {
            playlists.append(temp)
            UserDefaults.standard.playlistArray(playlist: temp)
             let indexPath = IndexPath(row: playlists.count-1, section: 0)
            createPlaylistTable.beginUpdates()
            createPlaylistTable.insertRows(at: [indexPath], with: .automatic)
            createPlaylistTable.endUpdates()
        } else {
            if !playlists.contains(where: { $0.playlistName == temp.playlistName }) {
                playlists.append(temp)
                UserDefaults.standard.playlistArray(playlist: temp)
                 let indexPath = IndexPath(row: playlists.count-1, section: 0)
                createPlaylistTable.beginUpdates()
                createPlaylistTable.insertRows(at: [indexPath], with: .automatic)
                createPlaylistTable.endUpdates()
            }
        }
        
        playlistTextField.text = ""
        view.endEditing(true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = createPlaylistTable.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistsCell
        
        cell.playlists = playlists[indexPath.row]
        let x : Int = playlists[indexPath.row].episodes.count
        let myString = String(x)
        cell.playlists.numberOfEpisodes = myString
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var segue: String!
        if check == true {
            segue = "fromPlaylistsToPlaylist"
        } else {
            playlists[indexPath.row].addTask(ep: self.episode!,i: indexPath.row)
            UserDefaults.standard.playlistEpisode(episode: self.episode!, name: playlists[indexPath.row].playlistName!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        playlists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deletePlaylist(playlist: playlist)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromPlaylistsToPlaylist" {
            if let indexPath = createPlaylistTable.indexPathForSelectedRow {
                let destination = segue.destination as! addEpisodeToPlaylist
                destination.playlistName = playlists[indexPath.row].playlistName!
                destination.episodes = UserDefaults.standard.playlistEpisodes(name: playlists[indexPath.row].playlistName!)
            }
        }
    }
}
