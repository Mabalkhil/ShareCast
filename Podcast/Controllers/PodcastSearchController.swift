//
//  PodcastSearchController.swift
//  Podcast
//
//  Created by MacBook on 03/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import Alamofire

class PodcastSearchController: UITableViewController, UISearchBarDelegate{
    // state variables
    let cellId = "cellId"
    var podcasts = [Podcast]()
    // Implement SearchBar Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    //Search result table
    let resultTableView: UITableView! = UITableView()
    
    //list of categories from the API and variable to reuse collection cells
    let categories = [Category]()
    var storedOffsets = [Int: CGFloat]()
    
    //delegate for the search table results
    var searchDelegate = SearchDelegate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupSearchTable()
        setupSearchBar()

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
            self.searchDelegate.updatePodcasts(podcasts: self.podcasts)
            self.resultTableView.reloadData()
        }
        if searchText.count == 0{
            self.podcasts.removeAll()
            self.resultTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.podcasts.removeAll()
        self.searchDelegate.updatePodcasts(podcasts: self.podcasts)
        self.resultTableView.reloadData()
        self.resultTableView.removeFromSuperview()

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addSubview(resultTableView)
    }
    
    
    
    // Adding cells step.1: register a cell for tableview
    //MARK:- Setup Work
    //MARK:- UITableView
    fileprivate func setupSearchTable(){
        //OMITTED: UITableViewCell registration
        
        self.searchDelegate.setData(podcasts: self.podcasts, id: self.cellId, nav: navigationController!)
        resultTableView.delegate = searchDelegate
        resultTableView.dataSource = searchDelegate
        
        self.definesPresentationContext = true // This will add navigation header for every controller you move to
        resultTableView.tableFooterView = UIView() // removes table lines
        self.resultTableView.backgroundColor =  UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        resultTableView.register(nib, forCellReuseIdentifier: cellId)
        
        resultTableView.frame = self.view.frame
        //resultTableView.tag = 010
        
    }
    
    // These two functions are for the defualt table which is the category table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryList", for: indexPath) as! DiscoverTableCell
        return cell
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? DiscoverTableCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        tableViewCell.categoryCollectionOffset = storedOffsets[indexPath.row] ?? 0
    }
    
   func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? DiscoverTableCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.categoryCollectionOffset
    }

}




//MARK:- Collection View
extension PodcastSearchController: UICollectionViewDelegate, UICollectionViewDataSource{

   func setupCollectionView(){
        self.definesPresentationContext = true // This will add navigation header for every controller you move to
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return categories[collectionView.tag].podcasts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCell

        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let channelStoryboard = UIStoryboard(name: "Channel", bundle: Bundle.main)
        guard let destinationViewController = channelStoryboard.instantiateInitialViewController() as?
            ChannelController else {
                return
        }
        let podcast = self.podcasts[indexPath.row]
        destinationViewController.podcast = podcast
        navigationController?.pushViewController(destinationViewController, animated: true)

    }


}



