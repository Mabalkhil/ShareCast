import UIKit

class MentionController: UITableViewController{
    let dbs = DBService.shared
        let reff
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[2]
            tabItem.badgeValue = nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func fetchUserSubs(){
        dbs
        
        
//        dbs. {
//            podcasts in
//            self.channelSub = podcasts
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
    }
    
    
}
