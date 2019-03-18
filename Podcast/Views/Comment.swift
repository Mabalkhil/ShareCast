//
//  Comment.swift
//  Podcast
//
//  Created by Mazen.A on 1/17/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var commentDescription: UITextView!
    @IBOutlet weak var UserRealName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//    func setComment(comment:CommentObj){
//
//    }
    
    var comment: CommentObj? {
        didSet{
            //        userImage.layer.borderWidth = 1
            userImage.layer.masksToBounds = false
            //        userImage.layer.borderColor = UIColor.black.cgColor
            userImage.layer.cornerRadius = userImage.frame.height/2
            userImage.clipsToBounds = true
            
            UserRealName.text = comment?.userRealName
            username.text = comment?.userName
//            userImage.image = UIImage(named: comment?.userImage)
            commentDescription.text = comment?.commentDesc
            userImage.sd_setImage(with: comment?.imgURL, completed: nil)
        }
    }

}
