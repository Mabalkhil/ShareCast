//
//  SubscriptionsViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 2/16/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase
class SubscriptionsViewController: UITableViewController {
        let reff = Database.database().reference()
        var channels = [Podcast]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserSubs()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cellId")
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
         tableView.separatorStyle = .singleLine
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showChannel", sender: nil)
      
//        let channelStoryboard = UIStoryboard(name: "Channel", bundle: Bundle.main)
//        guard let destinationViewController = channelStoryboard.instantiateInitialViewController() as?
//            ChannelController else {
//                return
//        }
//        let podcast = self.channels[indexPath.row]
//        destinationViewController.podcast = podcast
//        navigationController?.pushViewController(destinationViewController, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChannel" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! ChannelController
                // dont assign value directly because the destinition view visual component not created yet
                destination.podcast = self.channels[indexPath.row]
              
                
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! PodcastCell
        let channel = channels[indexPath.row]
        cell.podcast = channel
        return cell
    }
        
    func fetchUserSubs(){
        guard let currUser = Auth.auth().currentUser?.uid else {
            return
        }
        print(currUser)
        var url = [String]()
         reff.child("usersInfo").child(currUser).child("Subscription").observeSingleEvent(of: .value) { (snapshot) in
            for case let urls as DataSnapshot in snapshot.children {
                 url.append(urls.value as! String)
                print(urls)
            }
            let apiObject = APIService.init()
            apiObject.fetchChannels(feedUrls: url, completionHandler: { (podcast) in
                self.channels = podcast
                print("sooooommthing here \(self.channels[0].artistName)" )
                 print("sooooommthing here \(self.channels[1].artistName)" )
                DispatchQueue.main.async {
                self.tableView.reloadData()
                }
                return
            })
        }
    }
    
}
