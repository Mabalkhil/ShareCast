//
//  SubscriptionViewController.swift
//  Podcast
//
//  Created by MacBook on 07/02/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class SubscriptionViewController : UITableViewController{
    let cellId = "cellId"
    var podcasts = [Podcast]()
    var podcastsTableView =  UITableView()
    
    override func viewDidLoad() {
        setupTable()
    }
    
    fileprivate func setupTable(){
        
    }
    
    
    // Setup :- UITableViewC
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "podcast", for: indexPath) as! PodcastCell
        
        cell.podcast = podcasts[indexPath.row]
//        cell.categoryTitle.text = categories[indexPath.row].title
//        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        
        return cell
    }
}



