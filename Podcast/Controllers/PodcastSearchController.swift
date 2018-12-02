//
//  PodcastSearchController.swift
//  Podcast
//
//  Created by MacBook on 03/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import Alamofire

class PodcastSearchController: UITableViewController, UISearchBarDelegate {
    // state variables
    let cellId = "cellId"
    var podcasts = [Podcast]()
    // Implement SearchBar Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchBar()

    }
    // Adding cells step.1: register a cell for tableview
    //MARK:- Setup Work
    //MARK:- UITableView
    fileprivate func setupTableView(){
        //OMITTED: UITableViewCell registration
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        self.definesPresentationContext = true // This will add navigation header for every controller you move to
        tableView.tableFooterView = UIView() // removes table lines
        self.tableView.backgroundColor =  UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
       
    }
    // Adding cells step.2: Determain the number of raws
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    // Adding cells step.3: Define the dequeue cell content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        
        //OMITTED
//
//        cell.textLabel?.text = "\(podcast.trackName ?? "") \n \(podcast.artistName ?? "")"
//        cell.textLabel?.numberOfLines = -1 // for infinte number of lines
//        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
       return cell
    }
    //MARK:- Header settings
    //The header will be the label shown before the user searchs for something
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please Enter a search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white 
        return label
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //This method returns the hight of the header, will return 0 if there're cells in the table
        return podcasts.count > 0 ? 0 : 250
    }
    //MARK:- Selection actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        let podcast = self.podcasts[indexPath.row]
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
    //MARK:- Setup Work
    //MARK:- UISearchController
    fileprivate func setupSearchBar(){
        //SearchBar configurations
        //adding the searchbar
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
 
        searchController.searchBar.barStyle = .black
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    // executes whenever the text in the search bar changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        APIService.shared.fetchPodcast(searchText: searchText) { (podcasts) in
            self.podcasts = podcasts
            
            self.tableView.reloadData()
        }
        if searchText.count == 0{
            self.podcasts.removeAll()
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

}
