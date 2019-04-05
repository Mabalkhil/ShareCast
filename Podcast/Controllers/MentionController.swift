import UIKit
import Firebase

class MentionController: UITableViewController{
    
    let dbs = DBService.shared
    var mentionedPost = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser?.uid != nil {
            fetchMentionedEpisodes()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl!.addTarget(self, action: Selector("refreshHandler"), for: UIControl.Event.valueChanged)
      
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mentionedPost.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! TimelineTVC
        let post = mentionedPost[indexPath.row]
        print(post)
        cell.setMentionedEpisode(post: post)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let postId = self.mentionedPost[indexPath.row].post_id
        self.dbs.deleteMention(postId: postId!)
        tableView.reloadData()
        viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    func fetchMentionedEpisodes(){
        dbs.getMentionedEpisodes(completionHandler: { (post) in
            self.mentionedPost = post
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    
    // when a segue triggred  and before the visual transition occure
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEpisodeDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destination = segue.destination as! EpisodeViewController
                var episode = Episode()
                episode.describtion = mentionedPost[indexPath.row].episode_desc ?? ""
                episode.title = mentionedPost[indexPath.row].episode_name ?? ""
                episode.pubDate = mentionedPost[indexPath.row].episode_Date
                episode.streamURL = mentionedPost[indexPath.row].episode_streamURL
                episode.fileUrl = mentionedPost[indexPath.row].episode_FileUrl
                episode.imageUrl = mentionedPost[indexPath.row].episode_img_url
                episode.author = mentionedPost[indexPath.row].episode_author
                episode.timeStampLables = mentionedPost[indexPath.row].episode_timeStampLables
                episode.time =  mentionedPost[indexPath.row].episode_time
                episode.timeStamps = mentionedPost[indexPath.row].episode_timeStamps
                
                destination.episode = episode
                
            }
        }
    }
    
    
    
    @objc func refreshHandler() {
        // checkForUpdate()
       fetchMentionedEpisodes()
        self.refreshControl!.endRefreshing()
    }
    
    
    
}
