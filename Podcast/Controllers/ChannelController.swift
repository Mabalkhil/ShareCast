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
            fetchEpisode()
            navigationItem.title = podcast?.trackName
          
        }
    }
    let dbs = DBService.shared
    var firebaseReff = Auth.auth().currentUser
    var alert: UIAlertController!
    var alertAction: UIAlertAction!
    
    
    fileprivate func fetchEpisode(){
        guard let feedURL = podcast?.feedUrl else {
            return
        }

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

        self.dbs.checkSubscribestion(podcast: podcast!) {
            (exists) in
            if exists {
                self.headerView.SubButton.setTitle("Unsubscribe", for: .normal)
            } else {
                self.headerView.SubButton.setTitle("Subscribe", for: .normal)
            }
        }

    }
    
    
    func checkUserBell(){
        guard let uid = firebaseReff?.uid else {
            headerView.BellButton.setTitle("Bell", for: .normal)
            return
        }
        
        self.dbs.checkBell(podcast: podcast!) {
            (exists) in
            if exists {
                self.headerView.BellButton.setTitle("Unbell", for: .normal)
                self.headerView.BellButton.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
            } else {
                self.headerView.BellButton.setTitle("Bell", for: .normal)
                self.headerView.BellButton.tintColor = UIColor.white
            }
        }
    }
    
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
         //Configure the table view
         checkUserSubscriptions()
         checkUserBell()

      
        guard let url = URL(string : podcast?.artworkUrl600 ?? "") else {return}
        headerView.chennelImage.sd_setImage(with: url, completed: nil)
        headerView.nameLabel.text = podcast?.trackName
        headerView.typeLabel.text = podcast?.artistName
        
        
     //   headerView.headerImageView.image = UIImage(named: restaurant.image)
 
        
        headerView.SubButton.layer.borderWidth = 2.0;
        headerView.SubButton.layer.borderColor = UIColor.white.cgColor
        headerView.SubButton.layer.cornerRadius = 5
        headerView.SubButton.clipsToBounds = true
        
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

    // when a segue triggred  and before the visual transition occure
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEpisodeDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! EpisodeViewController
                // dont assign value directly because the destinition view visual component not created yet
                destination.episode = episodes[indexPath.row]
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

        if headerView.SubButton.currentTitle! == "Subscribe" {
            dbs.subscribeToChannel(podcast: podcast!)
            headerView.SubButton.setTitle("Unsubscribe", for: .normal)
        }else {
            self.alert = UIAlertController(title: "Are you sure you want to Unsubscribe", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.dbs.unsubscribeToChannel(podcast: self.podcast!)
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
    
    
    @IBAction func BellButton(_ sender: Any) {
        
        // unregister user
        guard  let uid = firebaseReff?.uid else {
            self.alert = UIAlertController(title: "Not Register", message: "You have to register to get this feature", preferredStyle: .alert)
            self.alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            self.alert.addAction( self.alertAction)
            present(self.alert,animated: true,completion: nil)
            return
        }
        
        if headerView.BellButton.currentTitle == "Bell" {
            dbs.bellAChannel(podcast: podcast!)
            headerView.BellButton.setTitle("Unbell", for: .normal)
            self.headerView.BellButton.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        }else {
            self.alert = UIAlertController(title: "Are you sure you want to unbell", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.dbs.unBellAChannel(podcast: self.podcast!)
                self.headerView.BellButton.setTitle("Bell", for: .normal)
                self.headerView.BellButton.tintColor = UIColor.white
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
