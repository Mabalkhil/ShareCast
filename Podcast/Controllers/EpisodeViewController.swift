//
//  ViewController.swift
//  Zoo App
//
//  Created by Mazen.A on 1/10/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit

class EpisodeViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var tableViewComments: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeImage: UIImageView!
     @IBOutlet weak var titleLabel: UILabel!
    
   
    @IBOutlet weak var downloadButton: UIButton!{
        didSet{
            downloadButton.addTarget(self, action: #selector(downloadHandler), for: .touchUpInside)
        }
    }
    
    @objc func downloadHandler(){
        UserDefaults.standard.downloadEpisode(episode: episode.self)
        APIService.shared.downloadEpisode(episode: episode.self)
    }
    
    
    var comments = [CommentObj]()
    var episode = Episode()
    
    override func viewDidLoad() {

        setAttributes()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // this piece of shit is to fix the episode description problem
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellAnimal:Comment = tableView.dequeueReusableCell(withIdentifier: "Comment", for: indexPath) as! Comment
        
        cellAnimal.setComment(comment: comments[indexPath.row])
        
        return cellAnimal
    }
    
    func setAttributes(){
        descriptionLabel.text = episode.describtion
        titleLabel.text = episode.title
        guard let url = URL(string: episode.imageUrl ?? "") else {return}
        episodeImage.sd_setImage(with: url)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "player" {
            let destinationController = segue.destination as! PlayerDetailsViewController
            destinationController.episode = self.episode
        }
    }
    
    
}

