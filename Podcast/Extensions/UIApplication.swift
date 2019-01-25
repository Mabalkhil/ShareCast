//
//  UIApplication.swift
//  Podcast
//
//  Created by assem hakami on 19/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        //UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
