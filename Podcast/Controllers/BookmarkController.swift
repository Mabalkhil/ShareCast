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
            clickToPlay()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookedMarked = UserDefaults.standard.bookmarkedEpisodes()
        bookmarks.reloadData()
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.bookedMarked[indexPath.row]
        bookedMarked.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteBookmarkedEpisode(episode: episode)
    }
    
    
    private func clickToPlay() {
        let indexPath = bookmarks.indexPathForSelectedRow
        PlayerDetailsViewController.shared.setEpisode(episode: self.bookedMarked[(indexPath?.row ?? nil)!])
    }
}
