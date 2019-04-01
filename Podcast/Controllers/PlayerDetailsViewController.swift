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
import AVFoundation
import MediaPlayer

var right: Float = 100
var left: Float = 100

class PlayerDetailsViewController: UIViewController,MYAudioTabProcessorDelegate {

     var tapProcessor: MYAudioTapProcessor!
    // create instance of the same class to make it singlton, we just need to add a private constructer to avoid ceating a new object
    // but Swift is stupid, duh 
    static var shared = UIStoryboard(name: "Player", bundle: Bundle.main).instantiateViewController(withIdentifier: "PlayerStoryBoard") as! PlayerDetailsViewController
    
    var isPlaying = false
    var smartSpeedToggle = false
    var timerTest : Timer?
    
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
            smallPlayerPlay.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    // for UI to work on every device
    @IBOutlet weak var topPartofStack: UIView!
    
    
    @IBOutlet weak var smallPlayerLabel: UILabel!
    
    @IBOutlet weak var bigPlayer: UIStackView!
    
    @IBOutlet weak var smallPlayer: UIView!
    //
    @IBOutlet weak var SSLabel: UILabel!
    
    var episodeImg: UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "1400x1400-eagles_podcast-logo")
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
    
    //MARK:- smart speed variables
    let decibelThreshold = Float(0.00035)
    var decibelValuer: Float = 100
    var decibelValuel: Float = 100
    let defaultPlaybackRate = 1
    let sampleRate = 0.1
    var averagePower:Float = 0
    var aaveragePower:Float = 0
    
    //MARK:- Player Declaration
    //declaring the player
    var player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpViews()
        if episode != nil {
            let durationTime = Double(self.player.currentItem?.duration.seconds ?? 0)
            if (durationTime > 0.0) {
                handlePlayPause()
            }
            else{
                episodeName?.text = episode.title
                setupNowPlayingInfo()
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
            self.setupLockscreenCurrentTime() // to observe the current from lock screen
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
        self.setupRemoteControl()
        self.setupAudioSession()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelTapMaximize)))
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main){
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
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
            playerItem.addObserver(self, forKeyPath: "tracks", options: NSKeyValueObservingOptions.new, context:  nil);
            playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            player.isMeteringEnabled = true
            player.replaceCurrentItem(with: playerItem)
            player.play()
            isPlaying = true
            smartSpeedButton.isHidden = false
            SSLabel.isHidden = false
            smartSpeedButton.isEnabled = true
        } else{
            guard let url = URL(string: episode.streamURL) else { return }
            let playerItem = AVPlayerItem(url: url)
            player.isMeteringEnabled = true
            player.replaceCurrentItem(with: playerItem)
            player.play()
            isPlaying = true
            smartSpeedButton.isEnabled = false
            smartSpeedButton.isHidden = true
            SSLabel.isHidden = true
            
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
            smallPlayerPlay.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            isPlaying = true
        }else{
            player.pause()
            smallPlayerPlay.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
            playPauseButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
            isPlaying = false
        }
        print ("Time skiped" ,skiped)
