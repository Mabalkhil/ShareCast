
import UIKit

class SubscriptionViewController: UITableViewController {
    
    @IBOutlet var subscriptions: UITableView!
    
     //FETCHSUB //UserDefaults.standard.bookmarkedEpisodes()
    var subscriptionsList : [Podcast] =
        [   Podcast(trackName: "فنجان", artistName: "ثمانية", artworkUrl600: "https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/ce/67/b2/ce67b29f-d606-345d-654e-f84d71454b85/source/600x600bb.jpg", trackCount: 50, feedUrl: "https://fnjan.fireside.fm/rss"),
            Podcast(trackName: "ثمانية ¾ مع سعود العود", artistName: "ثمانية", artworkUrl600: "https://is4-ssl.mzstatic.com/image/thumb/Music118/v4/23/f0/0c/23f00ca4-1fb1-6769-c527-3d6b4f4ef83e/source/600x600bb.jpg", trackCount: 50, feedUrl: "https://thmanyah34.fireside.fm/rss"),
            Podcast(trackName: "Radiolab", artistName: "WNPR", artworkUrl600: "https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/42/8a/28/428a28a2-ebcb-da74-3b73-1def5509f6b4/source/600x600bb.jpg", trackCount: 50, feedUrl: "http://feeds.wnyc.org/radiolab")
    ]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! PodcastCell
        
        cell.podcast = subscriptionsList[indexPath.row]
        
        return cell
    }
    
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        if self.subscriptionsList[indexPath.row].feedUrl != nil{
//            
//            performSegue(withIdentifier: "player", sender: self)
//        }
//        
//        
//    }
    
    
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 160.0;//Choose your custom row height
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
    
    
//    func tableView(_ tableView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let channelStoryboard = UIStoryboard(name: "Channel", bundle: Bundle.main)
//        guard let destinationViewController = channelStoryboard.instantiateInitialViewController() as?
//            ChannelController else {
//                return
//        }
//        let category = categories[collectionView.tag].podcasts
//        destinationViewController.podcast = category[indexPath.row]
//        navigationController?.pushViewController(destinationViewController, animated: true)
//
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channelStoryboard = UIStoryboard(name: "Channel", bundle: Bundle.main)
        guard let destinationViewController = channelStoryboard.instantiateInitialViewController() as?
                    ChannelController else {
                        return
                }
        destinationViewController.podcast = subscriptionsList[indexPath.row]
        navigationController?.pushViewController(destinationViewController, animated: true)
        
    }

}
