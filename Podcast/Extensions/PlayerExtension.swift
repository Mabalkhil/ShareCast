//
//  PlayerExtension.swift
//  Podcast
//
//  Created by Khaled H on 04/02/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import AVKit

extension PlayerDetailsViewController: UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    //MARK:- Scroll View
    //change the pageview when scrolled
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    //setting scroll view
    func setScrollView() {
        pageControl.numberOfPages = 2
        frame.origin.x = scrollView.frame.size.width * 0
        frame.size = scrollView.frame.size
        //episodeImg.frame = frame
        episodeImg.frame.origin.x = 0
        episodeImg.frame.size.width = self.view.frame.width
        episodeImg.frame.size.height = scrollView.frame.size.height
        scrollView.addSubview(episodeImg)
        
        handleTimeMark()
        
        
        scrollView.delegate = self
        //scrollView.isScrollEnabled = false
    }
    
    
    //MARK:- Table view functions
    
    func setTable() {
        
        scrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: scrollView.frame.size.height)
        
        frame.origin.x = self.view.frame.width + 5
        //frame.size = scrollView.frame.size
        
        myTableView = UITableView(frame: frame)
        myTableView.backgroundColor = #colorLiteral(red: 0.2548794746, green: 0.254914552, blue: 0.2548675537, alpha: 1)
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.register(TimeMarkCell.self, forCellReuseIdentifier: "TimeMarkCell")
        
        scrollView.addSubview(myTableView)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeMarkCell", for: indexPath) //as! TimeMarkCell
        let tm = self.marks[indexPath.row]
//        cell.time = tm.time
//        cell.desc = tm.desc
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.text = tm.time
        cell.detailTextLabel?.text = tm.desc
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 0.2548794746, green: 0.254914552, blue: 0.2548675537, alpha: 1)
    }
    
    //Handing the selected time mark
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTime = self.marks[indexPath.row].time
        
        let timeInSecondsList = selectedTime.split(whereSeparator: { $0 == ":" || $0 == " " })//.map { Double($0)!}
        var timeInSeconds:Double = 0
        if (timeInSecondsList.count == 3 ) {
            let hours = (Double(timeInSecondsList[0]) ?? 0.0 ) * 3600
            let minutes = (Double(timeInSecondsList[1])  ?? 0.0) * 60
            let seconds = (Double( timeInSecondsList[2])  ?? 0.0)
            timeInSeconds = hours + minutes + seconds
        }
        else {
            let minutes = (Double(timeInSecondsList[0])  ?? 0.0) * 60
            let seconds = (Double( timeInSecondsList[1])  ?? 0.0)
            timeInSeconds =  minutes + seconds
        }
        
        self.player.seek(to: CMTimeMakeWithSeconds(timeInSeconds, preferredTimescale: 1))
        
    }
}
