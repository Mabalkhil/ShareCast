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
    var people = [Person]()
    var cellId: String!
    //var cellId2: String! = "cellId2"
    var navController: UINavigationController!
    
    var searchScope: String! = "Channels"
    
    
    func setData(podcasts:[Podcast], people:[Person], id:String, nav:UINavigationController) {
        self.podcasts = podcasts
        self.people = people
        self.cellId = id
        self.navController = nav
    }
    
    func updatePodcasts(podcasts:[Podcast]) {
        self.podcasts = podcasts
    }
    
    func updatePeople(people:[Person]){
        self.people = people
    }
    
    
    // Adding cells step.2: Determain the number of raws
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchScope == "Channels" {
            return podcasts.count
            
        } else {
            return people.count
        }
        
    }
    
    // Adding cells step.3: Define the dequeue cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchScope == "Channels" {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
            let podcast = podcasts[indexPath.row]
            cell.podcast = podcast
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
            let person = people[indexPath.row]
            cell.person = person
            return cell
        }
        
        
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
        if searchScope == "Channels" {
            return podcasts.count > 0 ? 0 : 250
        } else {
            
            return people.count > 0 ? 0 : 250
        }
        
    }
    
    //MARK:- Selection actions for Search
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchScope == "Channels" {
            
            let channelStoryboard = UIStoryboard(name: "Channel", bundle: Bundle.main)
            guard let destinationViewController = channelStoryboard.instantiateInitialViewController() as?
                ChannelController else {
                    return
            }
            let podcast = self.podcasts[indexPath.row]
            destinationViewController.podcast = podcast
            navController?.pushViewController(destinationViewController, animated: true)
        } else {
            
            let userProfileStoryboard = UIStoryboard(name: "UsersProfile", bundle: Bundle.main)
            guard let destinationViewController = userProfileStoryboard.instantiateInitialViewController() as?
                UsersProfileController else {
                    return
            }
            let person = self.people[indexPath.row]
            destinationViewController.person = person
            navController?.pushViewController(destinationViewController, animated: true)
        }
        
        
    }
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

