//
//  Mark.swift
//  Podcast
//
//  Created by aziz alarfaj on 29/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import Foundation


struct Mark: Codable {
    
    var time: String?
    var desc: String?
    
    init(time: String, desc:String) {
        self.desc = desc
        self.time = time
  
    }

}
