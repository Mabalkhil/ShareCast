//
//  ResDetailHeaderView.swift
//  practice-tableView
//

//  Copyright © 2018 Mohammed Abalkhail. All rights reserved.
//

import UIKit

class ChannelHeaderView: UIView {
    @IBOutlet weak var chennelImage: UIImageView!
    @IBOutlet weak var SubButton: UIButton!
    @IBOutlet var BellButton: UIButton! {
        didSet{
            let origImage = UIImage(named: "alarm");
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            BellButton.setImage(tintedImage, for: .normal)
            BellButton.tintColor = UIColor.white
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel.layer.cornerRadius = 5.0
            typeLabel.layer.masksToBounds = true
        }
    }
    
    
}
