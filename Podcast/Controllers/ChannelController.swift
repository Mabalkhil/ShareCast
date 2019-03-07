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
    var firebaseReff = Auth.auth().currentUser
    var firebaseSubReff = Database.database().reference().child("usersInfo")
    let db = Firestore.firestore()
    var alert: UIAlertController!
    var alertAction: UIAlertAction!
    
    
    fileprivate func fetchEpisode(){
        guard let feedURL = podcast?.feedUrl else {
            return
        }
        print("looooooooooook heeeeerrrr\(feedURL)")
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
        
        //Realtime
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
        //Firebase
        self.db.collection("usersInfo").document(uid).collection("Subscriptions")
            .document((podcast?.feedUrl)!).getDocument { (document, error) in
                if let document = document, document.exists {
                    print("Podcast is Subscriped data: \(self.podcast?.trackName ?? "NO NAME")")
                    self.headerView.SubButton.setTitle("Unsubscribe", for: .normal)

                } else {
                    print("Podcast is not Subscriped data: \(self.podcast?.trackName ?? "NO NAME")")
                    self.headerView.SubButton.setTitle("Subscribe", for: .normal)

                }
        }
    }
    
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    
         //Configure the table view
         checkUserSubscriptions()

        print("HHHHHHEEEEEERRRRRREEE \(podcast?.feedUrl)")
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
            
            //Realtime
            firebaseSubReff.child(uid).child("Subscription").updateChildValues([chanelTitle : chanellUrl])
            //Firestore
            self.db.collection("usersInfo").document(uid).collection("Subscriptions")
                .document((podcast?.feedUrl)!).setData((podcast?.dictionary)!)
            //
            headerView.SubButton.setTitle("Unsubscribe", for: .normal)
        }else {
            self.alert = UIAlertController(title: "Are you sure you want to Unsubscribe", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //Realtime
                self.firebaseSubReff.child(uid).child("Subscription").child(chanelTitle).removeValue()
                //Firestore
                self.db.collection("usersInfo").document(uid).collection("Subscriptions")
                    .document((self.podcast?.feedUrl)!).delete()
                //
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
