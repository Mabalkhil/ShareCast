//
//  playerDetailsView.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit
import AVKit


class PlayerDetailsView: UIView {
    
    var episode: Episode! {
        didSet{
            titleLabel.text = episode.title
         //   authorLabel.text = episode.author
            playEpisode()
           guard let url = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            self.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self.player.currentItem?.duration
            self.durationLabel.text = durationTime?.toDisplayString()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        observePlayerCurrentTime()
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main){
            
        }
    }
    
    
    
    fileprivate func playEpisode(){
        guard let url = URL(string: episode.streamURL) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
   
    @IBOutlet weak var playPauseButton: UIButton!{
        didSet{
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause(){
        if player.timeControlStatus == .paused{
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        }else{
           player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        }
        
    }
    
    
//    @IBAction func handleDismiss(_ sender: Any) {
//        self.removeFromSuperview()
//        self.player.pause()
//    }
    
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
    
    
    
    
    @IBOutlet weak var speedUpButton: UIButton!{
        didSet{
            speedUpButton.addTarget(self, action: #selector(handleSpeedUp), for: .touchUpInside)
        }
    }
    
    
    @objc func handleSpeedUp(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        
        alert.addAction(UIAlertAction(title: "X2", style: .default) { _ in
            self.player.playImmediately(atRate: 2.0)
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        })
        
        alert.addAction(UIAlertAction(title: "X1.5", style: .default) { _ in
            self.player.playImmediately(atRate: 1.5)
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        })
        
        alert.addAction(UIAlertAction(title: "X1", style: .default) { _ in
            self.player.playImmediately(atRate: 1.0)
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        })
        
        alert.addAction(UIAlertAction(title: "X0.5", style: .default) { _ in
            self.player.playImmediately(atRate: 0.5)
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
           // let alertWindow = UIWindow()
            //alertWindow.windowLevel = UIWindow.Level.alert - 1;
        })
        
        //let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
//    @IBOutlet weak var timeMarkButton: UIButton!{
//        didSet{
//            timeMarkButton.addTarget(self, action: #selector(handleTimeMark), for: .touchUpInside)
//        }
//    }
    
    
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
        }
        else {
            alert.addAction(UIAlertAction(title: "No time marks for this episode" , style: .default) { _ in
                self.player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1))
            })
        }
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
