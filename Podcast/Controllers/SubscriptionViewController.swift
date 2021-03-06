
import UIKit

class SubscriptionViewController: UITableViewController {
    
    @IBOutlet var subscriptions: UITableView!
    
    var subscriptionsList = [Podcast]() //FETCHSUB //UserDefaults.standard.bookmarkedEpisodes()
    
    //For testing this is list of feed urls
    var feedUrls = ["https://spitballers.libsyn.com/comedypodcast","https://rss.art19.com/comedy-bang-bang",
                    "https://feeds.megaphone.fm/the-daily-show"]
    
 
    
    var myIndex = 0
    
    
    override func viewDidLoad() {
        subscriptions.delegate = self
        subscriptions.dataSource = self
        APIService.shared.fetchChannels(feedUrls: feedUrls) { (podcasts) in
            self.subscriptionsList = podcasts
        }
        super.viewDidLoad()
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
        subscriptionsList = [Podcast]() //FETCHSUB UserDefaults.standard.bookmarkedEpisodes()
        subscriptions.reloadData()
        
    }
    
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let podcast = self.subscriptionsList[indexPath.row]
//        subscriptionsList.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//        //FETCHSUB here should be the unsubscribe part
//        //        UserDefaults.standard.deleteBookmarkedEpisode(episode: episode)
//
//    }
    

}
