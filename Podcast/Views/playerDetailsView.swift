//
//  playerDetailsView.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit
import AVKit
import ACBAVPlayer



class PlayerDetailsView: UIView {

    
    
    var episode: Episode! {
        didSet{
            titleLabel.text = episode.title
//            authorLabel.text = episode.author
            playEpisode()
            guard let url = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    //MARK:- Showing Progress
    //this function for displaying the progress (time)
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            self.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self.player.currentItem?.duration
            self.durationLabel.text = durationTime?.toDisplayString()
            self.updateCurrentTimeSlider()
        }
    }
    
    
    //this function for displaying the progress (slider)
    fileprivate func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1,timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    //??
    override func awakeFromNib() {
        super.awakeFromNib()
        observePlayerCurrentTime()
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main){
            
        }
    }
    
    
    //this function to start playing when an episode is selected
    fileprivate func playEpisode(){
        guard let url = URL(string: episode.streamURL) else { return }
        let playerItem = AVPlayerItem(url: url)
        
        player.isMeteringEnabled = true
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    //MARK:- Player Declaration
    //declaring the player
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    //MARK:- Play & Pause
    //the pause button
    @IBOutlet weak var playPauseButton: UIButton!{
        didSet{
            playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause(){
        if player.timeControlStatus == .paused{
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
        }else{
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
           
        }
        
    }
    
    //MARK:- Other Playing related stuff
    
    //controlling playing by sliding the progress bar
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        self.player.seek(to: seekTime)
        //player.play()
        
    }
    
    //rewind button
    @IBAction func handleRewind(_ sender: Any) {
        
        seekToCurrentTime(delta: -15)
    }
    
    //forword button
    @IBAction func handleFastForword(_ sender: Any) {
        
        seekToCurrentTime(delta: 15)
        
    }
    
    //rewinding and forwording episode by 15 seconds
    fileprivate func seekToCurrentTime(delta: Int64){
        
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
        
    }
    
    //controlling volume
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    
    
    //Dismiss Button
    @IBAction func handleDismiss(_ sender: Any) {
        self.removeFromSuperview()
        //self.player.pause()
        player.stop()
    }
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.numberOfLines = 2
            
        }
    }
    
 //   @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    //MARK:- Voice Boost
    @IBOutlet weak var speedUpLabel: UILabel!
    
    @IBOutlet weak var speedUpButton: UIButton!{
        didSet{
            speedUpButton.addTarget(self, action: #selector(handleSpeedUp), for: .touchUpInside)
        }
    }
    
    var count = 1
    @objc func handleSpeedUp(){
        
       
        if (count == 1){
            self.player.playImmediately(atRate: 1.5)
            self.speedUpLabel.text = "1.5"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
            count = count + 1
        }else if(count == 2){
            self.player.playImmediately(atRate: 2.0)
            self.speedUpLabel.text = "2.0"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
            count = count + 1
        }else if(count == 3){
            self.player.playImmediately(atRate: 0.5)
            self.speedUpLabel.text = "0.5"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
            count = 0
        }else{
            self.player.playImmediately(atRate: 1.0)
            self.speedUpLabel.text = "1.0"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
            count = count + 1 
        }
        
        
        
        
        
        
       
        
        
        
        
        
        
        
        
       
        
    }
    
    
    //MARK:- Time Mark
    

    
    @IBOutlet weak var timeMarkButton: UIButton!{
        didSet{
            timeMarkButton.addTarget(self, action: #selector(handleTimeMark), for: .touchUpInside)
        }
    }


    @objc func handleTimeMark(){
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if (episode.timeStampLables.count-1 > 0 ) {
            for i in stride(from: 0, through: episode.timeStampLables.count-1, by: 1){
                let title = episode.timeStampLables[i]
                let time  = episode.timeStamps[i]
                let timeInSecondsList = time.split(whereSeparator: { $0 == ":" || $0 == " " })//.map { Double($0)!}
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
                alert.addAction(UIAlertAction(title: title , style: .default) { _ in
                    self.player.seek(to: CMTimeMakeWithSeconds(timeInSeconds, preferredTimescale: 1))
                })
            }
            alert.addAction(UIAlertAction(title: "cancel" , style: .cancel))
        }
        else {
            alert.addAction(UIAlertAction(title: "No time marks for this episode" , style: .cancel))
        }
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }

    
    
    //MARK:- Smart Speed
    
    let decibelThreshold = Float(-35)
    let defaultPlaybackRate = 1
    let sampleRate = 0.1
    var skippedSeconds = 0.0
    
    
    //smart speed button
//    @IBOutlet weak var smartSpeedButton: UIButton!{
//        didSet{
//            smartSpeedButton.addTarget(self, action: #selector(callingTimer), for: .touchUpInside)
//        }
//    }
//
//    //calling findSilences function every 0.1 seconds
//    @objc func callingTimer() {
//        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(findSilences), userInfo: nil, repeats: true)
//    }
//
//    //finding the silences in episode and increase speed to 3
//    //NOTE: it is still not working, the averagePower is always ZERO
//    @objc func findSilences() {
//        guard player.isPlaying == true else { return }
//        player.updateMeters()
//
//        let averagePower = player.averagePower(forChannel: 0)
//
//        //print(player.averagePowerInLinearForm(forChannel: 1))
//        if averagePower < decibelThreshold {
//            self.player.playImmediately(atRate: 3)
//            skippedSeconds += sampleRate - (sampleRate / 3)
//        } else {
//            self.player.playImmediately(atRate: 1)
//        }
//    }
    
    
   
    
}
