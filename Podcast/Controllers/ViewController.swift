//
//  ViewController.swift
//  Podcast
//
//  Created by MacBook on 02/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var imageView = UIImageView()
    var image = #imageLiteral(resourceName: "under_development")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(red: 82/255, green: 82/255, blue: 82/255, alpha: 1.0)
        
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        imageView.center = self.view.center
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent;
    }

}

