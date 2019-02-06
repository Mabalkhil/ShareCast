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


class PlayerDetailsViewController: UIViewController {

    // create instance of the same class to make it singlton, we just need to add a private constructer to avoid ceating a new object
    static var shared = UIStoryboard(name: "Player", bundle: Bundle.main).instantiateViewController(withIdentifier: "PlayerStoryBoard") as! PlayerDetailsViewController
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //names outlets
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var channelName: UILabel!
    
    //TimeSlider outlets
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    //volume outlet
    @IBOutlet weak var volumeSlider: UISlider!
    
    //small player
    @IBOutlet weak var smallPlayerImg: UIImageView!
    @IBOutlet weak var smallPlayerPlay: UIButton!{
        didSet{
            smallPlayerPlay.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            smallPlayerPlay.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var smallPlayerLabel: UILabel!
    
    @IBOutlet weak var bigPlayer: UIView!
    
    @IBOutlet weak var smallPlayer: UIView!
    //
    @IBOutlet weak var SSLabel: UILabel!
    
    var episodeImg: UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "appicon")
        return img
    }()
    
    struct Mark {
        var time:String
        var desc:String
    }
    
    var marks: [Mark] = []
    var episode:Episode!
    var myTableView: UITableView!
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var playerHelper = PlayerHelper() // player helper object to handle back ground playing
    
    //MARK:- Player Declaration
    //declaring the player
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setScrollView()
        if episode != nil {
            let durationTime = Double(self.player.currentItem?.duration.seconds ?? 0)
            if (durationTime > 0.0) {
                handlePlayPause()
            }
            else{
                episodeName?.text = episode.title
                playerHelper.player = player
                playerHelper.episode = episode
                playerHelper.setupNowPlayingInfo()
                playEpisode()
                guard let url = URL(string: episode.imageUrl ?? "") else { return }
                episodeImg.sd_setImage(with: url)
            }
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    static func getPlayer() -> PlayerDetailsViewController {
        return shared
    }
    
    
    //MARK:- Showing Progress
    //this function for displaying the progress (time)
    //This function would be called every passing second
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            self.currentTimeLabel.text = time.toDisplayString()
            var durationTime = self.player.currentItem?.duration
            durationTime = CMTime(seconds: (self.player.currentItem?.duration.seconds ?? 0) - (time.seconds ), preferredTimescale: durationTime!.timescale)
            self.durationLabel.text = "-"+(durationTime?.toDisplayString() ?? "--:--")
            self.playerHelper.setupLockscreenCurrentTime() // to observe the current from lock screen
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
        playerHelper.setUpAudionSession()  // handling the backgroudplaying stuff
        observePlayerCurrentTime()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelTapMaximize)))
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main){
        }
    }
    
    @objc func handelTapMaximize() {
        let app = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        app?.maximizePlayerDetails()
    }
    
    
    //this function to start playing when an episode is selected
    fileprivate func playEpisode(){
        if episode.fileUrl != ""{
            guard let fileURL = URL(string: episode.fileUrl ?? "") else{return}
            let fileName =  fileURL.lastPathComponent
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{ return }
            trueLocation.appendPathComponent(fileName)
            let playerItem = AVPlayerItem(url: trueLocation)
            player.isMeteringEnabled = true
            player.replaceCurrentItem(with: playerItem)
            player.play()
        } else{
            guard let url = URL(string: episode.streamURL) else { return }
            let playerItem = AVPlayerItem(url: url)
            player.isMeteringEnabled = true
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }

    
    
    //MARK:- Play & Pause
    //the pause button
    @IBOutlet weak var playPauseButton: UIButton!{
        didSet{
            playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause(){
        if player.timeControlStatus == .paused{
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
        }else{
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
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
        player.play()
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
        smallPlayerImg.image = episodeImg.image
        smallPlayerLabel.text = episodeName.text
        smallPlayerPlay = playPauseButton
        let app = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        app?.minimizePlayerDetails()
    }
    
    
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
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            count = count + 1
        }else if(count == 2){
            self.player.playImmediately(atRate: 2.0)
            self.speedUpLabel.text = "2.0"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            count = count + 1
        }else if(count == 3){
            self.player.playImmediately(atRate: 0.5)
            self.speedUpLabel.text = "0.5"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            count = 0
        }else{
            self.player.playImmediately(atRate: 1.0)
            self.speedUpLabel.text = "1.0"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            count = count + 1
        }
    }
    
    
    //MARK:- Time Mark
    //only handle if there is a time marks in an episode(Show table or don't)
    @objc func handleTimeMark(){
        if episode != nil {
            if (episode.timeStampLables!.count-1 > 0 ) {
                for i in stride(from: 0, through: episode.timeStampLables!.count-1, by: 1){
                    let title = episode.timeStampLables![i]
                    let time  = episode.timeStamps![i]
                    self.marks.append(Mark.init(time: time, desc: title))
                }
                setTable()
            }
            else {
                scrollView.isScrollEnabled = false
                pageControl.numberOfPages = 1
            }
        }
    }

    func setEpisode(episode:Episode){
        // if the episode is not playing right now do the followings
        // stop the current one, update the episode info, play the new one
        // if not it will not update, and keep the episode playing as it was
        // in both cases, the player will be showen
        let app = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        if (self.episode == nil || episode.title != self.episode.title) {
            player.stop()
            self.episode = episode
            episodeName?.text = episode.title
            channelName?.text = episode.author
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImg.sd_setImage(with: url)
            self.episode.timeStampLables = ["a","b"]
            self.episode.timeStamps = ["a","b"]
            app?.maximizePlayerDetails()
            playEpisode()
        }
        else {
            app?.maximizePlayerDetails()
        }
    }
}
