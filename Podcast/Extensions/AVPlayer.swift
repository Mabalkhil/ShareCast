//
//  AVPlayer.swift
//  Podcast
//
//  Created by Khaled H on 30/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
    
}
