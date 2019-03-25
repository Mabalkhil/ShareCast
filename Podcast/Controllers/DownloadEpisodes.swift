//
//  DownloadEpisodes.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 3/24/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class DownloadEpisodes: UITableViewController {
    
 var episodes = UserDefaults.standard.downloadedEpisodes()
    @IBOutlet var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if (episodes.count == 0){
            tableView.backgroundView = emptyView
        }else {
            tableView.backgroundView = UIView()
        }
        setupObservers()
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[2]
            tabItem.badgeValue = nil
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
        viewDidLoad()
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return episodes.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.episodes[indexPath.row].fileUrl != nil{
            clickToPlay() // Start playing the selected episode
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! DownloadEpisodeCell
        cell.setDownloadEpisode(episode: self.episodes[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteEpisode(episode: episode)
        APIService.shared.deleteEpisode(episode: episode)
        viewDidLoad()
    }

    fileprivate func setupObservers(){
        NotificationCenter.default.addObserver( self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc fileprivate func handleDownloadComplete(notification: Notification){
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else{ return }
        
        guard let index = self.episodes.index(where: { $0.title == episodeDownloadComplete.episodeTitle }) else { return }
        self.episodes[index].fileUrl = episodeDownloadComplete.fileURL
    }
    
    
    @objc fileprivate func handleDownloadProgress(notification: Notification){
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        
        guard let index = self.episodes.index(where: { $0.title == title }) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row:index,section:0)) as? DownloadEpisodeCell else{ return }
        cell.downloadProgress.progress = Float(progress)
        cell.downloadProgress.isHidden = false
        if progress == 1{
            cell.downloadProgress.isHidden = true
        }
    }
    
    private func clickToPlay() {
        let indexPath = tableView.indexPathForSelectedRow
        PlayerDetailsViewController.shared.setEpisode(episode: self.episodes[(indexPath?.row ?? nil)!])
    }
    

    
}
