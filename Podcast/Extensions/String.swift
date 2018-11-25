//
//  String.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import Foundation

extension String{
    
   func  toSecureHTTPS() -> String{
    
    return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
