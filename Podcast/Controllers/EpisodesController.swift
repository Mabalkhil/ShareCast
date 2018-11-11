//
//  Episodes.swift
//  Podcast
//
//  Created by MacBook on 09/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import FeedKit
class EpisodesController: UITableViewController {
    let cellId = "cellId"
    var episodes = [Episode]()
    var podcast: Podcast? {
        didSet{
            navigationItem.title = podcast?.trackName
            fetchEpisode()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    //MARK:- Episode
    fileprivate func fetchEpisode(){
        
        guard let feedUrl =  podcast?.feedUrl else {return}
        //feed url might not contain secure protocol (HTTPS)
        //which might be blocked. so we insert it
        let secureFeedUrl = feedUrl.contains("https") ? feedUrl :
            feedUrl.replacingOccurrences(of: "http", with: "https")
        print("Looking for episode from feed: ", secureFeedUrl )

        
        guard let url = URL(string: secureFeedUrl) else {return}
        let parser = FeedParser(URL: url)
        
        parser.parseAsync(result: { (result) in
            print("Parsing Done:", result.isSuccess)
            switch result {
            case let .rss(feed):
                var episodes = [Episode]()
                feed.items?.forEach({ (feedItem) in
                    let episode = Episode(title: feedItem.title ?? "")
                    episodes.append(episode)
                    
                })
                self.episodes = episodes
                DispatchQueue.main.async {
                    self.tableView.reloadData()

                }
                break

            case let .failure(error):
                print("Feed Parse Error: ", error)
                break
            default:
                print("Found Feed...")
                break
            }
            })
        
    }
    //MARK:- UITableView
    //MARK: Setup worl
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView() // removes table lines
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let episode = episodes[indexPath.row]
        cell.textLabel?.text = episode.title
        return cell
    }
    
    
    
    
    
    
    
    
    
    
}
