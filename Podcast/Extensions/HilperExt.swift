//
//  HilperExt.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/18/18.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /**
     Adds a vertical gradient layer with two **UIColors** to the **UIView**.
     - Parameter topColor: The top **UIColor**.
     - Parameter bottomColor: The bottom **UIColor**.
     */
    func addVerticalGradientLayer(topColor:UIColor, bottomColor:UIColor) {
       let gardient = CAGradientLayer()
        gardient.frame = self.bounds
        gardient.colors = [topColor.cgColor , bottomColor.cgColor]
        gardient.locations = [0.0 , 1.0]
        gardient.startPoint = CGPoint(x: 0, y: 0)
        gardient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gardient, at: 0)
    }
}
