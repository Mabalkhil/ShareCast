//
//  TimelineTVC.swift
//  Podcast
//
//  Created by Mazen.A on 2/25/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class TimelineTVC: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var episode_image: UIImageView?
    @IBOutlet weak var episode_name: UILabel!
    @IBOutlet weak var episode_desc: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAttributes(post:Post){
         var url = URL(string: post.episode_img_url!)
        episode_image?.sd_setImage(with: url, completed: nil)
        usernameLabel.text = post.username
        episode_name.text = post.episode_name
        episode_desc.text = post.episode_desc
        comment.text = post.postContent
         url = URL(string: post.userImage!)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let err = error {
                print(err)
            }
            DispatchQueue.main.async {
                self.userImage.image = UIImage(data: data!)
            }
        }).resume()
 
//       let url = URL(string: post.episode_img_url!)
//        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//            if let err = error {
//                print(err)
//            }
//            DispatchQueue.main.async {
//                self.episode_image.image = UIImage(data: data!)
//            }
//        }).resume()
    }

}
