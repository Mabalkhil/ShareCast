import UIKit
import Firebase

class MentionController: UITableViewController{
    
    let dbs = DBService.shared
    var mentionedPost = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMentionedEpisodes()
        tableView.delegate = self
        tableView.dataSource = self
      
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(mentionedPost.count)
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
}
