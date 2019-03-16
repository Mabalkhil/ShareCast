//
//  PlayerExtension.swift
//  Podcast
//
//  Created by Khaled H on 04/02/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import AVKit
import ACBAVPlayer
import MediaPlayer

extension PlayerDetailsViewController: UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    //MARK:- Scroll View
    //change the pageview when scrolled
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    
    // this function for lockscreen info: title and channel
    func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // this function for backgroudplaying
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }
    
     //this function is for contrling the player using the remote control center
    func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            //self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            return .success
        }
    
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            //self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
     }
    
    // this function for lockscreen for tracking the time of the episode
    func setupLockscreenCurrentTime() {
        // use empty dictionary if nowPlayingInfo is nil
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        // some modifications here
        guard let currentItem = player.currentItem else { return }
        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    //setting scroll view
    func setScrollView() {
        pageControl.numberOfPages = 1
        frame.origin.x = scrollView.frame.size.width * 0
        frame.size = scrollView.frame.size
        //episodeImg.frame = frame
        episodeImg.frame.origin.x = 0
        episodeImg.frame.size.width = self.view.frame.width
        episodeImg.frame.size.height = scrollView.frame.size.height
        scrollView.addSubview(episodeImg)
        handleTimeMark()
        
        scrollView.delegate = self
       // scrollView.isScrollEnabled = true
    }
    
    
    //MARK:- Table view functions
    
    func setTable() {
        
        scrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: scrollView.frame.size.height)
        
        frame.origin.x = self.view.frame.width
        //frame.size = scrollView.frame.size
        
        myTableView = UITableView(frame: frame)
        myTableView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        let copyedView = episodeImg.copyView() as UIImageView
        addBlurEffect(img: copyedView)
        myTableView.backgroundView = copyedView
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
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.0)
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

extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}
