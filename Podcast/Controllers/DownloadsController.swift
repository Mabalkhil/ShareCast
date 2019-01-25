//
//  DownloadsController.swift
//  Podcast
//
//  Created by assem hakami on 16/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class DownloadsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tablwViewDownload: UITableView!
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    var myIndex = 0
    
    override func viewDidLoad() {
     
        tablwViewDownload.delegate = self
        tablwViewDownload.dataSource = self
        
        super.viewDidLoad()
        
        
        //setupTableView()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return episodes.count
    }
    
   
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! DownloadEpisodeCell
        
        cell.episode = self.episodes[indexPath.row]
        
        return cell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        present( UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "playerStoryBoard") as UIViewController, animated: true, completion: nil)
        
       //UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerStoryBoard")
        // UIApplication.mainTabBarController().max
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         episodes = UserDefaults.standard.downloadedEpisodes()
        tablwViewDownload.reloadData()
        
    }
    
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteEpisode(episode: episode)
    }
    
    
    
    
    //MARK:- Setup
    
    fileprivate func setupTableView(){
    
        
    
}

}
