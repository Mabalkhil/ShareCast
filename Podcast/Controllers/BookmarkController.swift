//
//  BookmarkController.swift
//  Podcast
//
//  Created by Mazen.A on 1/30/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class BookmarkController: UITableViewController {
    
    @IBOutlet var bookmarks: UITableView!
    
    var bookedMarked = UserDefaults.standard.bookmarkedEpisodes()
    var myIndex = 0
    
    
    override func viewDidLoad() {
        
        bookmarks.delegate = self
        bookmarks.dataSource = self
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookedMarked.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as! BookmarkCell
        
        cell.setAttributes(episode: self.bookedMarked[indexPath.row])
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.bookedMarked[indexPath.row].fileUrl != nil{
            
            performSegue(withIdentifier: "player", sender: self)
        }
        
        
        // print(self.episodes[indexPath.row])
        
//         present( UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "playerStoryBoard") as UIViewController, animated: true, completion: nil)
//
//        UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerStoryBoard")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookedMarked = UserDefaults.standard.bookmarkedEpisodes()
        bookmarks.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.bookedMarked[indexPath.row]
        bookedMarked.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteBookmarkedEpisode(episode: episode)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "player" {
            if let indexPath = bookmarks.indexPathForSelectedRow {
                let destination = segue.destination as! PlayerDetailsViewController
                // dont assign value directly because the destinition view visual component not created yet
                destination.episode = bookedMarked[indexPath.row]
                print(destination.episode.title)
                
            }
        }
    }
}
