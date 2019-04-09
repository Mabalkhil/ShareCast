//
//  PodcastSearchController.swift
//  Podcast
//
//  Created by MacBook on 03/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PodcastSearchController: UITableViewController, UISearchBarDelegate{
    
    //DBS reference
    let dbs = DBService.shared
    
    // state variables
    let cellId = "cellId"
    let cellId2 = "cellId2"
    var podcasts = [Podcast]()
    // Implement SearchBar Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    //Search result table
    let resultTableView: UITableView! = UITableView()
    
    //list of categories from the API and variable to reuse collection cells
    var categories = [Category]()
    var storedOffsets = [Int: CGFloat]()
    
    //delegate for the search table results
    var searchDelegate = SearchDelegate()
    
    //users list
    var people = [Person]()
    
    
    //for the link
    var selectedscope: String?
    
    
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
        searchController.searchBar.tintColor = UIColor.white
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        //adding scope buttons to the search
        searchController.searchBar.scopeButtonTitles = ["Channels", "People", "Link"]
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
            self.people.removeAll()
            self.searchDelegate.updatePeople(people: self.people)
            self.resultTableView.reloadData()
        } else {
            
            //for users
            self.people.removeAll()

            Database.database().reference().child("usersInfo").queryOrdered(byChild: "searchName").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased() + "\u{f8ff}").observe(.childAdded) {
                    (snapshot) in
                    if let dict = snapshot.value as? [String: AnyObject]{

                        let person = Person(uid: snapshot.key, dictionary: dict)
                        self.people.append(person!)

                        self.searchDelegate.updatePeople(people: self.people)
                        self.resultTableView.reloadData()
                }
            }
        }
       
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.podcasts.removeAll()
        self.people.removeAll()
        self.searchDelegate.updatePodcasts(podcasts: self.podcasts)
        self.searchDelegate.updatePeople(people: self.people)
        self.resultTableView.reloadData()
        self.resultTableView.removeFromSuperview()

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addSubview(resultTableView)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBar.scopeButtonTitles! [selectedScope] != "Link" {
            self.searchDelegate.searchScope = searchBar.scopeButtonTitles! [selectedScope]
            self.resultTableView.reloadData()
        }
        self.selectedscope = searchBar.scopeButtonTitles! [selectedScope]
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if selectedscope == "Link" {
            let link = searchBar.text ?? ""
            guard let start = link.range(of: "Chennel:")?.upperBound else{ self.linkAlert()
                return
            }
            let mid = link.range(of: ":Episode:")?.lowerBound
            let end = link.range(of: ":Episode:")?.upperBound
            
            APIService.shared.fetchEpisodes(feedUrl: String(link[start..<mid!])) { (Episodes) in
                
                if Episodes.isEmpty {
                    self.linkAlert()
                    return
                }
                
                
                var ep: Episode?
                for episode in Episodes{
                    
                    if episode.streamURL ==  link[end!...] {
                        ep = episode
                        break
                    }
                   
                }
                
                if ep == nil{
                    self.linkAlert()
                    return
                }
                
                DispatchQueue.main.async {
                    let episodeStoryboard = UIStoryboard(name: "Episode", bundle: Bundle.main)
                    guard let destinationViewController = episodeStoryboard.instantiateInitialViewController() as?
                        EpisodeViewController else {
                            return
                    }
                    destinationViewController.episode = (ep ?? nil)!
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                }

            }

        }
    }
    
    
    private func linkAlert(){
        let alert = UIAlertController(title: "Wrong Link", message: "Please Enter a Correct Link", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    // Adding cells step.1: register a cell for tableview
    //MARK:- Setup Work
    //MARK:- UITableView
    fileprivate func setupSearchTable(){
        //OMITTED: UITableViewCell registration
        
        resultTableView.delegate = searchDelegate
        resultTableView.dataSource = searchDelegate
        self.searchDelegate.setData(podcasts: self.podcasts, people: self.people, id: self.cellId, nav: navigationController!)
        
        self.definesPresentationContext = true // This will add navigation header for every controller you move to
        resultTableView.tableFooterView = UIView() // removes table lines
        self.resultTableView.backgroundColor =  UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        //let nib2 = UINib(nibName: "PeopleCell", bundle: nil)
        resultTableView.register(nib, forCellReuseIdentifier: cellId)
        //resultTableView.register(nib2, forCellReuseIdentifier: cellId)
        
        resultTableView.frame = self.view.frame
        //resultTableView.tag = 010
        
    }
    
    
    
    // These two functions are for the defualt table which is the category table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! DiscoverTableCell
        
        cell.categoryTitle.text = categories[indexPath.row].title
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

}




//MARK:- Collection View
extension PodcastSearchController: UICollectionViewDelegate, UICollectionViewDataSource{

   func setupCollectionView(){
    
        APIService.shared.fetchDiscover() { (categories) in
            self.categories = categories
            self.tableView.reloadData()
        
        }
    
        self.definesPresentationContext = true // This will add navigation header for every controller you move to
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[collectionView.tag].podcasts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCell
        
        let category = categories[collectionView.tag].podcasts
        cell.podcast = category[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let channelStoryboard = UIStoryboard(name: "Channel", bundle: Bundle.main)
        guard let destinationViewController = channelStoryboard.instantiateInitialViewController() as?
            ChannelController else {
                return
        }
        let category = categories[collectionView.tag].podcasts
        destinationViewController.podcast = category[indexPath.row]
        navigationController?.pushViewController(destinationViewController, animated: true)

    }


}



