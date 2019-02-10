
import UIKit

class SubscriptionViewController: UITableViewController {
    
    @IBOutlet var subscriptions: UITableView!
    
     //FETCHSUB //UserDefaults.standard.bookmarkedEpisodes()
    var subscriptionsList : [Podcast] = [Podcast(trackName: "BOBO", artistName: "BABA", artworkUrl600: "https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/ce/67/b2/ce67b29f-d606-345d-654e-f84d71454b85/source/600x600bb.jpg", trackCount: 50, feedUrl: "https://fnjan.fireside.fm/rss")]
    //For testing this is list of feed urls
    var feedUrls = ["https://spitballers.libsyn.com/comedypodcast","https://rss.art19.com/comedy-bang-bang",
                    "https://feeds.megaphone.fm/the-daily-show"]
    
    
    var myIndex = 0
    
    
    override func viewDidLoad() {
        setupTable()
        
        super.viewDidLoad()
    }
    
    
    fileprivate func setupTable(){
        subscriptions.delegate = self
        subscriptions.dataSource = self
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        subscriptions.register(nib, forCellReuseIdentifier: "cellId")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptionsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell", for: indexPath) as! PodcastCell
        
        cell.podcast = subscriptionsList[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.subscriptionsList[indexPath.row].feedUrl != nil{
            
            performSegue(withIdentifier: "player", sender: self)
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        APIService.shared.fetchChannels(feedUrls: feedUrls) { (podcasts) in
//            self.subscriptionsList = podcasts
//        }
        
        subscriptions.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let podcast = self.subscriptionsList[indexPath.row]
        subscriptionsList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        //FETCHSUB here should be the unsubscribe part
        //        UserDefaults.standard.deleteBookmarkedEpisode(episode: episode)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        //        if segue.identifier == "player" {
        //            if let indexPath = subscriptions.indexPathForSelectedRow {
        //                let destination = segue.destination as! PlayerDetailsViewController
        //                // dont assign value directly because the destinition view visual component not created yet
        //                destination.episode = subscriptionsList[indexPath.row]
        //                print(destination.episode.title)
        //
        //            }
        //        }
    }
}
