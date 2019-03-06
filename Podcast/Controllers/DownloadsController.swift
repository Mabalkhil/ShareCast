//
//  DownloadsController.swift
//  Podcast
//
//  Created by assem hakami on 16/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class DownloadsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tablwViewDownload: UITableView!
    @IBOutlet var emptyView: UIView!
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    var myIndex = 0

    
    override func viewDidLoad() {
        tablwViewDownload.delegate = self
        tablwViewDownload.dataSource = self
        super.viewDidLoad()
        if (episodes.count == 0){
            tablwViewDownload.backgroundView = emptyView
        }else {
            tablwViewDownload.backgroundView = UIView()
        }
        setupObservers()
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[2]
            tabItem.badgeValue = nil
        }
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
        guard let cell = tablwViewDownload.cellForRow(at: IndexPath(row:index,section:0)) as? DownloadEpisodeCell else{ return }
        cell.downloadProgress.progress = Float(progress)
        cell.downloadProgress.isHidden = false
        if progress == 1{
            cell.downloadProgress.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return episodes.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! DownloadEpisodeCell
        cell.setDownloadEpisode(episode: self.episodes[indexPath.row])
        return cell
    }
    
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.episodes[indexPath.row].fileUrl != nil{
            clickToPlay() // Start playing the selected episode 
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.downloadedEpisodes()
        tablwViewDownload.reloadData()
        viewDidLoad()
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteEpisode(episode: episode)
        APIService.shared.deleteEpisode(episode: episode)
        viewDidLoad()
    }
    
    private func clickToPlay() {
        let indexPath = tablwViewDownload.indexPathForSelectedRow
        PlayerDetailsViewController.shared.setEpisode(episode: self.episodes[(indexPath?.row ?? nil)!])
    }
    
}
