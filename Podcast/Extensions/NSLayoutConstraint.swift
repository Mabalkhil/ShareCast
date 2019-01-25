//
//  NSLayoutConstraint.swift
//  Podcast
//
//  Created by assem hakami on 19/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
