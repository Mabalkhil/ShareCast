//
//  ChannelController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 1/16/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase

class ChannelController:  UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: ChannelHeaderView!
    
    
    ////// Episode Stuff
    var podcast: Podcast?{
        didSet{
            navigationItem.title = podcast?.trackName
            fetchEpisode()
        }
    }
    var firebaseReff = Auth.auth().currentUser
    var firebaseSubReff = Database.database().reference().child("usersInfo")
    var alert: UIAlertController!
    var alertAction: UIAlertAction!
    
    
    fileprivate func fetchEpisode(){
        guard let feedURL = podcast?.feedUrl else { return }
        print("The is the RSS")
        print(feedURL)
        
        APIService.shared.fetchEpisodes(feedUrl: feedURL) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func checkUserSubscriptions(){
        guard let uid = firebaseReff?.uid else {
            self.headerView.SubButton.setTitle("Subscribe", for: .normal)
            return
        }
        self.firebaseSubReff.child(uid).child("Subscription").observeSingleEvent(of: .value) { (snapshot) in
            var exist = false
            for case let rest as DataSnapshot in snapshot.children {
                let url = rest.value as! String
                if url == self.podcast?.feedUrl {
                    exist = true
                    print(1)
                    break
                }
            }
            if exist {
                self.headerView.SubButton.setTitle("Unsubscribe", for: .normal)
            } else {
                self.headerView.SubButton.setTitle("Subscribe", for: .normal)
            }
        }
    }
    
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserSubscriptions()
        fetchEpisode()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    
         //Configure the table view
        tableView.delegate = self
        tableView.dataSource = self

        // Configure header view
        guard let url = URL(string : podcast?.artworkUrl600 ?? "") else {return}
        headerView.chennelImage.sd_setImage(with: url, completed: nil)
        headerView.nameLabel.text = podcast?.trackName
        headerView.typeLabel.text = podcast?.artistName
      
        
     //   headerView.headerImageView.image = UIImage(named: restaurant.image)
 
        
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return episodes.count
      
    }
        // Filling the TableViewCell
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChennelTableViewCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
      
       
        return cell
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // when a segue triggred  and before the visual transition occure
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEpisodeDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! EpisodeViewController
                // dont assign value directly because the destinition view visual component not created yet
                destination.episode = episodes[indexPath.row]
                print(destination.episode.title)
                
            }
        }
    }
    
    @IBAction func SubscribePressed(_ sender: Any) {
        // unregister user
        guard  let uid = firebaseReff?.uid else {
           self.alert = UIAlertController(title: "Not Register", message: "You have to register to get this feature", preferredStyle: .alert)
         self.alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            self.alert.addAction( self.alertAction)
           present(self.alert,animated: true,completion: nil)
            return
        }
        //
         guard var chanelTitle = podcast?.trackName  else{
            return
        }
            chanelTitle = chanelTitle.replacingOccurrences(of: ".", with: " ")
            chanelTitle =  chanelTitle.replacingOccurrences(of: "]", with: " ")
            chanelTitle =  chanelTitle.replacingOccurrences(of: "[", with: " ")
            chanelTitle = chanelTitle.replacingOccurrences(of: "#", with: " ")
            chanelTitle = chanelTitle.replacingOccurrences(of: "$", with: " ")
        
        guard let chanellUrl = podcast?.feedUrl else {
            return
        }
        if headerView.SubButton.currentTitle! == "Subscribe" {
            print("Look Here\(chanelTitle)")
            firebaseSubReff.child(uid).child("Subscription").updateChildValues([chanelTitle : chanellUrl])
            headerView.SubButton.setTitle("Unsubscribe", for: .normal)
        }else {
            self.alert = UIAlertController(title: "Are you sure you want to Unsubscribe", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.firebaseSubReff.child(uid).child("Subscription").child(chanelTitle).removeValue()
                self.headerView.SubButton.setTitle("Subscribe", for: .normal)
                return
            })
            self.alertAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            self.alert.addAction(self.alertAction)
             self.alert.addAction(yesAction)
            present(self.alert,animated: true,completion: nil)
            return

        }
        
    }
    
    
    
}
