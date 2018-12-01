//
//  RoundedWhiteButton.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/18/18.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import UIKit

class RoundedWhiteButton:UIButton {
    
    var highlightedColor = UIColor.white
    {
        didSet {
            
        }
    }
    var defaultColor = UIColor.clear
    {
        didSet {
          
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
           
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {

        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