//        guard let duration = player.currentItem?.duration else { return }
//        let durationInSeconds = CMTimeGetSeconds(duration)
        UserDefaults.standard.trackedEpisode(episodeTitle: self.episode.title, time: Double(getDurationInSeconds()))
    }
    
    
    fileprivate func getDurationInSeconds() -> Float {
        guard let duration = player.currentItem?.currentTime() else { return 0.0}
        let durationInSeconds = Float(CMTimeGetSeconds(duration))
        print("*************")
        print(durationInSeconds)
        return durationInSeconds
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
    fileprivate func seekToCurrentTime(delta: Float64){
        let skipTime = delta
        let timeScale: Int32 = (self.player.currentItem!.asset.duration.timescale)
        let time: CMTime = CMTimeMakeWithSeconds(Float64(skipTime), preferredTimescale: timeScale) //////
        let seekTime = CMTimeAdd(player.currentTime(), time)
        player.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
    }
    
    //controlling volume
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    
    //Dismiss Button
    @IBAction func handleDismiss(_ sender: Any) {
        smallPlayerImg.image = episodeImg.image
        smallPlayerLabel.text = episodeName.text
        smallPlayerPlay.imageView?.image = playPauseButton.imageView?.image
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
                    if episode.timeStamps!.count > i {
                        let time  = episode.timeStamps![i]
                        self.marks.append(Mark.init(time: time, desc: title))
                    }
                }
                setTable()
                print("time mark here")
                print(marks)
                pageControl.numberOfPages = 3
                scrollView.isScrollEnabled = true
                
            }
            else {
                //scrollView.isScrollEnabled = false
                pageControl.numberOfPages = 1
                print("No time marks")
            }
        }
    }
    
    // MARK:- we need to copy viwedidload to here, since this is the new starting point :)
    // No, it starts before loading actully
    func setEpisode(episode:Episode){
        // if the episode is not playing right now do the followings
        // stop the current one, update the episode info, play the new one
        // if not, keep the episode playing as it was
        // in both cases, the player will be showen
        let app = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        if (self.episode == nil || episode.title != self.episode.title) {
            if (self.episode != nil ) {
                print(getDurationInSeconds())
                UserDefaults.standard.trackedEpisode(episodeTitle: self.episode.title, time: Double(getDurationInSeconds()))
            }
            player.stop()
            smartSpeedToggle == false
            self.episode = episode
            self.marks.removeAll() // remove all time marks from before
            smartSpeedToggle = false
            episodeName?.text = episode.title
            channelName?.text = episode.author
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImg.sd_setImage(with: url)
            self.episode.timeStampLables = ["a","b"]
            app?.maximizePlayerDetails()
            setScrollView()
            smallPlayerPlay.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            playPauseButton.setImage(#imageLiteral(resourceName: "PauseButton"), for: .normal)
            var tracked = UserDefaults.standard.trackedEpisodes()
            playEpisode()
            if tracked[episode.title] != nil {
                let time = tracked[episode.title] as! Double
                let time_to: CMTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: 600) //////
                self.player.seek(to: time_to)
            }
            self.setupNowPlayingInfo()
        }
        else {
            app?.maximizePlayerDetails()
        }
    }
    
    
    

    
    func setUpViews() {
        currentTimeSlider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        scrollView.frame = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight/2.0)
        //view.insertSubview(self.smallPlayer)
        // small player settings
        smallPlayer.layer.cornerRadius = smallPlayer.frame.height/2
        smallPlayer.clipsToBounds = true
        smallPlayerImg.layer.borderWidth = 2.0;
        smallPlayerImg.layer.borderColor = UIColor.white.cgColor
        smallPlayerImg.layer.cornerRadius = smallPlayerImg.frame.height/2
        smallPlayerImg.clipsToBounds = true
        
        // swipe to remove the player
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(dismissSmallPlayer))
        swipeLeft.direction = .left
        smallPlayer.addGestureRecognizer(swipeLeft)
        //(UISwipeGestureRecognizer(target: self, action: #selector(dismissSmallPlayer)).direction = .left)
    }
    

    @objc func dismissSmallPlayer() {
        let offScreen = -smallPlayer.frame.width
        let y = smallPlayer.frame.minX
        let width = smallPlayer.frame.width
        let height = smallPlayer.frame.height
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.smallPlayer.frame = CGRect(x: offScreen, y: y, width: width, height: height)
            self.player.pause()
        }, completion: nil)
    }
    
    func addBlurEffect(img: UIImageView)
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = img.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        img.addSubview(blurEffectView)
    }
    
    //MARK:- Smart Speed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? AVPlayerItem == player.currentItem && keyPath == "tracks"){
            if let playerItem: AVPlayerItem = player.currentItem {
                if let tracks = playerItem.asset.tracks as? [AVAssetTrack] {
                    tapProcessor = MYAudioTapProcessor(avPlayerItem: playerItem)
                    playerItem.audioMix = tapProcessor.audioMix
                    tapProcessor.delegate = self
                }
            }
        }else if (object as? AVPlayerItem == player.currentItem && keyPath == "playbackBufferEmpty"){
            if player.currentItem!.isPlaybackBufferEmpty {
                print("no buffer")
                self.player.play()
            }
        }else if (object as? AVPlayerItem == player.currentItem && keyPath == "playbackLikelyToKeepUp"){
            if player.currentItem!.isPlaybackLikelyToKeepUp {
                self.player.play()
            }
        }
        
        
        
    }

    func audioTabProcessor(_ audioTabProcessor: MYAudioTapProcessor!, hasNewLeftChannelValue leftChannelValue:Float, rightChannelValue: Float) {
            right = rightChannelValue
            left = leftChannelValue
        //print("volume: \(leftChannelValue) : \(rightChannelValue)")
    }

    @IBAction func compressorSwitchChanged(_ sender: UISwitch) {
        tapProcessor.compressorEnabled  = sender.isOn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //smart speed button
    @IBOutlet weak var smartSpeedButton: UIButton!{
            didSet{
                smartSpeedButton.addTarget(self, action: #selector(toggleSmartSpeed), for: .touchUpInside)
            }
        }
    
    @objc func toggleSmartSpeed(){
        if smartSpeedToggle == false{
            smartSpeedToggle = true
            SSLabel.text = "ON"
            smartSpeedButton.setImage(#imageLiteral(resourceName: "ActiveSmartSpeed"), for: .normal)
            callingTimer()
        }else{
            smartSpeedToggle = false
            SSLabel.text = "OFF"
            smartSpeedButton.setImage(#imageLiteral(resourceName: "SmartSpeed"), for: .normal)
        }
    }
    
    
        //calling findSilences function every 0.1 seconds
    @objc func callingTimer() {
        if smartSpeedToggle == true{
                timerTest = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(findSilences), userInfo: nil, repeats: true)
            }
        }
    
    //finding the silences in episode and jump 0.1 seconds
    var skiped = 0.0
    @objc func findSilences() {
            guard isPlaying == true else { return }
            if smartSpeedToggle == true{
                player.updateMeters()
                if left < decibelThreshold && player.rate != 2 && left != Float(0){
                    print("0.1 seconds were skiped")
                    skiped = skiped + 0.1
                    let skipTime = 0.1
                    self.seekToCurrentTime(delta: skipTime)
                }
           }
    }
    
    
}



