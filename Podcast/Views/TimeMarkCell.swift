//
//  TimeMarkCell.swift
//  Podcast
//
//  Created by Khaled H on 18/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class TimeMarkCell: UITableViewCell {

    var time: String?
    var desc: String?
    
    
    let timeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.isScrollEnabled = false
        return label
    }()
    
    let descriptionLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.isScrollEnabled = false
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(timeLabel)
        self.addSubview(descriptionLabel)
        
        timeLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        descriptionLabel.leftAnchor.constraint(equalTo: self.timeLabel.rightAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //        timeLabel.text = "--:--"
        //        timeLabel.textColor = .white
        if let time = time{
            timeLabel.text = time
            timeLabel.textColor = .white
        }
        
        if let des = desc{
            descriptionLabel.text = des
            descriptionLabel.textColor = .white
            descriptionLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.numberOfLines = 0
        }
        
        descriptionLabel.lineBreakMode = .byWordWrapping
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
