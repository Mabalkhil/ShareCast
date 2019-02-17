//
//  DiscoverTables.swift
//  Podcast
//
//  Created by Khaled H on 31/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

//MARK:- Search Table Delegate
class SearchDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var podcasts = [Podcast]()
    var cellId: String!
    var navController: UINavigationController!
    
    func setData(podcasts:[Podcast], id:String, nav:UINavigationController) {
        self.podcasts = podcasts
        self.cellId = id
        self.navController = nav
    }
    
    func updatePodcasts(podcasts:[Podcast]) {
        self.podcasts = podcasts
    }
    
    
    // Adding cells step.2: Determain the number of raws
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    // Adding cells step.3: Define the dequeue cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    //MARK:- Header settings
    //The header will be the label shown before the user searchs for something
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please Enter a search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        return label
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //This method returns the hight of the header, will return 0 if there're cells in the table
        return podcasts.count > 0 ? 0 : 250
    }
    
    //MARK:- Selection actions for Search
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channelStoryboard = UIStoryboard(name: "Channel", bundle: Bundle.main)
        guard let destinationViewController = channelStoryboard.instantiateInitialViewController() as?
            ChannelController else {
                return
        }
        let podcast = self.podcasts[indexPath.row]
        destinationViewController.podcast = podcast
        navController?.pushViewController(destinationViewController, animated: true)
        
    }
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

