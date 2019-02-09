//
//  PlayerHelper.swift
//  Podcast
//
//  Created by aziz alarfaj on 23/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import AVKit
import ACBAVPlayer
import MediaPlayer


public class PlayerHelper {
    var player: AVPlayer!
    var episode: Episode!
    
    
    init(){
        self.player = nil
        self.episode = nil
    }
    
    // this function for backgroudplaying
    func setUpAudionSession() {
        do {
            try AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let sessionError {
            print("Failed to activate session", sessionError)
        }
    }
    
    // this function is for contrling the player using the remote control center
    func setUpRemoteControl()  {
        let commanCenter = MPRemoteCommandCenter.shared()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        commanCenter.togglePlayPauseCommand.isEnabled = true
        commanCenter.togglePlayPauseCommand.addTarget { (_)
            -> MPRemoteCommandHandlerStatus in
            PlayerDetailsViewController.shared.handlePlayPause()
            return .success
        }
    }
    
    
    // this function for lockscreen info: title and channel
    func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // this function for lockscreen for tracking the time of the episode
    func setupLockscreenCurrentTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        let durationInSeconds = CMTimeGetSeconds((PlayerDetailsViewController.shared.player.currentItem?.duration ?? nil)!)
        let elapsedTime = CMTimeGetSeconds(PlayerDetailsViewController.shared.player.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}
