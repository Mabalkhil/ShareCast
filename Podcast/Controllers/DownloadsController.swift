//
//  DownloadsController.swift
//  Podcast
//
//  Created by assem hakami on 16/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    @IBOutlet var tablwViewDownload: UITableView!
    
    var list = [CommentObj]()
    
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
     
        
       
       //list.append(Episode(title: "b",pubDate: Date(),describtion:"a",imageUrl: "a",author:"a",streamURL:"a",timeStampLables:["aa","bb"],timeStamps:["aaa","bb"]))
        
        
        list.append(CommentObj(realName:"abc",username:"sss",img:"sss",com:"ddd"))
         list.append(CommentObj(realName:"abc",username:"sss",img:"sss",com:"ddd"))
         list.append(CommentObj(realName:"abc",username:"sss",img:"sss",com:"ddd"))
         list.append(CommentObj(realName:"abc",username:"sss",img:"sss",com:"ddd"))
        
        
        
        
        //setupTableView()
    }
    
    
    
    
   
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DownloadEpisodeCell

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        list.count
    }
    
    
    
    
    
    //MARK:- Setup
    
    fileprivate func setupTableView(){
    
        
    
}

}
